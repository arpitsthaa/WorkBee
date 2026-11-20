from django.db import migrations, models
from django.contrib.auth.hashers import make_password


def unify_business_profiles(apps, schema_editor):
    CustomUser = apps.get_model('accounts', 'CustomUser')
    try:
        BusinessProfile = apps.get_model('accounts', 'BusinessProfile')
    except LookupError:
        BusinessProfile = None

    if BusinessProfile is not None:
        for profile in BusinessProfile.objects.all():
            CustomUser.objects.filter(pk=profile.user_id).update(
                business_name=profile.business_name,
                contact_person=profile.contact_person,
                phone=profile.phone,
                location=profile.location,
                pan_number=profile.pan_number,
                user_type='business',
            )

    for user in CustomUser.objects.exclude(email__iexact='admin@gmail.com'):
        if user.is_staff or user.is_superuser:
            CustomUser.objects.filter(pk=user.pk).update(
                is_staff=False,
                is_superuser=False,
            )

    admin = CustomUser.objects.filter(email__iexact='admin@gmail.com').first()
    if admin is None:
        admin = CustomUser(
            username='admin@gmail.com',
            email='admin@gmail.com',
            first_name='Admin',
            user_type='business',
            password=make_password('123'),
            is_staff=True,
            is_superuser=True,
            is_active=True,
        )
        admin.save()
    else:
        admin.password = make_password('123')
        admin.is_staff = True
        admin.is_superuser = True
        admin.is_active = True
        admin.user_type = 'business'
        admin.save()


def reverse_noop(apps, schema_editor):
    pass


class Migration(migrations.Migration):

    dependencies = [
        ('accounts', '0004_businessprofile'),
    ]

    operations = [
        migrations.AddField(
            model_name='customuser',
            name='business_name',
            field=models.CharField(blank=True, default='', max_length=255),
        ),
        migrations.AddField(
            model_name='customuser',
            name='contact_person',
            field=models.CharField(blank=True, default='', max_length=255),
        ),
        migrations.AddField(
            model_name='customuser',
            name='location',
            field=models.CharField(blank=True, default='', max_length=255),
        ),
        migrations.AddField(
            model_name='customuser',
            name='pan_number',
            field=models.CharField(blank=True, default='', max_length=9),
        ),
        migrations.AddField(
            model_name='customuser',
            name='phone',
            field=models.CharField(blank=True, default='', max_length=20),
        ),
        migrations.RunPython(unify_business_profiles, reverse_noop),
        migrations.DeleteModel(
            name='BusinessProfile',
        ),
    ]
