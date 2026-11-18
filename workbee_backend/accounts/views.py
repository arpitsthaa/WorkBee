from rest_framework import status
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework_simplejwt.views import TokenObtainPairView
from .serializers import StudentRegistrationSerializer, CustomTokenObtainPairSerializer


class StudentRegisterView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = StudentRegistrationSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(
                {'message': 'Student registered successfully'},
                status=status.HTTP_201_CREATED
            )

        first_error = next(iter(serializer.errors.values()))[0]
        return Response(
            {'error': str(first_error)},
            status=status.HTTP_400_BAD_REQUEST
        )


class CustomLoginView(TokenObtainPairView):
    serializer_class = CustomTokenObtainPairSerializer