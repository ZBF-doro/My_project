<template>
  <div class="register-container">
    <h2>用户注册</h2>
    <form @submit.prevent="handleRegister">
      <div>
        <label>用户名：</label>
        <input v-model="username" type="text" required>
      </div>
      <div>
        <label>邮箱：</label>
        <input v-model="email" type="email" required>
      </div>
      <div>
        <label>电话：</label>
        <input
          v-model="phone"
          type="text"
          required
          pattern="^1[3-9]\d{9}$"
          title="请输入有效的手机号"
        >
      </div>
      <div>
        <label>密码：</label>
        <input v-model="password1" type="password" required>
      </div>
      <div>
        <label>确认密码：</label>
        <input v-model="password2" type="password" required>
      </div>
      <button type="submit">注册</button>
    </form>
  </div>
</template>

<script>
import axios from 'axios';
export default {
  data() {
    return {
      username: '',
      email: '',
      phone: '',
      password1: '',
      password2: ''
    };
  },
  methods: {
  async handleRegister() {
  // 前端验证
  if (this.password1 !== this.password2) {
    alert('两次输入的密码不一致，请重新输入');
    return;
  }
  if (!/^1[3-9]\d{9}$/.test(this.phone)) {
    alert('请输入有效的手机号');
    return;
  }

  try {
    const response = await axios.post('http://127.0.0.1:8000/api/users/register/', {
      username: this.username,
      email: this.email,
      phone: this.phone,
      password1: this.password1,
      password2: this.password2
    });

    // 成功响应处理
    if (response.status === 201) {  // 假设后端成功返回201状态码
      alert('注册成功，请登录');
      this.$router.push('/login');
    } else {
      // 错误响应处理
      let errorMsg = '注册失败';

      // 解析具体错误类型（中文）
      if (response.data.username) {
        errorMsg = response.data.username[0];  // 用户名重复错误
      } else if (response.data.password1 || response.data.password2) {
        errorMsg = '两次输入的密码不一致';  // 密码不一致错误
      } else if (response.data.email) {
        errorMsg = response.data.email[0];  // 邮箱格式错误
      } else if (response.data.detail) {
        errorMsg = response.data.detail;  // 其他后端提示
      }

      alert(errorMsg);
    }
  } catch (error) {
    console.error('请求失败:', error.response?.data || error.message);

    // 处理400错误（参数问题）
    if (error.response?.status === 400) {
      const errorData = error.response.data;
      let errorMsg = '注册失败';

      if (errorData.username) {
        errorMsg = errorData.username[0];  // 用户名重复
      } else if (errorData.password1 || errorData.password2) {
        errorMsg = '两次输入的密码不一致';  // 密码不一致
      } else if (errorData.email) {
        errorMsg = errorData.email[0];  // 邮箱错误
      } else if (errorData.non_field_errors) {
        errorMsg = errorData.non_field_errors[0];  // 其他全局错误
      }

      alert(errorMsg);
    } else {
      // 其他网络错误
      alert('注册失败，请检查网络或联系管理员');
    }
  }
}
  }
};
</script>

<style scoped>
.register-container {
  max-width: 350px;
  margin: 50px auto;
  padding: 20px;
  border: 1px solid #e0e0e0;
  border-radius: 8px;
}
div {
  margin-bottom: 15px;
}
label {
  display: block;
  margin-bottom: 5px;
}
input {
  width: 100%;
  padding: 8px;
  box-sizing: border-box;
  border: 1px solid #ccc;
  border-radius: 4px;
}
button {
  width: 100%;
  padding: 10px;
  background-color: #42b983;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}
</style>