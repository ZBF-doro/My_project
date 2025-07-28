const { defineConfig } = require('@vue/cli-service')

module.exports = defineConfig({
  devServer: {
    port: 8081,
    hot: true,
    open: true,
    // 添加代理配置 👇
    proxy: {
      '/api': {
        target: 'http://localhost:8000',  // Django后端地址
        changeOrigin: true,
        pathRewrite: {
          '^/api': '/api'
        }
      }
    }
  },
  transpileDependencies: true,
  lintOnSave: false,
  chainWebpack: config => {
    config.module.rules.delete('eslint')
  }
})