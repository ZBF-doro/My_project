<template>
  <div class="user-management-container">
    <div class="user-manage-wrapper">
      <h2 class="section-title">用户管理</h2>
      <button
        @click="fetchUsers"
        :disabled="isLoading"
        class="fetch-btn"
        :class="{ 'loading-disabled': isLoading }"
      >
        {{ isLoading? '加载中...' : '加载用户列表' }}
      </button>

      <div v-if="users.length" class="user-list-wrapper">
        <ul class="user-list">
          <li
            v-for="user in users"
            :key="user.id"
            class="user-item"
            :title="`用户ID：${user.id}`"
          >
            <div class="user-info">
              <div class="user-field">
                <span class="label">用户名：</span>{{ user.username }}
              </div>
              <div class="user-field">
                <span class="label">邮箱：</span>{{ user.email }}
              </div>
              <div class="user-field">
                <span class="label">电话：</span>{{ user.phone || '未填写' }}
              </div>
            </div>
            <div class="btn-group">
              <button
                @click="handleEdit(user.id)"
                class="edit-btn"
                :disabled="isLoading"
              >
                编辑
              </button>
              <button
                @click="handleDelete(user.id)"
                class="delete-btn"
                :disabled="isLoading"
              >
                删除
              </button>
            </div>
          </li>
        </ul>
      </div>

      <p v-else-if="!isLoading" class="no-data-tip">
        暂无用户数据，请点击按钮加载
      </p>
      <p v-else class="loading-tip">加载中，请稍候...</p>

      <!-- 编辑弹窗 -->
      <el-dialog
        v-model="editDialogVisible"
        title="编辑用户信息"
        width="400px"
        :before-close="handleDialogClose"
      >
        <el-form
          ref="editFormRef"
          :model="editForm"
          :rules="editRules"
          label-width="80px"
          class="edit-form"
        >
          <el-form-item label="用户名" prop="username">
            <el-input
              v-model="editForm.username"
              placeholder="请输入用户名"
              clearable
            ></el-input>
          </el-form-item>
          <el-form-item label="邮箱" prop="email">
            <el-input
              v-model="editForm.email"
              placeholder="请输入邮箱"
              clearable
            ></el-input>
          </el-form-item>
          <el-form-item label="电话" prop="phone">
            <el-input
              v-model="editForm.phone"
              placeholder="请输入电话"
              clearable
            ></el-input>
          </el-form-item>
        </el-form>
        <template #footer>
          <span class="dialog-footer">
            <el-button @click="editDialogVisible = false">取消</el-button>
            <el-button
              type="primary"
              @click="handleEditSubmit"
              :disabled="!editFormRef?.validate"
            >
              确认修改
            </el-button>
          </span>
        </template>
      </el-dialog>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import axios from 'axios'
import { ElMessage } from 'element-plus'

// 常量定义
const API_BASE_URL = 'http://127.0.0.1:8000'

// 状态管理
const users = ref([])
const isLoading = ref(false)
const editDialogVisible = ref(false)
const editForm = ref({ id: null, username: '', email: '', phone: '' })
const editFormRef = ref(null)

// 表单验证规则
const editRules = ref({
  username: [
    { required: true, message: '用户名不能为空', trigger: 'blur' },
    { min: 3, max: 20, message: '用户名长度3-20位', trigger: 'blur' }
  ],
  email: [
    { required: true, message: '邮箱不能为空', trigger: 'blur' },
    { type: 'email', message: '邮箱格式不正确', trigger: 'blur' }
  ],
  phone: [
    { required: true, message: '电话不能为空', trigger: 'blur' },
    { pattern: /^1[3-9]\d{9}$/, message: '请输入有效的手机号码', trigger: 'blur' }
  ]
})

// 统一错误处理
const handleError = (error, defaultMessage = '操作失败') => {
  console.error(error)
  const message = error.response?.data?.message || defaultMessage
  ElMessage.error(message)
}

// 权限验证工具函数，基于 is_superuser
const checkSuperPermission = () => {
  try {
    // 从 localStorage 获取用户对象
    const userData = JSON.parse(localStorage.getItem('user') || '{}')

    // 使用 is_superuser 字段判断管理员权限
    const isSuper = userData.is_superuser === true

    if (!isSuper) {
      ElMessage.error('需要管理员权限')
    }

    return isSuper
  } catch (e) {
    console.error('权限检查错误', e)
    ElMessage.error('用户信息解析失败')
    return false
  }
}

// 获取用户列表
const fetchUsers = async () => {
  if (!checkSuperPermission()) return
  if (isLoading.value) return

  isLoading.value = true
  try {
    const { data } = await axios.get(`${API_BASE_URL}/api/users/admin/users/`, {
      headers: { Authorization: `Token ${localStorage.getItem('token')}` }
    })
    users.value = data
  } catch (error) {
    handleError(error, '权限不足，获取用户列表失败！')
  } finally {
    isLoading.value = false
  }
}

