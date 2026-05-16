from rest_framework import status
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework_simplejwt.tokens import RefreshToken

import secrets

from accounts.models import PairingCode, ParentalLink
from accounts.serializers import RegisterSerializer, UserSerializer
from devices.models import Device


class RegisterView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = RegisterSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.save()
        refresh = RefreshToken.for_user(user)
        return Response(
            {"access": str(refresh.access_token), "refresh": str(refresh)},
            status=status.HTTP_201_CREATED,
        )


class MeView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        return Response(UserSerializer(request.user).data)


class GenerateCodeView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        pairing_code = PairingCode.generate(request.user)
        return Response(
            {"code": pairing_code.code, "expires_at": pairing_code.expires_at},
            status=status.HTTP_201_CREATED,
        )


class PairView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        code = request.data.get("code")
        if not code:
            return Response(
                {"error": "Campo 'code' é obrigatório."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        try:
            pairing_code = PairingCode.objects.get(code=code, used=False)
        except PairingCode.DoesNotExist:
            return Response(
                {"error": "Código inválido ou já utilizado."},
                status=status.HTTP_404_NOT_FOUND,
            )

        if pairing_code.is_expired:
            return Response(
                {"error": "Código expirado."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        # Mesma conta nos dois devices é permitido (pai loga no celular do filho)
        link, created = ParentalLink.objects.get_or_create(
            parent=pairing_code.user,
            child=request.user,
        )

        # Auto-create a Device for the child if not exists
        device_token = secrets.token_hex(16)
        device, _ = Device.objects.get_or_create(
            owner=request.user,
            child_name=request.user.get_full_name() or request.user.email,
            defaults={"device_token": device_token},
        )

        # Mark code as used
        pairing_code.used = True
        pairing_code.save()

        return Response(
            {
                "link": {"parent_id": link.parent.id, "child_id": link.child.id},
                "device_token": device.device_token,
            },
            status=status.HTTP_201_CREATED if created else status.HTTP_200_OK,
        )


class LinkStatusView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        # Check if user is a child (has a parent linked)
        parent_link = ParentalLink.objects.filter(child=request.user).first()
        if parent_link:
            return Response({
                "linked": True,
                "role": "child",
                "partner": {
                    "id": parent_link.parent.id,
                    "name": parent_link.parent.get_full_name() or parent_link.parent.email,
                },
            })

        # Check if user is a parent (has children linked)
        child_link = ParentalLink.objects.filter(parent=request.user).first()
        if child_link:
            return Response({
                "linked": True,
                "role": "parent",
                "partner": {
                    "id": child_link.child.id,
                    "name": child_link.child.get_full_name() or child_link.child.email,
                },
            })

        return Response({"linked": False, "role": None, "partner": None})
