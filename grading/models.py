from django.db import models
from django.contrib.auth import get_user_model
from django.utils import timezone

User = get_user_model()

class Image(models.Model):
    image_file = models.ImageField(upload_to='')
    user_id = models.BigIntegerField(null=False, blank=False)
    upload_time = models.DateTimeField(null=False, blank=False, default=timezone.now)
    image_name = models.CharField(max_length=200, null=False, blank=False)

    class Meta:
        db_table = 'image'

class GradingResult(models.Model):
    final_grade = models.CharField(max_length=50, null=False, blank=False)
    created_at = models.DateTimeField(null=False, blank=False, default=timezone.now)
    user_id = models.BigIntegerField(null=False, blank=False)
    image = models.ForeignKey(Image, on_delete=models.CASCADE, null=False, blank=False)
    confidence = models.FloatField(null=False, blank=False)
    detected_label = models.CharField(max_length=50, null=False, blank=False)
    source = models.CharField(max_length=10, null=False, blank=False, default='upload')

    class Meta:
        db_table = 'grading_gradingresult'
        ordering = ["-created_at"]