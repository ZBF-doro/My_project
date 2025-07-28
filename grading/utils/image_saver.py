import os
import uuid
from datetime import datetime
from django.conf import settings
from django.core.files.storage import FileSystemStorage
import logging

logger = logging.getLogger(__name__)

class ImageSaver:
    def __init__(self):
        self.fs = FileSystemStorage(location=settings.MEDIA_ROOT)
        self.base_dir = os.path.join('grading_images')  # 基础目录（使用正斜杠）

    def save_image(self, img_stream, user_id):
        try:
            # 生成日期目录（使用正斜杠分隔）
            date_dir = datetime.now().strftime("%Y%m%d")
            # 构建用户目录：grading_images/user_id/date_dir/
            user_dir = os.path.join(self.base_dir, str(user_id), date_dir)
            # 确保目录使用正斜杠（避免 Windows 反斜杠问题）
            user_dir = user_dir.replace('\\', '/')  # 强制转换为正斜杠
            # 生成唯一文件名并保留扩展名
            file_ext = os.path.splitext(img_stream.name)[1].lower() or '.jpg'
            filename = f"{uuid.uuid4()}{file_ext}"
            # 拼接相对路径（相对于 MEDIA_ROOT）
            relative_path = os.path.join(user_dir, filename).replace('\\', '/')  # 确保路径格式统一
            # 保存文件（Django 会自动处理路径创建）
            saved_name = self.fs.save(relative_path, img_stream)
            logger.info(f"图片保存成功，相对路径: {saved_name}")

            return saved_name  # 例如：grading_images/2/20250601/xxx.jpg
        except Exception as e:
            logger.error(f"图片保存失败: {str(e)}", exc_info=True)
            raise RuntimeError(f"图片保存失败: {str(e)}")