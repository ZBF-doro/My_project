<template>
  <div class="main-view">
    <HeaderView />
    <!-- 首页内容区域（仅在访问 /main 时显示） -->
    <div v-if="$route.path === '/main'" class="home-section">
      <h1 class="title">果蔬智能分级系统</h1>
      <p class="desc">高效精准的果蔬分级解决方案，支持水果、蔬菜分级及记录查询</p>

      <!--图片区域 -->
      <div class="featured-image">
        <img src="/img/farmer.jpg" alt="果蔬智能分级系统" class="responsive-image">
      </div>

      <div class="quick-actions">
        <router-link to="main/fruit-grading" class="action-btn">
          <i class="fas fa-apple-alt"></i>
          <span>水果分级</span>
        </router-link>
        <router-link to="main/vegetable-grading" class="action-btn">
          <i class="fas fa-leaf"></i>
          <span>蔬菜分级</span>
        </router-link>
        <router-link to="main/grading/results" class="action-btn">
          <i class="fas fa-list"></i>
          <span>分级记录</span>
        </router-link>
      </div>
    </div>
    <router-view />
    <FooterLinksView />
  </div>
</template>

<script>
import HeaderView from '@/components/HeaderView.vue';
import FooterLinksView from '@/components/FooterLinksView.vue';

export default {
  components: { HeaderView, FooterLinksView },
  data() {
    return {};
  }
};
</script>

<style scoped>
.main-view {
  display: flex;
  flex-direction: column;
  min-height: 100vh;
}

.home-section {
  padding: 40px 20px;
  text-align: center;
  flex: 1;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  background-color: #f8f9fa;
}

.title {
  font-size: 2.2rem;
  color: #2c3e50;
  margin-bottom: 15px;
}

.desc {
  font-size: 1.1rem;
  color: #7f8c8d;
  margin-bottom: 25px;
  max-width: 800px;
  line-height: 1.6;
}

.featured-image {
  margin: 20px 0 35px;
  max-width: 80%;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
  border: 1px solid #e0e0e0;
  transition: transform 0.3s ease;
}

.featured-image:hover {
  transform: scale(1.01);
}

.responsive-image {
  max-width: 100%;
  height: auto;
  display: block;
}

.quick-actions {
  display: flex;
  gap: 20px;
  flex-wrap: wrap;
  justify-content: center;
  margin-top: 20px;
}

.action-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 15px 30px;
  background: #3498db;
  color: white;
  text-decoration: none;
  border-radius: 8px;
  transition: transform 0.2s, background-color 0.2s;
  gap: 10px;
  min-width: 180px;
}

.action-btn:hover {
  transform: translateY(-3px);
  background-color: #2980b9;
}

.action-btn i {
  font-size: 1.2rem;
}

.action-btn span {
  font-size: 1.1rem;
}

/* 响应式调整 */
@media (max-width: 768px) {
  .featured-image {
    max-width: 95%;
  }

  .quick-actions {
    flex-direction: column;
    width: 100%;
    max-width: 300px;
  }

  .action-btn {
    width: 100%;
  }
}

@media (max-width: 480px) {
  .title {
    font-size: 1.8rem;
  }

  .desc {
    font-size: 1rem;
    padding: 0 15px;
  }

  .featured-image {
    margin: 15px 0 25px;
  }
}
</style>