import os
import time
import cv2
import uuid
from datetime import datetime
from django.core.files.storage import FileSystemStorage
from django.conf import settings
import logging
from contextlib import contextmanager

logger = logging.getLogger(__name__)


class ImagePreprocessor:
    def __init__(self):
        self.fs = FileSystemStorage(location=settings.MEDIA_ROOT)
        self.target_size = (640, 640)  # 统一模型输入尺寸
        self.temp_prefix = "tmp_"

    @contextmanager
    def _managed_tempfile(self, stream):
        """上下文管理器确保临时文件清理"""
        temp_path = None
        try:
            temp_path = self._save_temp(stream)
            yield temp_path
        except Exception as e:
            logger.error(f"临时文件管理异常: {str(e)}")
            raise
        finally:
            if temp_path and os.path.exists(temp_path):
                self._safe_remove(temp_path)
                logger.debug(f"临时文件已清理: {temp_path}")

    def process(self, img_stream, user_id):
        """图像处理主流程（接收用户ID，返回持久化相对路径）"""
        try:
            with self._managed_tempfile(img_stream) as temp_path:
                # 读取原始图像（BGR格式）
                raw_img = self._read_image(temp_path)
                # 标准化处理（保持BGR格式，避免颜色通道错误）
                processed_img = self._standardize(raw_img)
                # 生成持久化路径并保存
                save_path = self._generate_persistent_path(user_id)
                # 显式转换为BGR格式（OpenCV默认BGR，避免颜色异常）
                cv2.imwrite(save_path, cv2.cvtColor(processed_img, cv2.COLOR_RGB2BGR))
                logger.info(f"图片持久化成功，路径: {save_path}")
                return os.path.relpath(save_path, settings.MEDIA_ROOT)
        except Exception as e:
            logger.error(f"图像处理失败: {str(e)}", exc_info=True)
            raise RuntimeError(f"图像处理失败: {str(e)}")

    def _standardize(self, img):
        """标准化处理（保持BGR格式，避免颜色通道错误）"""
        try:
            h, w = img.shape[:2]
            # 计算缩放比例（保持宽高比）
            scale = min(self.target_size[0] / h, self.target_size[1] / w)
            new_h, new_w = int(h * scale), int(w * scale)

            # 缩放图像
            resized = cv2.resize(img, (new_w, new_h), interpolation=cv2.INTER_LINEAR)

            # 填充至目标尺寸（640x640）
            top = (self.target_size[0] - new_h) // 2
            bottom = self.target_size[0] - new_h - top
            left = (self.target_size[1] - new_w) // 2
            right = self.target_size[1] - new_w - left
            padded = cv2.copyMakeBorder(
                resized, top, bottom, left, right,
                cv2.BORDER_CONSTANT, value=(114, 114, 114)  # BGR填充色
            )

            # 转换为RGB格式（供模型推理使用）
            return cv2.cvtColor(padded, cv2.COLOR_BGR2RGB)
        except cv2.error as e:
            logger.error(f"OpenCV操作失败: {str(e)}（图像尺寸: {img.shape}）")
            raise
        except Exception as e:
            logger.error(f"标准化异常: {str(e)}", exc_info=True)
            raise

    def _save_temp(self, stream):
        file_ext = os.path.splitext(stream.name)[1].lower()
        if file_ext not in ['.jpg', '.jpeg', '.png']:
            logger.warning(f"拒绝非支持类型文件: {stream.name}（类型: {file_ext}）")
            raise ValueError(f"不支持的文件类型: {file_ext}")

        temp_name = f"{self.temp_prefix}{uuid.uuid4()}{file_ext}"

        # 保存文件并获取完整路径
        relative_path = self.fs.save(temp_name, stream)
        absolute_path = self.fs.path(relative_path)  # 关键修复：获取绝对路径

        logger.debug(f"临时文件保存成功: {absolute_path}")
        return absolute_path  # 返回绝对路径

    def _read_image(self, path):
        """读取图像（增强错误排查）"""
        img = cv2.imread(path, cv2.IMREAD_COLOR)  # 显式读取彩色图像
        if img is None:
            # 读取文件头辅助排查
            with open(path, 'rb') as f:
                header = f.read(100).hex()
            logger.error(f"图像解码失败，文件头: {header}（路径: {path}）")
            raise ValueError("无效的图像文件或损坏")
        return img

    def _generate_persistent_path(self, user_id):
        date_dir = datetime.now().strftime("%Y%m%d")
        filename = f"{uuid.uuid4()}.jpg"
        # 构建相对路径
        relative_dir = os.path.join('grading_images', str(user_id), date_dir)
        relative_path = os.path.join(relative_dir, filename)

        # 构建绝对路径并创建目录
        full_path = os.path.join(settings.MEDIA_ROOT, relative_path)
        os.makedirs(os.path.dirname(full_path), exist_ok=True)

        return relative_path  # 返回相对路径

    def _safe_remove(self, path):
        """安全删除文件（增强重试和权限处理）"""
        max_retries = 3
        for retry in range(max_retries):
            try:
                if os.path.exists(path):
                    os.remove(path)
                    logger.info(f"文件删除成功: {path}")
                return
            except PermissionError:
                logger.warning(f"删除文件权限不足（重试 {retry + 1}/{max_retries}）: {path}")
                time.sleep(0.2)
            except Exception as e:
                logger.error(f"删除文件异常: {path} - {str(e)}")
                if retry == max_retries - 1:
                    raise

    def cleanup_legacy_files(self):
        """清理24小时前的临时文件"""
        try:
            cutoff = time.time() - 24 * 3600  # 24小时前的时间戳
            for fname in os.listdir(settings.MEDIA_ROOT):
                if not fname.startswith(self.temp_prefix):
                    continue
                path = os.path.join(settings.MEDIA_ROOT, fname)
                if not os.path.isfile(path):
                    continue
                if os.path.getmtime(path) < cutoff:
                    self._safe_remove(path)
            logger.info("旧临时文件清理完成")
        except Exception as e:
            logger.error(f"清理旧文件失败: {str(e)}", exc_info=True)