from django.db import models
from django.conf import settings

class Gig(models.Model):
    CATEGORY_CHOICES = [
        ('design', 'Design & creative'),
        ('development', 'Development'),
        ('marketing', 'Marketing'),
        ('writing', 'Writing'),
        ('general', 'General project'),
    ]

    WORK_TYPE_CHOICES = [
        ('remote', 'Remote'),
        ('onsite', 'On-site'),
        ('hybrid', 'Hybrid'),
        ('flexible', 'Flexible'),
    ]

    owner = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='posted_gigs',
        null=True,
        blank=True,
        db_constraint=False,
    )
    title = models.CharField(max_length=200)
    business_name = models.CharField(max_length=200)
    location = models.CharField(max_length=200)
    budget_npr = models.PositiveIntegerField()
    duration_days = models.PositiveIntegerField(default=7)
    due_date = models.DateField()
    description = models.TextField(blank=True, default='')
    category = models.CharField(max_length=30, choices=CATEGORY_CHOICES, default='general')
    work_type = models.CharField(max_length=20, choices=WORK_TYPE_CHOICES, default='flexible')
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.title} ({self.business_name})"


class Application(models.Model):
    STATUS_CHOICES = [
        ('pending', 'Pending'),
        ('shortlisted', 'Shortlisted'),
        ('accepted', 'Accepted'),
        ('rejected', 'Rejected'),
    ]
    student = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='applications',
        db_constraint=False,
    )
    gig = models.ForeignKey(
        Gig,
        on_delete=models.CASCADE,
        related_name='applications',
        db_constraint=False,
    )
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')
    cover_letter = models.TextField(blank=True, default='')
    applied_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        constraints = [
            models.UniqueConstraint(
                fields=['student', 'gig'],
                name='unique_student_gig_application',
            )
        ]

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
        related_name='projects',
        db_constraint=False,
    )
    gig = models.ForeignKey(Gig, on_delete=models.CASCADE, db_constraint=False)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='active')
    rating = models.DecimalField(max_digits=3, decimal_places=1, null=True, blank=True)

    def __str__(self):
        return f"{self.gig.title} ({self.status})"