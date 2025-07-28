<template>
  <div id="app">
    <router-view />
  </div>
</template>

<script>
export default {
  name: 'App',
   mounted() {
    // 调试代码：打印全局配置
    console.log('当前 mediaUrl:', this.$globalConfig.mediaUrl);
    console.log('LocalStorage 配置:', JSON.parse(localStorage.getItem('globalConfig')));
  }
}
</script>

<style>
body {
  margin: 0;
}
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
}
</style>