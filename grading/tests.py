import os
from django.test import TestCase
from django.conf import settings
import logging

logger = logging.getLogger(__name__)


class MediaConfigTests(TestCase):
    def test_image_processor_permissions(self):
        """
        测试 ImagePreprocessor 是否能正确保存文件
        """
        from .utils.image_processor import ImagePreprocessor
        from django.core.files.uploadedfile import SimpleUploadedFile
        import numpy as np
        import cv2

        # 创建一个虚拟图片
        img_array = np.zeros((100, 100, 3), dtype=np.uint8)
        _, img_bytes = cv2.imencode('.jpg', img_array)
        img_content = img_bytes.tobytes()

        # 创建模拟上传文件
        uploaded_file = SimpleUploadedFile(
            name="test_image.jpg",
            content=img_content,
            content_type="image/jpeg"
        )

        # 使用预处理器
        preprocessor = ImagePreprocessor()
        try:
            logger.info(f"MEDIA_ROOT: {settings.MEDIA_ROOT}")
            relative_path = preprocessor.process(uploaded_file, "test_user")
            full_path = os.path.join(settings.MEDIA_ROOT, relative_path)

            # 验证文件是否创建
            self.assertTrue(os.path.exists(full_path))
            logger.info(f"图片处理器创建文件成功: {full_path}")

            # 检查文件内容
            img = cv2.imread(full_path)
            self.assertIsNotNone(img, "图片文件无法读取")
            self.assertEqual(img.shape, (640, 640, 3), "图片尺寸不正确")

            # 清理测试文件
            os.remove(full_path)
            logger.info("测试图片已清理")
        except Exception as e:
            logger.exception(f"图片处理器测试失败")  # 记录完整堆栈
            self.fail(f"图片处理器测试失败: {str(e)}")