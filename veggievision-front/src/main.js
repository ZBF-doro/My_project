import { createApp } from 'vue'
import App from './App.vue'
import router from './router'
import ElementPlus from 'element-plus'
import 'element-plus/dist/index.css'

// 1. 定义全局配置
const globalConfig = {
  mediaUrl: process.env.VUE_APP_MEDIA_URL || '/media/' // 优先从环境变量读取
}

// 2. 持久化到 localStorage
localStorage.setItem('globalConfig', JSON.stringify(globalConfig))

const app = createApp(App)

// 3. 挂载全局配置到 Vue 实例
app.config.globalProperties.$globalConfig = globalConfig

// 4. 应用初始化时尝试读取 localStorage 中的配置（覆盖环境变量）
const savedConfig = localStorage.getItem('globalConfig')
if (savedConfig) {
  try {
    const parsedConfig = JSON.parse(savedConfig)
    app.config.globalProperties.$globalConfig = {
      ...globalConfig,
      ...parsedConfig
    }
  } catch (e) {
    console.warn('解析本地存储的配置失败，使用环境变量配置')
  }
}

app.use(router)
app.use(ElementPlus)
app.mount('#app')