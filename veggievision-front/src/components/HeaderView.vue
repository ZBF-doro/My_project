<template>
  <header class="app-header">
    <h1 class="system-title">果蔬智能分级系统</h1>
    <div class="header-middle">
      <router-link to="/main" class="header-link">首页</router-link>
      <router-link to="/main/fruit-grading" class="header-link">水果分级</router-link>
      <router-link to="/main/vegetable-grading" class="header-link">蔬菜分级</router-link>
      <router-link to="/main/grading/results" class="header-link">分级记录</router-link>
      <router-link to="/main/user-management" class="header-link">用户管理</router-link>
    </div>
    <div class="header-right">
      <span class="user-info">当前用户: {{ userInfo.username || '未登录用户' }} - {{ userRole }}</span>
      <button class="logout-btn" @click="handleLogout">退出</button>
    </div>
  </header>
</template>

<script>
export default {
  data() {
    return {
      showDebug: true // 上线时设为false
    }
  },
  computed: {
    userInfo() {
      const userStr = localStorage.getItem('user') || '{}';
      return JSON.parse(userStr);
    },
    userRole() {
      return this.userInfo.is_superuser ? '管理员' : '普通用户';
    }
  },
  methods: {
    async handleLogout() {
      try {
        const response = await fetch('/api/users/logout/', {
          method: 'POST',
          headers: {
            'Authorization': `Token ${localStorage.getItem('token')}`,
            'Content-Type': 'application/json'
          }
        });

        const data = await response.json();
        if (response.ok) {
          localStorage.removeItem('user');
          localStorage.removeItem('token');
          this.$router.push('/login');
        } else {
          console.error('退出失败:', data.error);
        }
      } catch (error) {
        console.error('退出时发生错误:', error);
      }
    }
  }
};
</script>

<style scoped>
.app-header {
  display: flex;
  align-items: center;
  height: 60px;
  background: #f8f9fa;
  padding: 0 24px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.system-title {
  color: #2c3e50;
  font-size: 20px;
}

.header-middle {
  display: flex;
  gap: 24px;
  margin: 0 auto;
}

.header-link {
  color: #333;
  text-decoration: none;
  padding: 4px 8px;
  transition: color 0.3s;
}

.header-link:hover {
  color: #42b983;
}

.header-right {
  display: flex;
  gap: 12px;
  align-items: center;
}

.user-info {
  color: #6c757d;
  font-size: 14px;
}

.logout-btn {
  background-color: #dc3545;
  color: white;
  border: none;
  padding: 3px 8px;
  cursor: pointer;
  border-radius: 4px;
  transition: background-color 0.3s;
}

.logout-btn:hover {
  background-color: #c82333;
}

span[v-if] {
  font-size: 12px;
  color: #999;
  margin-left: 8px;
}
</style>