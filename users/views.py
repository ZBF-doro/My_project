from sqlite3 import IntegrityError
import logging
from rest_framework import status, generics, permissions
from rest_framework.response import Response
from rest_framework.authtoken.models import Token
from rest_framework.decorators import api_view, permission_classes
from django.contrib.auth import get_user_model, authenticate, logout
from .serializers import UserSerializer, LoginSerializer, UserManagementSerializer
from rest_framework.permissions import AllowAny, IsAdminUser

# 获取日志记录器
logger = logging.getLogger(__name__)
User = get_user_model()

# 邀请码的设置
valid_invitation_codes = ['ZBF123', 'zbf123']

# 自定义权限类
class IsSuperUser(permissions.BasePermission):
    """基于 is_superuser 字段的权限验证"""
    def has_permission(self, request, view):
        # 检查用户是否认证且是超级用户
        return request.user and request.user.is_authenticated and request.user.is_superuser

# 邀请码
valid_invitation_codes = ['ZBF123', 'zbf123']

@api_view(['POST'])
@permission_classes([AllowAny])
def register(request):
    # 解决密码字段命名问题
    request_data = request.data.copy()
    if 'password' in request_data and 'password1' not in request_data:
        request_data['password1'] = request_data['password']
        request_data['password2'] = request_data['password']

    serializer = UserSerializer(data=request_data)
    if serializer.is_valid():
        password = serializer.validated_data['password1']
        user = User.objects.create_user(
            username=serializer.validated_data['username'],
            email=serializer.validated_data.get('email'),
            phone=serializer.validated_data.get('phone'),
            password=password
        )
        token = Token.objects.create(user=user)

        # 返回包含 is_superuser 的响应
        return Response({
            'token': token.key,
            'username': user.username,
            'is_superuser': user.is_superuser  # 管理员标志
        }, status=status.HTTP_201_CREATED)

    logger.error(f"注册失败: {serializer.errors}")
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@api_view(['POST'])
@permission_classes([AllowAny])
def login(request):
    logger.debug(f"登录请求数据: {request.data}")

    serializer = LoginSerializer(data=request.data)
    if serializer.is_valid():
        user = serializer.validated_data['user']
        token, created = Token.objects.get_or_create(user=user)

        logger.info(f"用户 {user.username} 登录成功")

        # 确保返回 is_superuser 字段
        return Response({
            'token': token.key,
            'username': user.username,
            'user_id': user.id,
            'is_superuser': user.is_superuser  # 管理员标志
        }, status=status.HTTP_200_OK)

    logger.warning(f"登录验证失败: {serializer.errors}")
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@api_view(['POST'])
def user_logout(request):
    if request.auth:
        try:
            request.auth.delete()
        except Exception as e:
            logger.error(f"删除token失败: {str(e)}")
    logout(request)
    return Response({"message": "登出成功"}, status=status.HTTP_200_OK)

class UserListCreateView(generics.ListCreateAPIView):
    """用户管理API，基于 is_superuser 权限"""
    queryset = User.objects.filter(is_superuser=False)
    serializer_class = UserManagementSerializer
    permission_classes = [IsSuperUser]  # 使用自定义权限类

class UserRetrieveUpdateDestroyView(generics.RetrieveUpdateDestroyAPIView):
    """用户管理API。基于 is_superuser 权限"""
    queryset = User.objects.filter(is_superuser=False)
    serializer_class = UserManagementSerializer
    permission_classes = [IsSuperUser]  # 使用自定义权限类

@api_view(['POST'])
@permission_classes([AllowAny])
def register_superuser(request):
    try:
        data = request.data
        logger.debug(f"超级用户注册请求: {data}")

        required_fields = ['username', 'email', 'password', 'invitation_code', 'phone']
        missing_fields = [field for field in required_fields if field not in data]
        if missing_fields:
            logger.warning(f"缺少必填字段: {missing_fields}")
            return Response(
                {'error': f'缺少必填字段: {", ".join(missing_fields)}'},
                status=status.HTTP_400_BAD_REQUEST
            )

        if data['invitation_code'] not in valid_invitation_codes:
            logger.warning(f"无效邀请码: {data['invitation_code']}")
            return Response(
                {'error': f'无效邀请码，有效邀请码示例: {valid_invitation_codes[0]}'},
                status=status.HTTP_400_BAD_REQUEST
            )

        user = User.objects.create_superuser(
            username=data['username'],
            email=data['email'],
            password=data['password'],
            phone=data['phone'],
            is_superuser=True
        )

        token = Token.objects.create(user=user)
        return Response({
            'token': token.key,
            'is_superuser': True,  # 明确返回管理员标志
            'message': '超级用户注册成功'
        }, status=status.HTTP_201_CREATED)

    except IntegrityError as e:
        logger.error(f"超级用户注册失败: {str(e)}")
        return Response({'error': '用户名或电话已被注册'}, status=status.HTTP_400_BAD_REQUEST)