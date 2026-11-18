from django.urls import path
from rest_framework_simplejwt.views import TokenRefreshView
from .views import StudentRegisterView, CustomLoginView

urlpatterns = [
    path('register/student/', StudentRegisterView.as_view(), name='student_register'),
    path('login/', CustomLoginView.as_view(), name='token_obtain_pair'),
    path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
]