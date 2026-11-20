from django.db import transaction
from rest_framework import serializers
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer
from .models import CustomUser, StudentProfile, BusinessProfile


class StudentRegistrationSerializer(serializers.ModelSerializer):
    name = serializers.CharField(write_only=True)
    password = serializers.CharField(write_only=True, min_length=8)
    college = serializers.CharField(required=True)

    class Meta:
        model = CustomUser
        fields = ['name', 'email', 'password', 'college']

    def validate_email(self, value):
        email = value.lower().strip()
        if CustomUser.objects.filter(email=email).exists():
            raise serializers.ValidationError("An account with this email already exists.")
        return email

    def create(self, validated_data):
        name = validated_data.pop('name').strip().split(' ', 1)
        first_name = name[0]
        last_name = name[1] if len(name) > 1 else ''
        email = validated_data['email']

        user = CustomUser.objects.create_user(
            username=email,
            email=email,
            password=validated_data['password'],
            first_name=first_name,
            last_name=last_name,
            college=validated_data['college'].strip(),
            user_type='student',
        )
        StudentProfile.objects.create(
            user=user,
            college=validated_data['college'].strip(),
        )
        return user


class BusinessRegistrationSerializer(serializers.Serializer):
    business_name = serializers.CharField(max_length=255)
    contact_person = serializers.CharField(max_length=255)
    email = serializers.EmailField()
    phone = serializers.CharField(max_length=20)
    location = serializers.CharField(max_length=255)
    pan_number = serializers.CharField(min_length=9, max_length=9)
    password = serializers.CharField(write_only=True, min_length=8)

    def validate_email(self, value):
        email = value.lower().strip()
        if CustomUser.objects.filter(email=email).exists():
            raise serializers.ValidationError("An account with this email already exists.")
        return email

    def validate_pan_number(self, value):
        pan = value.strip()
        if not pan.isdigit() or len(pan) != 9:
            raise serializers.ValidationError("PAN number must be exactly 9 digits.")
        if BusinessProfile.objects.filter(pan_number=pan).exists():
            raise serializers.ValidationError("This PAN number is already registered.")
        return pan

    @transaction.atomic
    def create(self, validated_data):
        contact_name = validated_data['contact_person'].strip()
        name = contact_name.split(' ', 1)
        email = validated_data['email']

        user = CustomUser.objects.create_user(
            username=email,
            email=email,
            password=validated_data['password'],
            first_name=name[0],
            last_name=name[1] if len(name) > 1 else '',
            user_type='business',
        )
        BusinessProfile.objects.create(
            user=user,
            business_name=validated_data['business_name'].strip(),
            contact_person=contact_name,
            phone=validated_data['phone'].strip(),
            location=validated_data['location'].strip(),
            pan_number=validated_data['pan_number'].strip(),
        )
        return user


class ForgotPasswordSerializer(serializers.Serializer):
    email = serializers.EmailField()

    def validate_email(self, value):
        return value.lower().strip()


class CustomTokenObtainPairSerializer(TokenObtainPairSerializer):
    def validate(self, attrs):
        data = super().validate(attrs)
        data['user_type'] = self.user.user_type
        data['is_admin'] = self.user.is_staff and self.user.email.lower() == 'admin@gmail.com'
        return data