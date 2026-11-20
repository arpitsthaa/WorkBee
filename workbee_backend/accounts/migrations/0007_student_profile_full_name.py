from django.db import migrations, models


def fill_student_names(apps, schema_editor):
    StudentProfile = apps.get_model('accounts', 'StudentProfile')

    for profile in StudentProfile.objects.select_related('user').all():
        if not profile.full_name:
            profile.full_name = profile.user.get_full_name()
            if not profile.full_name:
                profile.full_name = profile.user.email.split('@')[0]
            profile.save(update_fields=['full_name'])


def reverse_noop(apps, schema_editor):
    pass


class Migration(migrations.Migration):
    atomic = False

    dependencies = [
        ('accounts', '0006_student_and_business_profiles'),
    ]

    operations = [
        migrations.AddField(
            model_name='studentprofile',
            name='full_name',
            field=models.CharField(blank=True, default='', max_length=255),
        ),
        migrations.RunPython(fill_student_names, reverse_noop),
    ]
