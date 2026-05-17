from django.urls import path
from monitoring.views import (
    AlertDetailView,
    AlertListView,
    AnalyzeView,
    SimulateAlertView,
    TriggerView,
    RecommendationsView,
)

urlpatterns = [
    path("analyze/", AnalyzeView.as_view()),
    path("simulate-alert/", SimulateAlertView.as_view()),
    path("alerts/", AlertListView.as_view()),
    path("alerts/<int:alert_id>/", AlertDetailView.as_view()),
    path("devices/<str:device_token>/triggers/", TriggerView.as_view()),
    path("devices/<str:device_token>/triggers/<int:trigger_id>/", TriggerView.as_view()),
    path("devices/<str:device_token>/recommendations/", RecommendationsView.as_view()),
]
