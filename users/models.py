from django.contrib.auth.models import AbstractUser
from django.db import models


class CustomUser(AbstractUser):
    phone = models.CharField(max_length=15, blank=True)
    avatar = models.ImageField(upload_to='avatars/', blank=True)

    class Meta:
        db_table = 'users'
        verbose_name = '用户'

    def __str__(self):
        return self.username