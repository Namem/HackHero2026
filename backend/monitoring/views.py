import random

from django.db import models
from rest_framework.parsers import MultiPartParser
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from devices.models import Device
from monitoring.models import Alert, Trigger
from monitoring.serializers import AlertSerializer, TriggerSerializer
from services.ai_agent import analyze_image, generate_recommendations


# Mock data por nível de risco — para o modo beta de simulação
SIMULATION_DATA = {
    "high_risk": {
        "categories": [
            ("Aliciamento", "Conversa suspeita detectada com possível padrão de grooming"),
            ("Conteúdo adulto", "Imagens inadequadas para a faixa etária identificadas"),
            ("Extremismo", "Discurso de ódio e radicalização detectados"),
            ("Apostas", "Interface de cassino online identificada"),
        ],
        "app_packages": ["com.roblox.client", "com.epicgames.fortnite", "com.discord", "com.example.game"],
        "confidence_range": (0.85, 0.99),
    },
    "attention": {
        "categories": [
            ("Violência", "Cenas de violência gráfica em jogo"),
            ("Bullying", "Linguagem agressiva no chat do jogo"),
            ("Microtransações", "Múltiplas tentativas de compra em jogo"),
            ("Privacidade", "Pedido de informações pessoais detectado"),
        ],
        "app_packages": ["com.activision.callofduty.shooter", "ee.dustland.android.dustlandsudoku", "com.supercell.clashroyale"],
        "confidence_range": (0.70, 0.90),
    },
    "safe": {
        "categories": [
            ("Microtransação leve", "Compra opcional de item cosmético detectada"),
            ("FOMO", "Notificação de evento por tempo limitado"),
            ("Conteúdo neutro", "Atividade normal de jogo identificada"),
        ],
        "app_packages": ["com.minecraft", "com.toca.world", "com.duolingo"],
        "confidence_range": (0.60, 0.85),
    },
}


class AnalyzeView(APIView):
    permission_classes = [AllowAny]
    parser_classes = [MultiPartParser]

    def post(self, request):
        device_token = request.data.get("device_token")
        app_package = request.data.get("app_package", "")
        image_file = request.FILES.get("image")

        try:
            device = Device.objects.get(device_token=device_token)
        except Device.DoesNotExist:
            return Response({"detail": "Device não encontrado."}, status=404)

        image_bytes = image_file.read()
        report = analyze_image(image_bytes, app_package=app_package)
        del image_bytes

        if report["risk_level"] != "safe":
            Alert.objects.create(
                device=device,
                risk_level=report["risk_level"],
                category=report["categoria"],
                description=report["descricao"],
                confidence=report["confianca"],
                app_package=app_package or None,
            )

        return Response(report)


class SimulateAlertView(APIView):
    """Endpoint para simular um alerta sem precisar de imagem real ou IA.
    Usado para testes beta e demonstrações.

    POST body:
      {
        "device_token": "...",
        "risk_level": "high_risk" | "attention" | "safe"
      }
    """
    permission_classes = [AllowAny]

    def post(self, request):
        device_token = request.data.get("device_token")
        risk_level = request.data.get("risk_level", "attention")

        if risk_level not in SIMULATION_DATA:
            return Response(
                {"detail": f"risk_level inválido. Use: {list(SIMULATION_DATA.keys())}"},
                status=400,
            )

        try:
            device = Device.objects.get(device_token=device_token)
        except Device.DoesNotExist:
            return Response({"detail": "Device não encontrado."}, status=404)

        data = SIMULATION_DATA[risk_level]
        category, description = random.choice(data["categories"])
        app_package = random.choice(data["app_packages"])
        confidence = random.uniform(*data["confidence_range"])

        alert = Alert.objects.create(
            device=device,
            risk_level=risk_level,
            category=category,
            description=description,
            confidence=round(confidence, 2),
            app_package=app_package,
        )

        return Response({
            "alert_id": alert.id,
            "risk_level": risk_level,
            "category": category,
            "description": description,
            "confidence": alert.confidence,
            "app_package": app_package,
            "created_at": alert.created_at.isoformat(),
            "message": f"Alerta simulado criado com sucesso ({risk_level})",
        }, status=201)


