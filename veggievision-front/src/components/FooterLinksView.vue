<template>
  <footer class="app-footer">
    <div class="footer-left">
      <router-link to="/register-superuser">成为管理员</router-link>
    </div>
    <div class="footer-right">
      <a href="#" @click.prevent="goToAdmin">后台管理</a>
    </div>
  </footer>
</template>

<script>
export default {
  methods: {
    goToAdmin() {
      window.open('http://127.0.0.1:8000/admin/', '_blank'); // 后台地址
    }
  }
};
</script>

<style scoped>
.app-footer {
  background: #e0e0e0; /* 灰色背景 */
  padding: 15px 24px; /* 增加左右内边距，避免内容贴边 */
  display: flex;
  justify-content: space-between; /* 左右内容分离 */
  margin-top: auto;
  font-size: 14px;
  border-top: 1px solid #dcdfe6;
}

.footer-left,
.footer-right {
  color: #495057;
}

.app-footer a {
  text-decoration: none;
  transition: color 0.3s;
}

.app-footer a:hover {
  color: #42b983;
}
</style>