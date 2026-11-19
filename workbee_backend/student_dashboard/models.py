from django.db import models
from django.conf import settings

class Gig(models.Model):
    title = models.CharField(max_length=200)
    business_name = models.CharField(max_length=200)
    location = models.CharField(max_length=200)
    budget_npr = models.PositiveIntegerField()
    duration_days = models.PositiveIntegerField(default=7)
    due_date = models.DateField()
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.title} ({self.business_name})"


class Application(models.Model):
    STATUS_CHOICES = [
        ('pending', 'Pending'),
        ('shortlisted', 'Shortlisted'),
        ('rejected', 'Rejected'),
    ]
    student = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='applications'
    )
    gig = models.ForeignKey(Gig, on_delete=models.CASCADE, related_name='applications')
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')
    applied_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.student.email} applied to {self.gig.title}"


class Project(models.Model):
    STATUS_CHOICES = [
        ('active', 'Active'),
        ('approved', 'Approved'),
    ]
    student = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='projects'
    )
    gig = models.ForeignKey(Gig, on_delete=models.CASCADE)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='active')
    rating = models.DecimalField(max_digits=3, decimal_places=1, null=True, blank=True)

    def __str__(self):
        return f"{self.gig.title} ({self.status})"