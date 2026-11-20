from django.db import migrations, models


def add_full_name_column(apps, schema_editor):
    table_name = 'accounts_studentprofile'
    column_name = 'full_name'

    with schema_editor.connection.cursor() as cursor:
        existing = {
            column.name
            for column in schema_editor.connection.introspection.get_table_description(
                cursor,
                table_name,
            )
        }
        if column_name not in existing:
            quoted_table = schema_editor.quote_name(table_name)
            quoted_column = schema_editor.quote_name(column_name)
            cursor.execute(
                f'ALTER TABLE {quoted_table} ADD COLUMN {quoted_column} '
                "varchar(255) NOT NULL DEFAULT ''"
            )


def fill_student_names(apps, schema_editor):
    StudentProfile = apps.get_model('accounts', 'StudentProfile')

    for profile in StudentProfile.objects.select_related('user').all():
        if not profile.full_name:
            first_name = getattr(profile.user, 'first_name', '') or ''
            last_name = getattr(profile.user, 'last_name', '') or ''
            profile.full_name = f"{first_name} {last_name}".strip()
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
        migrations.SeparateDatabaseAndState(
            database_operations=[
                migrations.RunPython(add_full_name_column, reverse_noop),
            ],
            state_operations=[
                migrations.AddField(
                    model_name='studentprofile',
                    name='full_name',
                    field=models.CharField(blank=True, default='', max_length=255),
                ),
            ],
        ),
        migrations.RunPython(fill_student_names, reverse_noop),
    ]
