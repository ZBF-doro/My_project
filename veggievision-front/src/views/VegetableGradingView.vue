<template>
  <div class="detection-page">
    <!-- 选项卡组件 -->
    <div class="mode-tabs">
      <button
        v-for="tab in tabs"
        :key="tab.id"
        :class="{ active: activeTab === tab.id }"
        @click="switchTab(tab.id)"
      >
        {{ tab.label }}
      </button>
    </div>
    <!-- 文件上传模式 -->
    <div v-if="activeTab === 'file'" class="file-section">
      <input
        type="file"
        ref="fileInput"
        accept="image/*"
        @change="handleFileUpload"
        hidden
      />
      <button
        class="upload-btn"
        @click="triggerFileSelect"
        :disabled="!isLoggedIn"
      >
        {{ selectedFile ? selectedFile.name : '选择图片' }}
        <span v-if="!isLoggedIn" class="upload-tip">请登录后使用</span>
      </button>
      <button
        v-if="uploadedImageId && isLoggedIn"
        class="detect-btn"
        @click="handleImageDetection"
        :disabled="isDetecting"
      >
        <span v-if="isDetecting">检测中...</span>
        <span v-else>开始检测</span>
      </button>
      <!-- 文件上传检测结果 -->
      <div v-if="detectionResult?.result" class="result-card">
        <img :src="previewImage" class="preview-img" />
        <div class="overlay-info">
          <span class="class-tag">{{ detectionResult.result.品种 }}</span>
          <!-- 精确匹配等级绑定类 -->
          <span
            class="grade-tag"
            :class="detectionResult.result.等级 === '合格' ? 'qualified' : 'disqualified'"
          >
            {{ detectionResult.result.等级 }}
          </span>
        </div>
        <div class="confidence-info">
          <div class="confidence-bar">
            <div class="fill" :style="{ width: detectionResult.result.置信度 }"></div>
          </div>
          <span class="confidence-value">{{ detectionResult.result.置信度 }}</span>
        </div>
        <div class="grade-info">
          <span class="grade-label">分级结果：</span>
          <!-- 精确匹配等级绑定类 -->
          <span
            class="grade-value"
            :class="detectionResult.result.等级 === '合格' ? 'qualified' : 'disqualified'"
          >
            {{ detectionResult.result.品种 }}_{{ detectionResult.result.等级 }}
          </span>
        </div>
      </div>
    </div>
    <!-- 拍摄上传模式 -->
    <div v-if="activeTab === 'camera'" class="camera-section">
      <video ref="videoElement" autoplay playsinline class="camera-preview"></video>
      <button
        v-if="isLoggedIn && cameraInitialized"
        class="capture-btn"
        @click="captureImage"
        :disabled="isCapturing"
      >
        <span v-if="isCapturing">拍摄中...</span>
        <span v-else>拍摄照片</span>
      </button>
      <!-- 拍摄检测结果 -->
      <div v-if="capturedResult?.result" class="result-card">
        <img :src="capturedPreview" class="preview-img" />
        <div class="overlay-info">
          <span class="class-tag">{{ capturedResult.result.品种 }}</span>
          <!-- 精确匹配等级绑定类 -->
          <span
            class="grade-tag"
            :class="capturedResult.result.等级 === '合格' ? 'qualified' : 'disqualified'"
          >
            {{ capturedResult.result.等级 }}
          </span>
        </div>
        <div class="confidence-info">
          <div class="confidence-bar">
            <div class="fill" :style="{ width: capturedResult.result.置信度 }"></div>
          </div>
          <span class="confidence-value">{{ capturedResult.result.置信度 }}</span>
        </div>
        <div class="grade-info">
          <span class="grade-label">分级结果：</span>
          <!-- 精确匹配等级绑定类 -->
          <span
            class="grade-value"
            :class="capturedResult.result.等级 === '合格' ? 'qualified' : 'disqualified'"
          >
            {{ capturedResult.result.品种 }}_{{ capturedResult.result.等级 }}
          </span>
        </div>
      </div>
    </div>
    <!-- 错误提示 -->
    <div v-if="errorMsg" class="error-msg">⚠️ {{ errorMsg }}</div>
  </div>
</template>

<script>
import axios from 'axios';