// 删除用户
const handleDelete = async userId => {
  if (!checkSuperPermission()) return
  if (!confirm('确认删除该用户？')) return

  try {
    await axios.delete(`${API_BASE_URL}/api/users/admin/users/${userId}/`, {
      headers: { Authorization: `Token ${localStorage.getItem('token')}` }
    })
    users.value = users.value.filter(user => user.id !== userId)
    ElMessage.success('删除用户成功')
  } catch (error) {
    handleError(error, '删除用户失败')
  }
}

// 编辑用户
const handleEdit = async userId => {
  if (!checkSuperPermission()) return

  try {
    const { data } = await axios.get(
      `${API_BASE_URL}/api/users/admin/users/${userId}/`,
      { headers: { Authorization: `Token ${localStorage.getItem('token')}` } }
    )

    // 更新编辑表单数据
    editForm.value = {
      id: data.id,
      username: data.username,
      email: data.email,
      phone: data.phone
    }
    editDialogVisible.value = true
  } catch (error) {
    handleError(error, '获取编辑信息失败')
  }
}

// 提交编辑
const handleEditSubmit = async () => {
  if (!checkSuperPermission()) return
  if (!editFormRef.value) return

  try {
    await editFormRef.value.validate()

    await axios.put(
      `${API_BASE_URL}/api/users/admin/users/${editForm.value.id}/`,
      editForm.value,
      { headers: { Authorization: `Token ${localStorage.getItem('token')}` } }
    )

    ElMessage.success('用户信息修改成功')
    editDialogVisible.value = false
    await fetchUsers()
  } catch (error) {
    if (error.name!== 'ValidateError') {
      handleError(error, '用户信息修改失败')
    }
  }
}

// 关闭弹窗处理
const handleDialogClose = () => {
  editForm.value = { id: null, username: '', email: '', phone: '' }
  editFormRef.value?.resetFields()
}

// 初始化加载
onMounted(() => {
  // 调试输出当前用户权限信息
  const userData = JSON.parse(localStorage.getItem('user') || '{}')
  console.log('当前用户权限信息:', {
    username: userData.username,
    is_superuser: userData.is_superuser
  })

  if (checkSuperPermission()) {
    fetchUsers()
  }
})
</script>
<style scoped>
.user-management-container {
  padding: 20px;
  background-color: #f0f2f5;
  min-height: calc(100vh - 60px);
}

.user-manage-wrapper {
  max-width: 1200px;
  margin: 0 auto;
  background-color: white;
  border-radius: 12px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
  padding: 24px;
}

.section-title {
  text-align: center;
  margin-bottom: 24px;
  color: #1a1a1a;
  font-size: 24px;
  font-weight: 500;
  border-bottom: 2px solid #e4e7ed;
  padding-bottom: 12px;
}

.fetch-btn {
  display: block;
  margin: 0 auto 24px;
  padding: 12px 24px;
  background: #409eff;
  color: white;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  transition: transform 0.2s, box-shadow 0.2s;
  font-size: 16px;
  font-weight: 500;
}

.fetch-btn:hover:enabled {
  background: #2b8df0;
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(64, 158, 255, 0.2);
}

.fetch-btn:disabled {
  background: #e4e7ed;
  color: #909399;
  cursor: not-allowed;
  transform: none;
  box-shadow: none;
}

.user-list-wrapper {
  margin-top: 24px;
}

.user-list {
  list-style: none;
  padding: 0;
}

.user-item {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  padding: 16px 24px;
  margin: 12px 0;
  background: #f8f9fa;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
  transition: transform 0.2s, box-shadow 0.2s;
  min-height: 120px;
}

.user-item:hover {
  transform: translateX(4px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.user-info {
  display: flex;
  flex-direction: column;
  gap: 12px;
  align-items: flex-start;
}

.user-field {
  display: flex;
  gap: 12px;
  align-items: center;
}

.label {
  color: #606266;
  font-weight: 500;
  min-width: 80px;
  text-align: right;
}

.btn-group {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.edit-btn,
.delete-btn {
  padding: 8px 16px;
  background: #42b983;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  transition: background 0.3s;
  font-size: 14px;
  width: 80px;
}

.delete-btn {
  background: #ff4949;
}

.edit-btn:hover {
  background: #35a078;
}

.delete-btn:hover {
  background: #cc0000;
}

.no-data-tip {
  text-align: center;
  color: #909399;
  margin-top: 24px;
  font-size: 16px;
  padding: 24px;
  background: #f8f9fa;
  border-radius: 8px;
}

.loading-tip {
  text-align: center;
  color: #606266;
  margin-top: 24px;
  font-size: 16px;
  padding: 24px;
}

.edit-form {
  padding: 16px;
}

.dialog-footer {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
  padding: 16px;
}

.loading-disabled {
  pointer-events: none;
  opacity: 0.8;
}
</style>