<template>
  <div class="register-container">
    <h2>管理员注册</h2>
    <form @submit.prevent="handleRegister">
      <div>
        <label>用户名：</label>
        <input v-model="formData.username" type="text" required>
      </div>
      <div>
        <label>邮箱：</label>
        <input v-model="formData.email" type="email" required>
      </div>
      <div>
        <label>电话：</label>
        <input
          v-model="formData.phone"
          type="tel"
          required
          pattern="^1[3-9]\d{9}$"
          title="请输入有效的手机号"
        >
      </div>
      <div>
        <label>密码：</label>
        <input v-model="formData.password" type="password" required>
      </div>
      <div>
        <label>确认密码：</label>
        <input v-model="formData.password_confirm" type="password" required>
      </div>
      <div>
        <label>邀请码：</label>
        <input v-model="formData.invitation_code" type="text" required>
      </div>
      <button type="submit">完成注册</button>
    </form>
  </div>
</template>

<script>
import { reactive } from 'vue';
import axios from 'axios';
import { useRouter } from 'vue-router';

export default {
  setup() {
    const router = useRouter();
    const formData = reactive({
      username: '',
      email: '',
      phone: '',
      password: '',
      password_confirm: '',
      invitation_code: '' // 与后端保持一致的字段名
    });

    // 获取CSRF令牌的函数
    const getCookie = (name) => {
      let cookieValue = null;
      if (document.cookie && document.cookie !== '') {
        const cookies = document.cookie.split(';');
        for (let i = 0; i < cookies.length; i++) {
          const cookie = cookies[i].trim();
          // 查找以name=开头的cookie
          if (cookie.substring(0, name.length + 1) === (name + '=')) {
            cookieValue = decodeURIComponent(cookie.substring(name.length + 1));
            break;
          }
        }
      }
      return cookieValue;
    };

    const handleRegister = async () => {
      // 前端验证
      if (formData.password !== formData.password_confirm) {
        alert('两次输入的密码不一致，请重新输入');
        return;
      }
      if (!/^1[3-9]\d{9}$/.test(formData.phone)) {
        alert('请输入有效的手机号');
        return;
      }

      try {
        // 设置CSRF令牌
        const csrftoken = getCookie('csrftoken');
        axios.defaults.headers.common['X-CSRFToken'] = csrftoken;

        const response = await axios.post(
          'http://127.0.0.1:8000/api/users/register-superuser/',
          {
            username: formData.username,
            email: formData.email,
            phone: formData.phone,
            password: formData.password,
            invitation_code: formData.invitation_code
          }
        );

        if (response.status === 201) {
          alert('注册成功，请登录');
          router.push('/login');
        } else {
          let errorMsg = '注册失败';
          const errorData = response.data;

          if (errorData.username) errorMsg = errorData.username[0];
          else if (errorData.email) errorMsg = errorData.email[0];
          else if (errorData.phone) errorMsg = errorData.phone[0];
          else if (errorData.password) errorMsg = errorData.password[0];
          else if (errorData.invitation_code) errorMsg = errorData.invitation_code[0];
          else if (errorData.non_field_errors) errorMsg = errorData.non_field_errors[0];

          alert(errorMsg);
        }
      } catch (error) {
        console.error('注册请求失败:', error);
        alert('注册失败，请检查网络或联系管理员');
      }
    };

    return { formData, handleRegister };
  }
}
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