class AlertDetailView(APIView):
    """Operações sobre um alerta específico.

    DELETE: pai dispensa/remove o alerta da lista (marca como visto/resolvido).
    """
    permission_classes = [IsAuthenticated]

    def delete(self, request, alert_id):
        from accounts.models import ParentalLink
        from monitoring.models import Alert as AlertModel

        child_ids = ParentalLink.objects.filter(
            parent=request.user
        ).values_list("child_id", flat=True)
        accessible_devices = Device.objects.filter(
            models.Q(owner=request.user) | models.Q(owner_id__in=child_ids)
        )

        try:
            alert = AlertModel.objects.get(id=alert_id, device__in=accessible_devices)
        except AlertModel.DoesNotExist:
            return Response({"detail": "Alerta não encontrado."}, status=404)

        alert.delete()
        return Response(status=204)


class AlertListView(APIView):
    """Lista alertas para o pai autenticado.

    - Sem query params: retorna alertas de TODOS os filhos vinculados ao pai
    - Com ?device_token=...: retorna apenas alertas daquele device (se o pai tiver acesso)
    """
    permission_classes = [IsAuthenticated]

    # Mapeamento string -> número 0-10 (compatível com a UI Flutter)
    RISK_LEVEL_MAP = {
        "safe": 2,
        "attention": 5,
        "high_risk": 8,
    }

    def get(self, request):
        from accounts.models import ParentalLink

        device_token = request.query_params.get("device_token")

        # Devices que o pai pode acessar = próprios + dos filhos vinculados
        child_ids = ParentalLink.objects.filter(
            parent=request.user
        ).values_list("child_id", flat=True)
        accessible_devices = Device.objects.filter(
            models.Q(owner=request.user) | models.Q(owner_id__in=child_ids)
        )

        if device_token:
            accessible_devices = accessible_devices.filter(device_token=device_token)

        from monitoring.models import Alert as AlertModel
        alerts = AlertModel.objects.filter(device__in=accessible_devices)[:50]

        # Resposta no formato esperado pelo Flutter (lista pura)
        result = []
        for a in alerts:
            result.append({
                "id": a.id,
                "risk_level": self.RISK_LEVEL_MAP.get(a.risk_level, 5),
                "categories": [a.category] if a.category else [],
                "description": a.description,
                "app_name": self._app_name_from_package(a.app_package),
                "app_package": a.app_package,
                "timestamp": a.created_at.isoformat(),
                "seen": False,  # TODO: persistir em outra tabela quando implementarmos
            })
        return Response(result)

    @staticmethod
    def _app_name_from_package(package):
        if not package:
            return None
        # Mapeamento simples para nomes amigáveis
        mapping = {
            "com.dts.freefireth": "Free Fire",
            "com.activision.callofduty.shooter": "Call of Duty",
            "com.roblox.client": "Roblox",
            "com.epicgames.fortnite": "Fortnite",
            "com.discord": "Discord",
            "com.google.android.youtube": "YouTube",
            "com.android.chrome": "Chrome",
            "com.supercell.clashroyale": "Clash Royale",
            "com.minecraft": "Minecraft",
            "com.toca.world": "Toca World",
            "com.duolingo": "Duolingo",
            "ee.dustland.android.dustlandsudoku": "Sudoku",
        }
        if package in mapping:
            return mapping[package]
        # Fallback: pega a última parte do package
        return package.split(".")[-1].capitalize()


class TriggerView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, device_token):
        device = Device.objects.get(device_token=device_token, owner=request.user)
        return Response(TriggerSerializer(device.triggers.all(), many=True).data)

    def post(self, request, device_token):
        device = Device.objects.get(device_token=device_token, owner=request.user)
        serializer = TriggerSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        serializer.save(device=device)
        return Response(serializer.data, status=201)

    def delete(self, request, device_token, trigger_id):
        device = Device.objects.get(device_token=device_token, owner=request.user)
        Trigger.objects.filter(id=trigger_id, device=device).delete()
        return Response(status=204)


class RecommendationsView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, device_token):
        try:
            device = Device.objects.get(device_token=device_token, owner=request.user)
        except Device.DoesNotExist:
            return Response({"detail": "Device não encontrado."}, status=404)

        alerts = list(
            device.alerts.values("risk_level", "category", "description", "app_package", "created_at")[:30]
        )

        if not alerts:
            return Response({"recommendations": [
                "Nenhum alerta registrado ainda. Continue monitorando."
            ]})

        recommendations = generate_recommendations(device.child_name, alerts)
        return Response({"recommendations": recommendations})
