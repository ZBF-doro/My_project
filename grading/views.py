import os
import time
import cv2
import uuid
import numpy as np
import torch
import base64
import logging
from datetime import datetime
from django.conf import settings
from rest_framework.parsers import MultiPartParser
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status, permissions
from django.utils import timezone
from django.contrib.auth import get_user_model
from .models import Image, GradingResult
from ultralytics import YOLO
from rest_framework.permissions import IsAuthenticated
from rest_framework.authentication import TokenAuthentication

# 导入工具类
from .utils.image_processor import ImagePreprocessor
from .utils.image_saver import ImageSaver

logger = logging.getLogger(__name__)
User = get_user_model()

FRUIT_EN_TO_CN = {
    'apple_qualified': '苹果_合格',
    'apple_disqualified': '苹果_不合格',
    'apricot_qualified': '杏_合格',
    'apricot_disqualified': '杏_不合格',
    'banana_qualified': '香蕉_合格',
    'banana_disqualified': '香蕉_不合格',
    'bell_pepper_qualified': '甜椒_合格',
    'bell_pepper_disqualified': '甜椒_不合格',
    'bitter_gourd_qualified': '苦瓜_合格',
    'bitter_gourd_disqualified': '苦瓜_不合格',
    'broccoli_qualified': '西兰花_合格',
    'broccoli_disqualified': '西兰花_不合格',
    'cabbage_qualified': '卷心菜_合格',
    'cabbage_disqualified': '卷心菜_不合格',
    'carrot_qualified': '胡萝卜_合格',
    'carrot_disqualified': '胡萝卜_不合格',
    'cauliflower_qualified': '花椰菜_合格',
    'cauliflower_disqualified': '花椰菜_不合格',
    'corn_qualified': '玉米_合格',
    'corn_disqualified': '玉米_不合格',
    'cucumber_qualified': '黄瓜_合格',
    'cucumber_disqualified': '黄瓜_不合格',
    'durian_qualified': '榴莲_合格',
    'durian_disqualified': '榴莲_不合格',
    'eggplant_qualified': '茄子_合格',
    'eggplant_disqualified': '茄子_不合格',
    'grape_qualified': '葡萄_合格',
    'grape_disqualified': '葡萄_不合格',
    'hot_pepper_qualified': '辣椒_合格',
    'hot_pepper_disqualified': '辣椒_不合格',
    'kiwi_qualified': '猕猴桃_合格',
    'kiwi_disqualified': '猕猴桃_不合格',
    'lemon_qualified': '柠檬_合格',
    'lemon_disqualified': '柠檬_不合格',
    'mango_qualified': '芒果_合格',
    'mango_disqualified': '芒果_不合格',
    'onion_qualified': '洋葱_合格',
    'onion_disqualified': '洋葱_不合格',
    'orange_qualified': '橘子_合格',
    'orange_disqualified': '橘子_不合格',
    'papaya_qualified': '木瓜_合格',
    'papaya_disqualified': '木瓜_不合格',
    'peach_qualified': '桃子_合格',
    'peach_disqualified': '桃子_不合格',
    'pear_qualified': '梨_合格',
    'pear_disqualified': '梨_不合格',
    'persimmon_qualified': '柿子_合格',
    'persimmon_disqualified': '柿子_不合格',
    'pineapple_qualified': '菠萝_合格',
    'pineapple_disqualified': '菠萝_不合格',
    'plum_qualified': '李子_合格',
    'plum_disqualified': '李子_不合格',
    'pomegranate_qualified': '石榴_合格',
    'pomegranate_disqualified': '石榴_不合格',
    'potato_qualified': '土豆_合格',
    'potato_disqualified': '土豆_不合格',
    'pumpkin_qualified': '南瓜_合格',
    'pumpkin_disqualified': '南瓜_不合格',
    'radish_qualified': '萝卜_合格',
    'radish_disqualified': '萝卜_不合格',
    'strawberry_qualified': '草莓_合格',
    'strawberry_disqualified': '草莓_不合格',
    'tomato_qualified': '番茄_合格',
    'tomato_disqualified': '番茄_不合格',
    'watermelon_qualified': '西瓜_合格',
    'watermelon_disqualified': '西瓜_不合格'
}


# 检测器类
class Detector:
    def __init__(self):
        self.model = YOLO(settings.MODEL_PATHS['DETECTION_MODEL'])
        self.model.to(settings.DEVICE).eval()
        with open(settings.MODEL_PATHS['CLASS_NAMES']) as f:
            self.classes = [line.strip() for line in f if line.strip()]
        self.input_size = (640, 640)

    def predict(self, img):
        results = self.model(img, imgsz=self.input_size, conf=0.3)
        return self._parse_output(results)

    def _parse_output(self, results):
        detections = []
        for result in results:
            for box in result.boxes:
                if box.conf.item() < 0.3:
                    continue
                class_id = int(box.cls.item())
                if 0 <= class_id < len(self.classes):
                    detections.append({
                        'class': self.classes[class_id],
                        'confidence': round(box.conf.item(), 4),
                        'bbox': box.xyxy[0].tolist()
                    })
        return detections


