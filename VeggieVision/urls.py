from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static
from rest_framework.authtoken.views import obtain_auth_token

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api-auth/', include('rest_framework.urls')),        # DRF 认证页面
    path('api/users/', include('users.urls')),                # 用户模块路由
    path('api/grading/', include('grading.urls')),           # 分级模块路由
    path('api-token-auth/', obtain_auth_token),              # Token 认证接口
]

# 开发环境静态资源和媒体文件路由
if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
    urlpatterns += static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)