export default {
  data() {
    return {
      tabs: [
        { id: 'file', label: '文件上传' },
        { id: 'camera', label: '拍摄上传' }
      ],
      activeTab: 'file',
      selectedFile: null,
      previewImage: null,
      detectionResult: null,
      uploadedImageId: null,
      capturedPreview: null,
      capturedResult: null,
      capturedImageId: null,
      videoElement: null,
      canvasElement: null,
      cameraInitialized: false,
      errorMsg: '',
      isLoggedIn: false,
      isDetecting: false,
      isCapturing: false
    };
  },
  mounted() {
    this.updateLoginStatus();
  },
  watch: {
    $route() {
      this.updateLoginStatus();
    }
  },
  methods: {
    switchTab(tabId) {
      this.activeTab = tabId;
      if (tabId === 'camera') {
        // 使用 nextTick 确保 DOM 渲染完成后初始化摄像头
        this.$nextTick(() => this.initCamera());
      } else {
        this.stopCamera();
      }
    },
    triggerFileSelect() {
      this.$refs.fileInput.click();
    },
    async handleFileUpload(e) {
      const file = e.target.files[0];
      if (!file || !file.type.startsWith('image/')) {
        this.errorMsg = '仅支持JPG/PNG格式图片';
        return;
      }
      this.selectedFile = file;
      this.previewImage = URL.createObjectURL(file);
      this.uploadedImageId = await this.uploadImage(file);
    },
    async handleImageDetection() {
      if (!this.uploadedImageId) return;
      this.isDetecting = true;
      this.errorMsg = '';
      try {
        this.detectionResult = await this.detectImage(this.uploadedImageId);
      } catch (error) {
        this.handleError(error, '检测');
      } finally {
        this.isDetecting = false;
      }
    },
    async captureImage() {
      if (!this.isLoggedIn) return;
      this.isCapturing = true;
      this.errorMsg = '';
      try {
        if (!this.videoElement || !this.cameraInitialized) {
          this.errorMsg = '摄像头未初始化，请重试';
          return;
        }
        const canvas = document.createElement('canvas');
        canvas.width = this.videoElement.videoWidth;
        canvas.height = this.videoElement.videoHeight;
        canvas.getContext('2d').drawImage(this.videoElement, 0, 0);
        const blob = await new Promise(resolve => canvas.toBlob(resolve, 'image/jpeg', 0.8));
        this.capturedPreview = URL.createObjectURL(blob);
        this.capturedImageId = await this.uploadImage(blob, 'capture.jpg');
        this.capturedResult = await this.detectImage(this.capturedImageId);
      } catch (error) {
        this.handleError(error, '拍摄上传');
      } finally {
        this.isCapturing = false;
      }
    },
    async uploadImage(file, filename = 'upload.jpg') {
      const formData = new FormData();
      formData.append('image', file, filename);
      const token = localStorage.getItem('token');
      const response = await axios.post(
        'http://127.0.0.1:8000/api/grading/image-upload/',
        formData,
        {
          headers: {
            'Content-Type': 'multipart/form-data',
            ...(token && { Authorization: `Token ${token}` })
          },
          timeout: 10000
        }
      );
      return response.data.image_id;
    },
    async detectImage(imageId) {
      const formData = new FormData();
      formData.append('image_id', imageId);
      const token = localStorage.getItem('token');
      const response = await axios.post(
        'http://127.0.0.1:8000/api/grading/grading/',
        formData,
        {
          headers: {
            'Content-Type': 'multipart/form-data',
            ...(token && { Authorization: `Token ${token}` })
          },
          timeout: 10000
        }
      );
      return response.data;
    },
    initCamera() {
      this.videoElement = this.$refs.videoElement;
      if (!this.videoElement) {
        this.errorMsg = '摄像头组件未加载完成，请重试';
        return;
      }

      // 检查媒体设备是否可用
      if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) {
        this.errorMsg = '当前浏览器不支持摄像头功能';
        return;
      }

      navigator.mediaDevices.getUserMedia({ video: true })
        .then(stream => {
          this.videoElement.srcObject = stream;
          this.cameraInitialized = true;
        })
        .catch(err => {
          console.error('摄像头初始化失败:', err);
          // 区分不同错误类型
          if (err.name === 'NotAllowedError') {
            this.errorMsg = '请允许浏览器访问摄像头';
          } else if (err.name === 'NotFoundError') {
            this.errorMsg = '未检测到摄像头设备';
          } else if (err.name === 'NotReadableError') {
            this.errorMsg = '摄像头正在被其他应用使用';
          } else if (err.name === 'OverconstrainedError') {
            this.errorMsg = '摄像头参数不满足要求';
          } else {
            this.handleError(err, '摄像头初始化', '初始化失败，请重试');
          }
        });
    },
    stopCamera() {
      try {
        if (this.videoElement && this.cameraInitialized) {
          const stream = this.videoElement.srcObject;
          if (stream) {
            stream.getTracks().forEach(track => track.stop());
          }
          this.videoElement.srcObject = null;
          this.cameraInitialized = false;
        }
      } catch (error) {
        this.handleError(error, '关闭摄像头', '关闭摄像头失败');
      } finally {
        this.capturedPreview = null;
        this.capturedResult = null;
      }
    },
    updateLoginStatus() {
      this.isLoggedIn = !!localStorage.getItem('token');
    },
    handleError(error, operation, defaultMsg = '操作失败，请稍后重试') {
      console.error(`${operation}失败:`, error);
      if (error.response) {
        switch (error.response.status) {
          case 400:
            this.errorMsg = error.response.data.error || '请求参数错误';
            break;
          case 404:
            this.errorMsg = '图片不存在，请重新' + operation.toLowerCase();
            break;
          default:
            this.errorMsg = defaultMsg;
        }
      } else {
        this.errorMsg = defaultMsg;
      }
    }
  },
  beforeUnmount() {
    this.stopCamera();
    if (this.previewImage) URL.revokeObjectURL(this.previewImage);
    if (this.capturedPreview) URL.revokeObjectURL(this.capturedPreview);
  }
};
</script>

