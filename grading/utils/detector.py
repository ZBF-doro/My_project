import os
import torch
import cv2
import numpy as np
import yaml
from django.conf import settings
from ultralytics import YOLO


class Detector:
    _instance = None
    classes = []
    args = {}
    input_size = (640, 640)
    device = 'cuda' if torch.cuda.is_available() else 'cpu'

    def __new__(cls):
        if not cls._instance:
            cls._instance = super().__new__(cls)
            cls._initialize()
        return cls._instance

    @classmethod
    def _initialize(cls):
        class_names_path = settings.MODEL_PATHS['CLASS_NAMES']
        with open(class_names_path, 'r', encoding='utf-8') as f:
            cls.classes = [line.strip() for line in f if line.strip()]

        args_path = settings.MODEL_PATHS.get('ARGS_YAML')
        if args_path and os.path.exists(args_path):
            with open(args_path, 'r', encoding='utf-8') as f:
                cls.args = yaml.safe_load(f) or {}
                if 'input_size' in cls.args:
                    cls.input_size = tuple(cls.args['input_size'])

        model_path = settings.MODEL_PATHS['DETECTION_MODEL']
        if not os.path.exists(model_path):
            raise FileNotFoundError(f"模型文件不存在: {model_path}")
        cls.model = YOLO(model_path)
        cls.model.to(cls.device)
        cls.model.eval()

    def preprocess_realtime_frame(self, img):
        h, w = img.shape[:2]
        target_h, target_w = self.input_size
        scale = min(target_h / h, target_w / w)
        new_h, new_w = int(h * scale), int(w * scale)
        resized = cv2.resize(img, (new_w, new_h), interpolation=cv2.INTER_LINEAR)
        top = (target_h - new_h) // 2
        bottom = target_h - new_h - top
        left = (target_w - new_w) // 2
        right = target_w - new_w - left
        return cv2.copyMakeBorder(resized, top, bottom, left, right,
                                  cv2.BORDER_CONSTANT, value=(114, 114, 114))

    def predict(self, input_data):
        img = self._load_input(input_data)
        processed_img = self.preprocess_realtime_frame(img)
        results = self._inference(processed_img)
        return self._parse_output(results)

    def _load_input(self, input_data):
        if isinstance(input_data, str):
            return cv2.imread(input_data, cv2.IMREAD_COLOR)
        elif isinstance(input_data, np.ndarray):
            return input_data
        raise ValueError("不支持的输入类型")

    def _inference(self, img):
        return self.model(
            img,
            imgsz=self.input_size,
            conf=0.2,
            iou=0.5,
            max_det=1,
            device=self.device
        )

    @classmethod
    def _parse_output(cls, results):
        detections = []
        for result in results:
            model_names = result.names  # 直接从模型结果获取类别映射

            for box in result.boxes:
                conf = round(box.conf.item(), 4)
                class_id = int(box.cls.item())

                # 优先使用模型自带的类别映射
                if class_id in model_names:
                    class_name = model_names[class_id]
                elif 0 <= class_id < len(cls.classes):
                    # 备选：使用类变量加载的类别名称
                    class_name = cls.classes[class_id]
                else:
                    continue  # 无效类别ID，跳过

                detections.append({
                    'class': class_name,
                    'confidence': conf,
                    'bbox': [round(c.item(), 4) for c in box.xyxy[0]]
                })

        return detections