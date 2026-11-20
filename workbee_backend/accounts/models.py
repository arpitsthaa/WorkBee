from django.contrib.auth.models import AbstractUser
from django.db import models


class CustomUser(AbstractUser):
    USER_TYPE_CHOICES = [
        ('student', 'Student'),
        ('business', 'Business'),
        ('admin', 'Admin'),
    ]

    email = models.EmailField(unique=True)
    user_type = models.CharField(max_length=20, choices=USER_TYPE_CHOICES, default='student')
    college = models.CharField(max_length=255, blank=True, null=True)
    is_verified = models.BooleanField(default=True)
    bio = models.TextField(blank=True, default='')
    portfolio_url = models.URLField(blank=True, default='')
    business_name = models.CharField(max_length=255, blank=True, default='')
    contact_person = models.CharField(max_length=255, blank=True, default='')
    phone = models.CharField(max_length=20, blank=True, default='')
    location = models.CharField(max_length=255, blank=True, default='')
    pan_number = models.CharField(max_length=9, blank=True, default='')

    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['username']

    def __str__(self):
        return f"{self.email} ({self.user_type})"
    
    def save(self, *args, **kwargs):
        is_admin = self.email.lower() == 'admin@gmail.com'
        self.is_staff = is_admin
        self.is_superuser = is_admin
        if is_admin:
            self.user_type = 'admin'
        super().save(*args, **kwargs)


class StudentProfile(models.Model):
    user = models.OneToOneField(
        CustomUser,
        on_delete=models.CASCADE,
        related_name='student_profile',
    )
    college = models.CharField(max_length=255, blank=True, default='')
    is_verified = models.BooleanField(default=True)
    bio = models.TextField(blank=True, default='')
    portfolio_url = models.URLField(blank=True, default='')

    def __str__(self):
        return f"Student: {self.user.email}"


class BusinessProfile(models.Model):
    user = models.OneToOneField(
        CustomUser,
        on_delete=models.CASCADE,
        related_name='business_profile',
    )
    business_name = models.CharField(max_length=255)
    contact_person = models.CharField(max_length=255)
    phone = models.CharField(max_length=20)
    location = models.CharField(max_length=255)
    pan_number = models.CharField(max_length=9, unique=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Business: {self.business_name}"