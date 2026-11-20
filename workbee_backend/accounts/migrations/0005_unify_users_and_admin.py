from django.db import migrations, models


def add_user_columns(apps, schema_editor):
    table_name = 'accounts_customuser'
    columns = [
        ('business_name', 'varchar(255)', "NOT NULL DEFAULT ''"),
        ('contact_person', 'varchar(255)', "NOT NULL DEFAULT ''"),
        ('phone', 'varchar(20)', "NOT NULL DEFAULT ''"),
        ('location', 'varchar(255)', "NOT NULL DEFAULT ''"),
        ('pan_number', 'varchar(9)', "NOT NULL DEFAULT ''"),
    ]

    with schema_editor.connection.cursor() as cursor:
        existing = {
            column.name
            for column in schema_editor.connection.introspection.get_table_description(
                cursor,
                table_name,
            )
        }

        for name, field_type, extra_sql in columns:
            if name not in existing:
                quoted_table = schema_editor.quote_name(table_name)
                quoted_column = schema_editor.quote_name(name)
                cursor.execute(
                    f'ALTER TABLE {quoted_table} ADD COLUMN {quoted_column} '
                    f'{field_type} {extra_sql}'
                )
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


def drop_business_profile_table(apps, schema_editor):
    table_name = 'accounts_businessprofile'
    with schema_editor.connection.cursor() as cursor:
        existing_tables = schema_editor.connection.introspection.table_names(cursor)
        if table_name in existing_tables:
            quoted_table = schema_editor.quote_name(table_name)
            cursor.execute(f'DROP TABLE {quoted_table}')


class Migration(migrations.Migration):
    atomic = False

    dependencies = [
        ('accounts', '0004_businessprofile'),
    ]

    operations = [
        migrations.SeparateDatabaseAndState(
            database_operations=[
                migrations.RunPython(add_user_columns, reverse_noop),
            ],
            state_operations=[
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
            ],
        ),
        migrations.RunPython(unify_business_profiles, reverse_noop),
        migrations.SeparateDatabaseAndState(
            database_operations=[
                migrations.RunPython(drop_business_profile_table, reverse_noop),
            ],
            state_operations=[
                migrations.DeleteModel(
                    name='BusinessProfile',
                ),
            ],
        ),
    ]