<style scoped>
/* 基础样式 */
.detection-page {
  max-width: 600px;
  margin: 2rem auto;
  padding: 1.5rem;
}

/* 选项卡样式 */
.mode-tabs {
  display: flex;
  gap: 1rem;
  margin-bottom: 2rem;
}
.mode-tabs button {
  flex: 1;
  padding: 1rem;
  border: 2px solid #e5e7eb;
  border-radius: 8px;
  background: #f8fafc;
  cursor: pointer;
  transition: all 0.3s;
}
.mode-tabs button.active {
  border-color: #3b82f6;
  background: #bfdbfe;
  color: #1e40af;
}

/* 按钮样式 */
.upload-btn,
.capture-btn,
.detect-btn {
  width: 100%;
  padding: 0.8rem 2rem;
  border: none;
  border-radius: 6px;
  color: white;
  cursor: pointer;
  margin: 1rem 0;
  transition: opacity 0.3s;
}
.upload-btn { background-color: #3b82f6; }
.capture-btn { background-color: #10b981; }
.detect-btn { background-color: #e53e3e; }
button:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

/* 结果卡片样式 */
.result-card {
  margin-top: 2rem;
  padding: 1.5rem;
  background: white;
  border-radius: 12px;
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.1);
}
.preview-img {
  width: 100%;
  height: 300px;
  object-fit: cover;
  border-radius: 8px;
  margin-bottom: 1rem;
}
.overlay-info {
  position: relative;
  margin-bottom: 1rem;
}
.class-tag {
  font-size: 1.1em;
  font-weight: 500;
}
.grade-tag {
  margin-left: 0.5rem;
  padding: 0.2rem 0.6rem;
  border-radius: 4px;
  color: white;
}

.detection-page .result-card .grade-tag.qualified,
.detection-page .result-card .grade-value.qualified {
  background-color: #10B981 !important;
  color: white !important;
}

.detection-page .result-card .grade-tag.disqualified,
.detection-page .result-card .grade-value.disqualified {
  background-color: #EF4444 !important;
  color: white !important;
}

.detection-page .grade-info .qualified {
  color: #10B981 !important;
}
.detection-page .grade-info .disqualified {
  color: #EF4444 !important;
}

.confidence-info {
  display: flex;
  align-items: center;
  gap: 1rem;
  margin: 1rem 0;
}
.confidence-bar {
  flex: 1;
  height: 8px;
  background: #e2e8f0;
  border-radius: 4px;
  overflow: hidden;
}
.confidence-bar .fill {
  height: 100%;
  background: #3b82f6;
  transition: width 0.3s ease;
}

.error-msg {
  color: #dc2626;
  background: #fee2e2;
  padding: 1rem;
  border-radius: 8px;
  margin-top: 1.5rem;
}

/* 摄像头预览样式 */
video.camera-preview {
  width: 100%;
  height: 300px;
  border-radius: 8px;
  background: #000;
  margin: 1rem 0;
}
</style>