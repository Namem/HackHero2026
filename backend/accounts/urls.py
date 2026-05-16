from django.urls import path
from rest_framework_simplejwt.views import TokenObtainPairView

from accounts.views import (
    GenerateCodeView,
    LinkStatusView,
    MeView,
    PairView,
    RegisterView,
)

urlpatterns = [
    path("register/", RegisterView.as_view(), name="register"),
    path("login/", TokenObtainPairView.as_view(), name="login"),
    path("me/", MeView.as_view(), name="me"),
    path("link/generate/", GenerateCodeView.as_view(), name="link-generate"),
    path("link/pair/", PairView.as_view(), name="link-pair"),
    path("link/status/", LinkStatusView.as_view(), name="link-status"),
]
