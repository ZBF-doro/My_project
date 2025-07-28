import { createRouter, createWebHistory } from 'vue-router'
import LoginView from '../views/LoginView.vue'
import RegisterView from '../views/RegisterView.vue'
import MainView from "@/views/MainView.vue"
// grading模块
import FruitGradingView from '@/views/FruitGradingView.vue'
import VegetableGradingView from '@/views/VegetableGradingView.vue'
import ResultListView from '@/views/ResultListView.vue'
// 用户管理组件导入
import UserManagement from '@/views/UserManagementView.vue'
// 注册超级用户页面组件导入
import RegisterSuperuserView from '@/views/RegisterSuperuserView.vue'

const routes = [
  {
    path: '/',
    redirect: '/main'
  },
  {
    path: '/main',
    component: MainView,
    meta: { auth: true }, // 主页面需要登录
    children: [
      {
        path: 'fruit-grading',
        name: 'FruitGrading',
        component: FruitGradingView,
        meta: { title: '水果分级' }
      },
      {
        path: 'vegetable-grading',
        name: 'VegetableGrading',
        component: VegetableGradingView,
        meta: { title: '蔬菜分级' }
      },
      {
        path: 'grading/results',
        name: 'ResultList',
        component: ResultListView,
        meta: { title: '分级记录' }
      },
      {
        path: 'user-management',
        name: 'UserManagement',
        component: UserManagement,
        meta: { title: '用户管理', auth: true }
      }
    ]
  },
  // 登录/注册路由
  {
    path: '/login',
    name: 'Login',
    component: LoginView,
    meta: { title: '用户登录', auth: false }
  },
  {
    path: '/register',
    name: 'Register',
    component: RegisterView,
    meta: { title: '用户注册', auth: false }
  },
  // 注册超级用户路由
  {
    path: '/register-superuser',
    name: 'RegisterSuperuser',
    component: RegisterSuperuserView,
    meta: { title: '注册超级用户', auth: false }
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
});

// 路由守卫，登录检查
router.beforeEach((to, from, next) => {
  // 从localStorage获取用户信息判断登录状态
  const isLoggedIn = localStorage.getItem('user');

  // 检查目标路由是否需要登录权限
  if (to.meta.auth && !isLoggedIn) {
    // 未登录且需要登录权限，跳转登录页
    next({
      name: 'Login',
      query: { redirect: to.fullPath } // 记录原目标路径，登录后可跳转回
    });
  } else {
    // 已登录或无需登录权限，正常访问
    next();
  }
});

export default router;