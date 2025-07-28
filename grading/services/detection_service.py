class DetectionPipeline:
    def __init__(self):
        self.preprocessor = ImagePreprocessor()
        self.detector = Detector()

    def process_upload(self, uploaded_file):
        """完整处理流程：上传→预处理→检测→结果"""
        try:
            # 执行预处理
            img_path = self.preprocessor.process(uploaded_file)

            # 执行检测
            results = self.detector.predict(img_path)

            return {
                "status": "success",
                "image_path": img_path,
                "detections": results
            }
        except Exception as e:
            return {
                "status": "error",
                "message": str(e)
            }