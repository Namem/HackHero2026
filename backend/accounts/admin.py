from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from accounts.models import PairingCode, ParentalLink, User

admin.site.register(User, UserAdmin)


@admin.register(PairingCode)
class PairingCodeAdmin(admin.ModelAdmin):
    list_display = ("code", "user", "expires_at", "used", "created_at")
    list_filter = ("used",)
    search_fields = ("code", "user__email")


@admin.register(ParentalLink)
class ParentalLinkAdmin(admin.ModelAdmin):
    list_display = ("parent", "child", "created_at")
    search_fields = ("parent__email", "child__email")
