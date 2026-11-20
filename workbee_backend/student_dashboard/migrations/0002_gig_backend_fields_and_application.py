# Generated for the WorkBee gig backend

import django.db.models.deletion
from django.conf import settings
from django.db import migrations, models


def add_gig_fields(apps, schema_editor):
    if schema_editor.connection.vendor == 'postgresql':
        statements = [
            'ALTER TABLE student_dashboard_gig ADD COLUMN IF NOT EXISTS owner_id bigint NULL',
            'ALTER TABLE student_dashboard_gig ADD COLUMN IF NOT EXISTS description text NULL',
            "ALTER TABLE student_dashboard_gig ADD COLUMN IF NOT EXISTS category varchar(30) NOT NULL DEFAULT 'general'",
            "ALTER TABLE student_dashboard_gig ADD COLUMN IF NOT EXISTS work_type varchar(20) NOT NULL DEFAULT 'flexible'",
            'ALTER TABLE student_dashboard_application ADD COLUMN IF NOT EXISTS cover_letter text NULL',
            'CREATE UNIQUE INDEX IF NOT EXISTS unique_student_gig_application ON student_dashboard_application (student_id, gig_id)',
        ]
    else:
        statements = [
            'ALTER TABLE student_dashboard_gig ADD COLUMN owner_id integer NULL',
            'ALTER TABLE student_dashboard_gig ADD COLUMN description text',
            "ALTER TABLE student_dashboard_gig ADD COLUMN category varchar(30) NOT NULL DEFAULT 'general'",
            "ALTER TABLE student_dashboard_gig ADD COLUMN work_type varchar(20) NOT NULL DEFAULT 'flexible'",
            'ALTER TABLE student_dashboard_application ADD COLUMN cover_letter text',
            'CREATE UNIQUE INDEX IF NOT EXISTS unique_student_gig_application ON student_dashboard_application (student_id, gig_id)',
        ]
    for statement in statements:
        schema_editor.execute(statement)


def remove_gig_fields(apps, schema_editor):
    if schema_editor.connection.vendor == 'postgresql':
        for statement in [
            'DROP INDEX IF EXISTS unique_student_gig_application',
            'ALTER TABLE student_dashboard_application DROP COLUMN IF EXISTS cover_letter',
            'ALTER TABLE student_dashboard_gig DROP COLUMN IF EXISTS work_type',
            'ALTER TABLE student_dashboard_gig DROP COLUMN IF EXISTS category',
            'ALTER TABLE student_dashboard_gig DROP COLUMN IF EXISTS description',
            'ALTER TABLE student_dashboard_gig DROP COLUMN IF EXISTS owner_id',
        ]:
            schema_editor.execute(statement)
        return


class Migration(migrations.Migration):

    dependencies = [
        ('student_dashboard', '0001_initial'),
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
    ]

    operations = [
        migrations.SeparateDatabaseAndState(
            database_operations=[
                migrations.RunPython(add_gig_fields, remove_gig_fields),
            ],
            state_operations=[
                migrations.AddField(
                    model_name='gig',
                    name='owner',
                    field=models.ForeignKey(blank=True, db_constraint=False, null=True, on_delete=django.db.models.deletion.CASCADE, related_name='posted_gigs', to=settings.AUTH_USER_MODEL),
                ),
                migrations.AddField(
                    model_name='gig',
                    name='description',
                    field=models.TextField(blank=True, default=''),
                ),
                migrations.AddField(
                    model_name='gig',
                    name='category',
                    field=models.CharField(choices=[('design', 'Design & creative'), ('development', 'Development'), ('marketing', 'Marketing'), ('writing', 'Writing'), ('general', 'General project')], default='general', max_length=30),
                ),
                migrations.AddField(
                    model_name='gig',
                    name='work_type',
                    field=models.CharField(choices=[('remote', 'Remote'), ('onsite', 'On-site'), ('hybrid', 'Hybrid'), ('flexible', 'Flexible')], default='flexible', max_length=20),
                ),
                migrations.AddField(
                    model_name='application',
                    name='cover_letter',
                    field=models.TextField(blank=True, default=''),
                ),
                migrations.AlterField(
                    model_name='application',
                    name='status',
                    field=models.CharField(choices=[('pending', 'Pending'), ('shortlisted', 'Shortlisted'), ('accepted', 'Accepted'), ('rejected', 'Rejected')], default='pending', max_length=20),
                ),
                migrations.AddConstraint(
                    model_name='application',
                    constraint=models.UniqueConstraint(fields=('student', 'gig'), name='unique_student_gig_application'),
                ),
            ],
        ),
    ]
