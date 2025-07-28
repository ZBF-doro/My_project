<template>
  <div class="grading-history">
    <h2>我的分级结果</h2>

    <!-- 加载状态指示器 -->
    <div v-if="loading" class="loading">
      <div class="loader"></div>
      <p>正在加载分级记录...</p>
    </div>

    <!-- 数据展示区域 -->
    <div v-else>
      <table v-if="gradingHistory && gradingHistory.length > 0">
        <thead>
          <tr>
            <th>序号</th>
            <th>检测图片</th>
            <th>品种</th>
            <th>等级</th>
            <th>置信度</th>
            <th>检测时间</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(item, index) in gradingHistory" :key="item.id">
            <td>{{ index + 1 }}</td>
            <td>
              <img
                :src="getFullImageUrl(item.image_file)"
                alt="检测图片"
                style="max-width: 100px;"
                @click="showImagePreview(item.image_file)"
              >
            </td>
            <td>
              {{ getFruitStatus(item.detected_label).fruit }}
              <span class="status-badge" :class="getFruitStatus(item.detected_label).statusClass">
                {{ getFruitStatus(item.detected_label).status }}
              </span>
            </td>
            <td>{{ item.final_grade || '未知' }}</td>
            <td>{{ (item.confidence * 100).toFixed(2) }}%</td>
            <td>{{ formatDateTime(item.created_at) }}</td>
          </tr>
        </tbody>
      </table>
      <p v-else>暂无分级记录</p>
    </div>

    <!-- 图片预览模态框 -->
    <div v-if="previewImageUrl" class="image-preview-modal" @click.self="previewImageUrl = null">
      <div class="modal-content">
        <img :src="getFullImageUrl(previewImageUrl)" alt="预览图片">
        <button @click="previewImageUrl = null">关闭</button>
      </div>
    </div>
  </div>
</template>

<script>
import axios from 'axios';

const FRUIT_EN_TO_CN = {
  'apple': '苹果',
  'apricot': '杏',
  'banana': '香蕉',
  'bell_pepper': '甜椒',
  'bitter_gourd': '苦瓜',
  'broccoli': '西兰花',
  'cabbage': '卷心菜',
  'carrot': '胡萝卜',
  'cauliflower': '花椰菜',
  'corn': '玉米',
  'cucumber': '黄瓜',
  'durian': '榴莲',
  'eggplant': '茄子',
  'grape': '葡萄',
  'hot_pepper': '辣椒',
  'kiwi': '猕猴桃',
  'lemon': '柠檬',
  'mango': '芒果',
  'onion': '洋葱',
  'orange': '橘子',
  'papaya': '木瓜',
  'peach': '桃子',
  'pear': '梨',
  'persimmon': '柿子',
  'pineapple': '菠萝',
  'plum': '李子',
  'pomegranate': '石榴',
  'potato': '土豆',
  'pumpkin': '南瓜',
  'radish': '萝卜',
  'strawberry': '草莓',
  'tomato': '西红柿',
  'watermelon': '西瓜'
};

