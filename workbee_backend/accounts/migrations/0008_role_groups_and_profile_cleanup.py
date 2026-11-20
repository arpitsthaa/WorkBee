from django.db import migrations


def setup_roles(apps, schema_editor):
    CustomUser = apps.get_model('accounts', 'CustomUser')
    StudentProfile = apps.get_model('accounts', 'StudentProfile')
    BusinessProfile = apps.get_model('accounts', 'BusinessProfile')
    Group = apps.get_model('auth', 'Group')

    student_group, _ = Group.objects.get_or_create(name='Students')
    business_group, _ = Group.objects.get_or_create(name='Businesses')

    for user in CustomUser.objects.all():
        if user.email.lower() == 'admin@gmail.com':
            user.user_type = 'admin'
            user.is_staff = True
            user.is_superuser = True
            user.save(update_fields=['user_type', 'is_staff', 'is_superuser'])
            user.groups.remove(student_group, business_group)
        elif user.user_type == 'student':
            user.groups.add(student_group)
            user.groups.remove(business_group)
            if not StudentProfile.objects.filter(user_id=user.pk).exists():
                StudentProfile.objects.create(
                    user_id=user.pk,
                    full_name=user.get_full_name(),
                    college=getattr(user, 'college', '') or '',
                    is_verified=getattr(user, 'is_verified', True),
                    bio=getattr(user, 'bio', '') or '',
                    portfolio_url=getattr(user, 'portfolio_url', '') or '',
                )
        elif user.user_type == 'business':
            user.groups.add(business_group)
            user.groups.remove(student_group)
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


def reverse_roles(apps, schema_editor):
    pass


class Migration(migrations.Migration):
    atomic = False

    dependencies = [
        ('accounts', '0007_student_profile_full_name'),
    ]

    operations = [
        migrations.RunPython(setup_roles, reverse_roles),
        migrations.SeparateDatabaseAndState(
            database_operations=[],
            state_operations=[
                migrations.RemoveField(model_name='customuser', name='college'),
                migrations.RemoveField(model_name='customuser', name='is_verified'),
                migrations.RemoveField(model_name='customuser', name='bio'),
                migrations.RemoveField(model_name='customuser', name='portfolio_url'),
                migrations.RemoveField(model_name='customuser', name='business_name'),
                migrations.RemoveField(model_name='customuser', name='contact_person'),
                migrations.RemoveField(model_name='customuser', name='phone'),
                migrations.RemoveField(model_name='customuser', name='location'),
                migrations.RemoveField(model_name='customuser', name='pan_number'),
            ],
        ),
    ]
