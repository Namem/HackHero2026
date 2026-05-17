import secrets

from rest_framework import status
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from devices.models import Device, MonitoredApp
from devices.serializers import DeviceSerializer, MonitoredAppSerializer
from monitoring.serializers import TriggerSerializer


class DeviceListCreateView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        devices = Device.objects.filter(owner=request.user)
        return Response(DeviceSerializer(devices, many=True).data)

    def post(self, request):
        data = request.data.copy()
        data["device_token"] = secrets.token_hex(16)
        serializer = DeviceSerializer(data=data)
        serializer.is_valid(raise_exception=True)
        serializer.save(owner=request.user)
        return Response(serializer.data, status=status.HTTP_201_CREATED)


class MonitoredAppView(APIView):
    permission_classes = [IsAuthenticated]

    def _get_device(self, request, device_token):
        """Get device if user is owner OR is a parent linked to the device owner."""
        from accounts.models import ParentalLink
        try:
            return Device.objects.get(device_token=device_token, owner=request.user)
        except Device.DoesNotExist:
            device = Device.objects.get(device_token=device_token)
            if ParentalLink.objects.filter(parent=request.user, child=device.owner).exists():
                return device
            raise

    def get(self, request, device_token):
        device = self._get_device(request, device_token)
        apps = device.monitored_apps.all()
        return Response(MonitoredAppSerializer(apps, many=True).data)

    def post(self, request, device_token):
        device = self._get_device(request, device_token)

        # Parent flow: toggle is_active de apps existentes
        # Accepts {"app_ids": [1, 2, 3]} — IDs marcados como monitorados
        if "app_ids" in request.data:
            app_ids = request.data.get("app_ids") or []
            qs = device.monitored_apps.all()
            qs.filter(id__in=app_ids).update(is_active=True)
            qs.exclude(id__in=app_ids).update(is_active=False)
            return Response(
                MonitoredAppSerializer(device.monitored_apps.all(), many=True).data,
                status=status.HTTP_200_OK,
            )

        # Child flow: bulk sync da lista de apps instalados
        # Accepts {"apps": [{"package_name": "...", "app_name": "...", "icon": "..."}]}
        if "apps" in request.data:
            apps_list = request.data["apps"]
            existing = {a.package_name: a for a in device.monitored_apps.all()}
            seen_packages = set()
            result = []
            for app_data in apps_list:
                pkg = app_data["package_name"]
                seen_packages.add(pkg)
                if pkg in existing:
                    # Atualiza metadados mantendo is_active e o ID
                    obj = existing[pkg]
                    obj.app_name = app_data.get("app_name", pkg)
                    icon = app_data.get("icon", "")
                    if icon:
                        obj.icon_base64 = icon
                    obj.save()
                else:
                    obj = MonitoredApp.objects.create(
                        device=device,
                        package_name=pkg,
                        app_name=app_data.get("app_name", pkg),
                        icon_base64=app_data.get("icon", ""),
                        is_active=False,  # padrão: não monitora até pai escolher
                    )
                result.append(obj)
            # Remove apps que não estão mais instalados
            device.monitored_apps.exclude(package_name__in=seen_packages).delete()
            return Response(
                MonitoredAppSerializer(result, many=True).data,
                status=status.HTTP_200_OK,
            )

        # Single app
        serializer = MonitoredAppSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        serializer.save(device=device)
        return Response(serializer.data, status=status.HTTP_201_CREATED)

    def delete(self, request, device_token, app_id):
        device = self._get_device(request, device_token)
        MonitoredApp.objects.filter(id=app_id, device=device).delete()
        return Response(status=status.HTTP_204_NO_CONTENT)


class ChildDevicesView(APIView):
    """Retorna devices dos filhos vinculados ao pai autenticado."""
    permission_classes = [IsAuthenticated]

    def get(self, request):
        from accounts.models import ParentalLink
        child_ids = ParentalLink.objects.filter(
            parent=request.user
        ).values_list("child_id", flat=True)
        devices = Device.objects.filter(owner_id__in=child_ids)
        return Response(DeviceSerializer(devices, many=True).data)


class DeviceConfigView(APIView):
    """Usado pelo app do filho para buscar apps monitorados e gatilhos."""
    permission_classes = [AllowAny]

    def get(self, request, device_token):
        try:
            device = Device.objects.get(device_token=device_token)
        except Device.DoesNotExist:
            return Response({"detail": "Device não encontrado."}, status=404)

        apps = device.monitored_apps.filter(is_active=True).values("package_name", "app_name")
        triggers = device.triggers.all()

        return Response({
            "device_token": device_token,
            "child_name": device.child_name,
            "monitored_apps": list(apps),
            "triggers": TriggerSerializer(triggers, many=True).data,
        })
