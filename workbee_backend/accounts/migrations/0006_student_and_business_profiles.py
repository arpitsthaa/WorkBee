import django.db.models.deletion
from django.conf import settings
from django.db import migrations, models


def create_profiles(apps, schema_editor):
    CustomUser = apps.get_model('accounts', 'CustomUser')
    StudentProfile = apps.get_model('accounts', 'StudentProfile')
    BusinessProfile = apps.get_model('accounts', 'BusinessProfile')

    for user in CustomUser.objects.all():
        if user.email.lower() == 'admin@gmail.com':
            CustomUser.objects.filter(pk=user.pk).update(
                user_type='admin',
                is_staff=True,
                is_superuser=True,
                is_active=True,
            )
        elif user.user_type == 'student':
            if not StudentProfile.objects.filter(user_id=user.pk).exists():
                StudentProfile.objects.create(
                    user_id=user.pk,
                    college=getattr(user, 'college', '') or '',
                    is_verified=getattr(user, 'is_verified', True),
                    bio=getattr(user, 'bio', '') or '',
                    portfolio_url=getattr(user, 'portfolio_url', '') or '',
                )
        elif user.user_type == 'business':
            if not getattr(user, 'pan_number', ''):
                continue
            if not BusinessProfile.objects.filter(user_id=user.pk).exists():
                BusinessProfile.objects.create(
                    user_id=user.pk,
                    business_name=getattr(user, 'business_name', '') or 'Business',
                    contact_person=getattr(user, 'contact_person', '') or '',
                    phone=getattr(user, 'phone', '') or '',
                    location=getattr(user, 'location', '') or '',
                    pan_number=user.pan_number,
                )

    CustomUser.objects.exclude(email__iexact='admin@gmail.com').exclude(
        email__isnull=True
    ).update(is_staff=False, is_superuser=False)


def reverse_profiles(apps, schema_editor):
    pass


class Migration(migrations.Migration):
    atomic = False
    dependencies = [
        ('accounts', '0005_unify_users_and_admin'),
    ]

    operations = [
        migrations.CreateModel(
            name='StudentProfile',
            fields=[
                ('id', models.BigAutoField(
                    auto_created=True,
                    primary_key=True,
                    serialize=False,
                    verbose_name='ID',
                )),
                ('college', models.CharField(
                    blank=True,
                    default='',
                    max_length=255,
                )),
                ('is_verified', models.BooleanField(default=True)),
                ('bio', models.TextField(blank=True, default='')),
                ('portfolio_url', models.URLField(blank=True, default='')),
                ('user', models.OneToOneField(
                    on_delete=django.db.models.deletion.CASCADE,
                    related_name='student_profile',
                    to=settings.AUTH_USER_MODEL,
                )),
            ],
        ),
        migrations.CreateModel(
            name='BusinessProfile',
            fields=[
                ('id', models.BigAutoField(
                    auto_created=True,
                    primary_key=True,
                    serialize=False,
                    verbose_name='ID',
                )),
                ('business_name', models.CharField(max_length=255)),
                ('contact_person', models.CharField(max_length=255)),
                ('phone', models.CharField(max_length=20)),
                ('location', models.CharField(max_length=255)),
                ('pan_number', models.CharField(max_length=9, unique=True)),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('user', models.OneToOneField(
                    on_delete=django.db.models.deletion.CASCADE,
                    related_name='business_profile',
                    to=settings.AUTH_USER_MODEL,
                )),
            ],
        ),
        migrations.AlterField(
            model_name='customuser',
            name='user_type',
            field=models.CharField(
                choices=[
                    ('student', 'Student'),
                    ('business', 'Business'),
                    ('admin', 'Admin'),
                ],
                default='student',
                max_length=20,
            ),
        ),
        migrations.RunPython(create_profiles, reverse_profiles),
    ]
