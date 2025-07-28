from rest_framework import serializers
from .models import GradingResult

class GradingResultSerializer(serializers.ModelSerializer):
    class Meta:
        model = GradingResult
        fields = ('id', 'image', 'detected_label', 'final_grade', 'confidence', 'created_at')
        extra_kwargs = {
            'created_at': {'format': '%Y-%m-%d %H:%M:%S'}  # 匹配前端时间格式
        }