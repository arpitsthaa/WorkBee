from django.conf import settings
from django.contrib.auth.tokens import default_token_generator
from django.core.mail import send_mail
from django.utils.encoding import force_bytes
from django.utils.http import urlsafe_base64_encode
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework_simplejwt.views import TokenObtainPairView
from .models import CustomUser
from .serializers import (
    StudentRegistrationSerializer,
    BusinessRegistrationSerializer,
    ForgotPasswordSerializer,
    CustomTokenObtainPairSerializer,
)


class StudentRegisterView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = StudentRegistrationSerializer(data=request.data)
        if not serializer.is_valid():
            error = next(iter(serializer.errors.values()))[0]
            return Response({'error': str(error)}, status=400)

        serializer.save()
        return Response({'message': 'Student registered successfully'}, status=201)


class BusinessRegisterView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = BusinessRegistrationSerializer(data=request.data)
        if not serializer.is_valid():
            error = next(iter(serializer.errors.values()))[0]
            return Response({'error': str(error)}, status=400)

        serializer.save()
        return Response({'message': 'Business registered successfully'}, status=201)


class ForgotPasswordView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = ForgotPasswordSerializer(data=request.data)
        if serializer.is_valid():
            email = serializer.validated_data['email']
            user = CustomUser.objects.filter(email=email).first()

            if user:
                token = default_token_generator.make_token(user)
                uid = urlsafe_base64_encode(force_bytes(user.pk))
                reset_link = f"https://workbee-zi7l.onrender.com/reset-password/{uid}/{token}/"

                send_mail(
                    subject="WorkBee Password Reset",
                    message=f"Use this link to reset your WorkBee password: {reset_link}",
                    from_email=getattr(settings, 'DEFAULT_FROM_EMAIL', 'noreply@workbee.com'),
                    recipient_list=[email],
                    fail_silently=True,
                )

            return Response({
                'message': 'If an account exists with this email, a reset link has been sent.'
            })

        error = next(iter(serializer.errors.values()))[0]
        return Response({'error': str(error)}, status=400)


class CustomLoginView(TokenObtainPairView):
    serializer_class = CustomTokenObtainPairSerializer