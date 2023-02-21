from django.contrib.auth.models import AbstractUser


class CustomUser(AbstractUser):
    # age = models.IntegerField(blank=True, null=True)
    # city = models.CharField(max_length=255, blank=True, null=True)

    class Meta:
        verbose_name = "Пользователь"
        verbose_name_plural = "Пользователи"