from django.urls import path
from .views import (
    DetectionView, SystemStatsAPI, GradingAPIView,
    GradingHistoryView, RealTimeDetectionAPI, ImageUploadAPIView
)

urlpatterns = [
    path('detect/', DetectionView.as_view(), name='detect-api'),  # 基础检测接口（可能已废弃）
    path('api/system-stats/', SystemStatsAPI.as_view()),        # 系统统计接口
    path('image-upload/', ImageUploadAPIView.as_view()),       # 图片上传接口（核心）
    path('grading/', GradingAPIView.as_view()),                # 分级检测接口（核心）
    path('grading-history/', GradingHistoryView.as_view()),     # 分级历史查询接口
    path('realtime-detect/', RealTimeDetectionAPI.as_view()),  # 实时检测接口（若已删除实时功能可移除）
]