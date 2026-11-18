from rest_framework import status
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework.views import APIView
from .serializers import StudentRegistrationSerializer

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
        
        # Extract the first readable error message so Flutter's errorData['error'] catches it
        first_error = next(iter(serializer.errors.values()))[0]
        return Response(
            {'error': str(first_error)},
            status=status.HTTP_400_BAD_REQUEST
        )