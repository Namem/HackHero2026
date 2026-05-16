import random
from datetime import timedelta

from django.contrib.auth.models import AbstractUser
from django.db import models
from django.utils import timezone


class User(AbstractUser):
    email = models.EmailField(unique=True)
    USERNAME_FIELD = "email"
    REQUIRED_FIELDS = ["username"]


class PairingCode(models.Model):
    code = models.CharField(max_length=6, unique=True)
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name="pairing_codes")
    expires_at = models.DateTimeField()
    used = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.code} ({self.user.email})"

    @property
    def is_expired(self):
        return timezone.now() > self.expires_at

    @classmethod
    def generate(cls, user):
        code = f"{random.randint(0, 999999):06d}"
        # Ensure uniqueness
        while cls.objects.filter(code=code, used=False).exists():
            code = f"{random.randint(0, 999999):06d}"
        expires_at = timezone.now() + timedelta(minutes=10)
        return cls.objects.create(code=code, user=user, expires_at=expires_at)


class ParentalLink(models.Model):
    parent = models.ForeignKey(User, on_delete=models.CASCADE, related_name="children_links")
    child = models.ForeignKey(User, on_delete=models.CASCADE, related_name="parent_links")
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ("parent", "child")

    def __str__(self):
        return f"{self.parent.email} → {self.child.email}"
