from django.urls import path
from rest_framework_simplejwt.views import TokenRefreshView
from .views import (
    StudentRegisterView,
    BusinessRegisterView,
    ForgotPasswordView,
    CustomLoginView,
)

urlpatterns = [
    path('register/student/', StudentRegisterView.as_view(), name='student_register'),
    path('register/business/', BusinessRegisterView.as_view(), name='business_register'),
    path('forgot-password/', ForgotPasswordView.as_view(), name='forgot_password'),
    path('login/', CustomLoginView.as_view(), name='token_obtain_pair'),
    path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
]