# 初始化全局检测器实例
detector_instance = Detector()


# ImageUploadAPIView类
class ImageUploadAPIView(APIView):
    parser_classes = [MultiPartParser]
    permission_classes = [IsAuthenticated]

    def post(self, request):
        if 'image' not in request.FILES:
            return Response({"error": "未上传图片"}, status=status.HTTP_400_BAD_REQUEST)

        image_file = request.FILES['image']
        user_id = request.user.id

        try:
            # 使用 ImageSaver 保存图片（返回相对路径）
            image_saver = ImageSaver()
            saved_path_rel = image_saver.save_image(image_file, user_id)

            # 获取原始URL
            original_url = request.data.get('original_url', '')

            # 保存图片元数据到数据库
            image = Image.objects.create(
                user_id=user_id,
                image_file=saved_path_rel,  # 存储相对路径到数据库
                upload_time=timezone.now(),
                image_name=image_file.name,
            )

            return Response({
                "message": "图片保存成功",
                "image_id": image.id,
                "image_url": image.image_file.url  # Django自动生成完整URL
            }, status=status.HTTP_201_CREATED)

        except Exception as e:
            logger.error(f"图片保存失败: {str(e)}", exc_info=True)
            return Response({"error": f"图片保存失败: {str(e)}"}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


# 分级检测接口（使用 ImagePreprocessor 处理图片）
class GradingAPIView(APIView):
    parser_classes = [MultiPartParser]
    permission_classes = [IsAuthenticated]

    def post(self, request):
        image_id = request.data.get('image_id')
        image_file = request.FILES.get('image')

        # 检查是否有有效的输入
        if not image_id and not image_file:
            return Response({"error": "请上传图片或提供图片ID"}, status=status.HTTP_400_BAD_REQUEST)

        try:
            # 情况1：通过image_id检测
            if image_id:
                return self._grade_by_image_id(request, image_id)

            # 情况2：通过上传的图片文件检测
            return self._grade_by_uploaded_file(request)

        except Exception as e:
            logger.error(f"分级失败: {str(e)}", exc_info=True)
            return Response({"error": f"分级失败: {str(e)}"}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

    def _grade_by_uploaded_file(self, request):
        """处理直接上传图片文件的情况"""
        image_file = request.FILES['image']
        user_id = request.user.id
        preprocessor = ImagePreprocessor()

        saved_path_rel = preprocessor.process(image_file, user_id)
        saved_path = os.path.join(settings.MEDIA_ROOT, saved_path_rel.replace('\\', '/'))
        saved_path = os.path.abspath(saved_path)
        detections = detector_instance.predict(saved_path)

        if not detections:
            return Response({"error": "未检测到目标"}, status=status.HTTP_400_BAD_REQUEST)

        best_det = max(detections, key=lambda x: x['confidence'])
        detected_class = best_det['class']
        fruit_en = detected_class.split('_')[0]

        chinese_fruit = "未知"
        for key in FRUIT_EN_TO_CN.keys():
            if key.startswith(fruit_en + '_'):
                chinese_fruit = FRUIT_EN_TO_CN[key].split('_')[0]
                break

        final_grade = self._parse_grade(detected_class)

        image = Image.objects.create(
            user_id=user_id,
            image_file=saved_path_rel,
            upload_time=timezone.now(),
            image_name=image_file.name,
        )

        GradingResult.objects.create(
            user_id=user_id,
            image=image,
            detected_label=detected_class,
            final_grade=final_grade,
            confidence=best_det['confidence'],
            source=request.data.get('source', 'upload'),
            created_at=timezone.now()
        )

        return Response({
            "message": "分级成功",
            "result": {
                "品种": chinese_fruit,
                "等级": final_grade,
                "置信度": f"{best_det['confidence'] * 100:.2f}%",
                "检测时间": timezone.now().strftime("%Y-%m-%d %H:%M:%S"),
                "image_url": image.image_file.url
            }
        }, status=status.HTTP_200_OK)

    def _grade_by_image_id(self, request, image_id):
        """处理通过image_id检测的情况"""
        try:
            image = Image.objects.get(id=image_id, user_id=request.user.id)
        except Image.DoesNotExist:
            return Response({"error": "图片不存在或无权访问"}, status=status.HTTP_404_NOT_FOUND)

        # 构建图片绝对路径
        image_path = os.path.join(settings.MEDIA_ROOT, image.image_file.name)
        image_path = os.path.abspath(image_path)

        detections = detector_instance.predict(image_path)
        if not detections:
            return Response({"error": "未检测到目标"}, status=status.HTTP_400_BAD_REQUEST)

        best_det = max(detections, key=lambda x: x['confidence'])
        detected_class = best_det['class']
        fruit_en = detected_class.split('_')[0]

        chinese_fruit = "未知"
        for key in FRUIT_EN_TO_CN.keys():
            if key.startswith(fruit_en + '_'):
                chinese_fruit = FRUIT_EN_TO_CN[key].split('_')[0]
                break

        final_grade = self._parse_grade(detected_class)

        # 保存检测结果
        GradingResult.objects.create(
            user_id=request.user.id,
            image=image,
            detected_label=detected_class,
            final_grade=final_grade,
            confidence=best_det['confidence'],
            source=request.data.get('source', 'upload'),
            created_at=timezone.now()
        )

        return Response({
            "message": "分级成功",
            "result": {
                "品种": chinese_fruit,
                "等级": final_grade,
                "置信度": f"{best_det['confidence'] * 100:.2f}%",
                "检测时间": timezone.now().strftime("%Y-%m-%d %H:%M:%S"),
                "image_url": image.image_file.url
            }
        }, status=status.HTTP_200_OK)

    def _parse_grade(self, detected_class):
        if "disqualified" in detected_class:
            return "不合格"  # 优先判断不合格，避免逻辑覆盖
        elif "qualified" in detected_class:
            return "合格"
        return "未知"


# ====== 分级历史查询接口 ======
class GradingHistoryView(APIView):
    authentication_classes = [TokenAuthentication]
    permission_classes = [IsAuthenticated]

    def get(self, request):
        try:
            # 关联查询用户分级历史记录
            history = GradingResult.objects.filter(
                user_id=request.user.id
            ).select_related('image').order_by('-created_at')

            data = []
            for item in history:
                # 返回前端需要的数据结构
                data.append({
                    "id": item.id,
                    "image_file": item.image.image_file.name,  # 相对路径
                    "detected_label": item.detected_label,    # 原始检测标签
                    "final_grade": item.final_grade,
                    "confidence": float(item.confidence),      # 转换为浮点数
                    "created_at": item.created_at.isoformat()  # ISO格式时间
                })

            return Response(data, status=status.HTTP_200_OK)

        except Exception as e:
            logger.error(f"分级历史查询失败: {str(e)}")
            return Response({"error": "服务器内部错误"}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


class DetectionView(APIView):
    parser_classes = [MultiPartParser]
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        if 'image' not in request.FILES:
            return Response({"error": "未上传图片"}, status=status.HTTP_400_BAD_REQUEST)

        img_file = request.FILES['image']
        img = cv2.imdecode(np.frombuffer(img_file.read(), np.uint8), cv2.IMREAD_COLOR)
        if img is None:
            return Response({"error": "图片解码失败"}, status=status.HTTP_400_BAD_REQUEST)

        detections = detector_instance.predict(img)
        if not detections:
            return Response({"error": "未检出目标"}, status=status.HTTP_400_BAD_REQUEST)

        best_det = max(detections, key=lambda x: x['confidence'])
        detected_label = best_det['class']

        try:
            fruit_en, grade_status = detected_label.split('_', 1)
        except:
            fruit_en, grade_status = detected_label, 'unknown'
        chinese_fruit = FRUIT_EN_TO_CN.get(fruit_en, '未知果蔬')
        final_grade = f"{chinese_fruit}_{'合格' if grade_status == 'qualified' else '不合格'}"

        return Response({
            "message": "检测成功",
            "result": {
                "detected_class": detected_label,
                "final_grade": final_grade,
                "confidence": best_det['confidence'],
                "bbox": best_det['bbox']
            }
        })


class SystemStatsAPI(APIView):
    def get(self, request):
        try:
            User = get_user_model()
            return Response({
                'total_grading': GradingResult.objects.count(),
                'total_users': User.objects.count()
            })
        except:
            return Response({'error': '获取统计数据失败'}, status=500)


class RealTimeDetectionAPI(APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        try:
            base64_frame = request.data.get('frame')
            if not base64_frame:
                return Response({"error": "无帧数据"}, status=400)

            # 解码Base64帧数据为图像数组
            nparr = np.frombuffer(base64.b64decode(base64_frame), np.uint8)
            img_np = cv2.imdecode(nparr, cv2.IMREAD_COLOR)

            # 执行实时检测
            detections = detector_instance.predict(img_np)

            if not detections:
                return Response({
                    "status": "no_detections",
                    "message": "未检测到目标（尝试调整角度或光线）",
                }, status=200)

            best_det = max(detections, key=lambda x: x['confidence'])
            return Response({
                "status": "success",
                "detected_class": best_det['class'],
                "confidence": best_det['confidence'],
                "bbox": best_det['bbox'],
            }, status=200)
        except Exception as e:
            logger.error(f"实时检测错误：{e}", exc_info=True)
            return Response({"error": "服务器错误"}, status=500)