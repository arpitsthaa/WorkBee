# Generated for the WorkBee gig backend

import django.db.models.deletion
from django.conf import settings
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('student_dashboard', '0001_initial'),
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
    ]

    operations = [
        migrations.AddField(
            model_name='gig',
            name='owner',
            field=models.ForeignKey(
                blank=True,
                db_constraint=False,
                null=True,
                on_delete=django.db.models.deletion.CASCADE,
                related_name='posted_gigs',
                to=settings.AUTH_USER_MODEL,
            ),
        ),
        migrations.AddField(
            model_name='gig',
            name='description',
            field=models.TextField(blank=True, default=''),
        ),
        migrations.AddField(
            model_name='gig',
            name='category',
            field=models.CharField(
                choices=[
                    ('design', 'Design & creative'),
                    ('development', 'Development'),
                    ('marketing', 'Marketing'),
                    ('writing', 'Writing'),
                    ('general', 'General project'),
                ],
                default='general',
                max_length=30,
            ),
        ),
        migrations.AddField(
            model_name='gig',
            name='work_type',
            field=models.CharField(
                choices=[
                    ('remote', 'Remote'),
                    ('onsite', 'On-site'),
                    ('hybrid', 'Hybrid'),
                    ('flexible', 'Flexible'),
                ],
                default='flexible',
                max_length=20,
            ),
        ),
        migrations.AddField(
            model_name='application',
            name='cover_letter',
            field=models.TextField(blank=True, default=''),
        ),
        migrations.AlterField(
            model_name='application',
            name='status',
            field=models.CharField(
                choices=[
                    ('pending', 'Pending'),
                    ('shortlisted', 'Shortlisted'),
                    ('accepted', 'Accepted'),
                    ('rejected', 'Rejected'),
                ],
                default='pending',
                max_length=20,
            ),
        ),
        migrations.AddConstraint(
            model_name='application',
            constraint=models.UniqueConstraint(
                fields=('student', 'gig'),
                name='unique_student_gig_application',
            ),
        ),
    ]
