<template>
  <div class="login-container">
    <h2>用户登录</h2>
    <form @submit.prevent="handleLogin">
      <div>
        <label>用户名：</label>
        <input v-model="username" type="text" required>
      </div>
      <div>
        <label>密码：</label>
        <input v-model="password" type="password" required>
      </div>
      <button type="submit">登录</button>
    </form>
    <div class="register-link">
      没有账号？<router-link to="/register">去注册</router-link>
    </div>
  </div>
</template>

<script>
import axios from 'axios';

export default {
  data() {
    return {
      username: '',
      password: '',
      isLoggedIn: false
    };
  },
  mounted() {
    this.isLoggedIn = !!localStorage.getItem('token');
  },
  methods: {
    async handleLogin() {
      try {
        const response = await axios.post('http://127.0.0.1:8000/api/users/login/', {
          username: this.username,
          password: this.password
        });

        if (response.status === 200) {
          // 保存 token
          localStorage.setItem('token', response.data.token);

          // 存储包含 is_superuser 的用户对象
          localStorage.setItem('user', JSON.stringify({
            username: response.data.username,
            is_superuser: response.data.is_superuser, // 管理员标志
            user_id: response.data.user_id
          }));

          // 调试输出
          console.log('登录用户信息:', {
            username: response.data.username,
            is_superuser: response.data.is_superuser
          })

          this.$router.push('/main');
        } else {
          console.error('登录失败:', response.data.error);
        }
      } catch (error) {
        console.error('登录请求失败:', error);
        if (error.response?.status === 401) {
          alert('用户名或密码错误，请重试！');
        } else {
          alert('登录失败，请检查网络连接！');
        }
      }
    }
  }
};
</script>

<style scoped>
.login-container {
  max-width: 300px;
  margin: 50px auto;
  padding: 20px;
  border: 1px solid #e0e0e0;
  border-radius: 8px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
  background-color: #fff;
}

h2 {
  text-align: center;
  margin-bottom: 20px;
  color: #2c3e50;
}

div {
  margin-bottom: 15px;
}

label {
  display: block;
  margin-bottom: 5px;
  font-weight: 500;
  color: #555;
}

input {
  width: 100%;
  padding: 10px;
  box-sizing: border-box;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 14px;
  transition: border-color 0.3s;
}

input:focus {
  border-color: #42b983;
  outline: none;
  box-shadow: 0 0 0 2px rgba(66, 185, 131, 0.2);
}

button {
  width: 100%;
  padding: 12px;
  background-color: #42b983;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 16px;
  font-weight: 600;
  transition: background-color 0.3s;
}

button:hover {
  background-color: #3aa976;
}

button:active {
  background-color: #329567;
}

.register-link {
  text-align: center;
  margin-top: 20px;
  font-size: 14px;
  color: #666;
}

.register-link a {
  color: #42b983;
  text-decoration: none;
  font-weight: 500;
  cursor: pointer;
  transition: color 0.2s;
}

.register-link a:hover {
  color: #3aa976;
  text-decoration: underline;
}
</style>