export default {
  data() {
    return {
      loading: true,
      gradingHistory: [],
      previewImageUrl: null,
      defaultStatus: {
        fruit: '未知',
        status: '未知',
        statusClass: 'unknown'
      }
    };
  },
  mounted() {
    this.fetchHistory();
  },
  methods: {
    async fetchHistory() {
      const token = localStorage.getItem('token');
      this.loading = true;

      try {
        const response = await axios.get('/api/grading/grading-history/', {
          headers: { 'Authorization': `Token ${token}` }
        });

        this.gradingHistory = response.data;

      } catch (error) {
        console.error('获取分级记录失败:', error);
        this.gradingHistory = [];
        this.$notify({
          title: '错误',
          message: '获取分级记录失败，请稍后重试',
          type: 'error'
        });
      } finally {
        this.loading = false;
      }
    },

    getFruitStatus(detectedLabel) {
      if (!detectedLabel) return this.defaultStatus;

      // 处理英文标签格式（如"mango_disqualified"）
      if (detectedLabel.includes('_')) {
        const [fruitEn, statusEn] = detectedLabel.split('_');

        // 获取中文水果名称
        const chineseFruit = FRUIT_EN_TO_CN[fruitEn] || fruitEn;

        // 解析状态
        let statusText = '未知';
        let statusClass = 'unknown';

        if (statusEn === 'disqualified' || statusEn === 'unqualified') {
          statusText = '不合格';
          statusClass = 'unqualified';
        } else if (statusEn === 'qualified') {
          statusText = '合格';
          statusClass = 'qualified';
        }

        return {
          fruit: chineseFruit,
          status: statusText,
          statusClass: statusClass
        };
      }

      // 尝试从映射表中获取中文名称
      const chineseName = FRUIT_EN_TO_CN[detectedLabel];
      if (chineseName) {
        const [fruit, status] = chineseName.split('_');
        return {
          fruit: fruit || '未知',
          status: status || '未知',
          statusClass: status === '合格' ? 'qualified' :
                      status === '不合格' ? 'unqualified' : 'unknown'
        };
      }

      // 处理纯中文标签
      if (detectedLabel.includes('合格') || detectedLabel.includes('不合格')) {
        const statusText = detectedLabel.includes('合格') ? '合格' : '不合格';
        const fruitName = detectedLabel.replace(/(合格|不合格)/g, '').trim();

        return {
          fruit: fruitName || '未知',
          status: statusText,
          statusClass: statusText === '合格' ? 'qualified' : 'unqualified'
        };
      }

      return this.defaultStatus;
    },

    getFullImageUrl(relativePath) {
      if (!relativePath) return '';

      // 如果已经是完整URL则直接返回
      if (relativePath.startsWith('http://') || relativePath.startsWith('https://')) {
        return relativePath;
      }

      // 使用环境变量中的媒体URL
      const baseUrl = process.env.VUE_APP_MEDIA_URL || 'http://127.0.0.1:8000/media/';

      // 确保路径格式正确
      const cleanPath = relativePath.replace(/^\//, '');

      // 构建完整URL
      return `${baseUrl}${cleanPath}`;
    },

    formatDateTime(isoString) {
      if (!isoString) return '无日期';

      try {
        return new Date(isoString).toLocaleString('zh-CN');
      } catch (e) {
        return isoString;
      }
    },

    showImagePreview(imageUrl) {
      this.previewImageUrl = imageUrl;
    }
  }
};
</script>

<style scoped>
.grading-history {
  margin: 20px;
  position: relative;
  min-height: 300px;
}

table {
  width: 100%;
  border-collapse: collapse;
  margin-top: 15px;
}

th, td {
  border: 1px solid #ddd;
  padding: 8px;
  text-align: center;
}

th {
  background-color: #f2f2f2;
}

img {
  cursor: pointer;
  transition: transform 0.3s;
}

img:hover {
  transform: scale(1.05);
}

/* 状态徽章样式 */
.status-badge {
  display: inline-block;
  padding: 2px 6px;
  margin-left: 5px;
  border-radius: 4px;
  font-size: 12px;
  font-weight: bold;
}

.status-badge.qualified {
  background-color: #e6f7ff;
  color: #1890ff;
}

.status-badge.unqualified {
  background-color: #fff2f0;
  color: #f5222d;
}

.status-badge.unknown {
  background-color: #f5f5f5;
  color: #8c8c8c;
}

/* 图片预览模态框样式 */
.image-preview-modal {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-color: rgba(0, 0, 0, 0.8);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
}

.modal-content {
  max-width: 80%;
  max-height: 80%;
  position: relative;
}

.modal-content img {
  max-width: 100%;
  max-height: 80vh;
  display: block;
}

.modal-content button {
  position: absolute;
  top: 10px;
  right: 10px;
  background: #fff;
  border: none;
  padding: 5px 10px;
  cursor: pointer;
  border-radius: 3px;
}

/* 加载状态样式 */
.loading {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 40px 0;
  color: #666;
}

.loader {
  border: 5px solid #f3f3f3;
  border-top: 5px solid #3498db;
  border-radius: 50%;
  width: 50px;
  height: 50px;
  animation: spin 1s linear infinite;
  margin-bottom: 15px;
}

@keyframes spin {
  0% {
    transform: rotate(0deg);
  }
  100% {
    transform: rotate(360deg);
  }
}
</style>