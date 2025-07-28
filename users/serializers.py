from rest_framework import serializers
from django.contrib.auth import get_user_model, authenticate
from django.contrib.auth.password_validation import validate_password
from django.core.exceptions import ValidationError

User = get_user_model()


class UserSerializer(serializers.ModelSerializer):
    password1 = serializers.CharField(
        write_only=True,
        label="密码",
        required=True,
        validators=[validate_password]
    )
    password2 = serializers.CharField(
        write_only=True,
        label="确认密码",
        required=True
    )

    class Meta:
        model = User
        fields = ('username', 'password1', 'password2', 'email', 'phone')
        extra_kwargs = {
            'phone': {'required': True}
        }

    def validate_username(self, value):
        if User.objects.filter(username=value).exists():
            raise serializers.ValidationError("用户名已存在")
        return value

    def validate(self, attrs):
        # 验证两次密码是否一致
        if attrs['password1'] != attrs['password2']:
            raise serializers.ValidationError("两次输入的密码不一致")
        return attrs

    def create(self, validated_data):
        # 创建用户时使用 password1 作为密码
        user = User.objects.create_user(
            username=validated_data['username'],
            email=validated_data.get('email'),
            phone=validated_data.get('phone'),
            password=validated_data['password1']
        )
        return user


class LoginSerializer(serializers.Serializer):
    username = serializers.CharField(required=True)
    password = serializers.CharField(
        required=True,
        style={'input_type': 'password'}
    )

    def validate(self, data):
        username = data.get('username')
        password = data.get('password')

        if username and password:
            user = authenticate(username=username, password=password)

            if user:
                if not user.is_active:
                    raise serializers.ValidationError("用户账户已被禁用")
                data['user'] = user
            else:
                raise serializers.ValidationError("用户名或密码不正确")
        else:
            raise serializers.ValidationError("必须提供用户名和密码")

        return data


class UserManagementSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ('id', 'username', 'email', 'phone', 'is_active')

    def update(self, instance, validated_data):
        # 更新用户信息
        instance.username = validated_data.get('username', instance.username)
        instance.email = validated_data.get('email', instance.email)
        instance.phone = validated_data.get('phone', instance.phone)
        instance.is_active = validated_data.get('is_active', instance.is_active)

        # 如果有密码更新
        if 'password' in validated_data:
            instance.set_password(validated_data['password'])

        instance.save()
        return instance