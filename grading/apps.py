from django.apps import AppConfig


class GradingConfig(AppConfig):
    default_auto_field = "django.db.models.BigAutoField"
    name = "grading"

    def ready(self):
        # 服务启动时加载模型
        from .utils.detector import Detector
        Detector()