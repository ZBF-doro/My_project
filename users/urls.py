from django.urls import path
from . import views
from .views import UserListCreateView, UserRetrieveUpdateDestroyView, register_superuser

urlpatterns = [
    path('register/', views.register, name='register'),
    path('login/', views.login, name='login'),
    path('logout/', views.user_logout, name='logout'),
    path('admin/users/', UserListCreateView.as_view(), name='user-list-create'),
    path('admin/users/<int:pk>/', UserRetrieveUpdateDestroyView.as_view(), name='user-retrieve-update-destroy'),
    path('register-superuser/', register_superuser, name='register-superuser'),
]