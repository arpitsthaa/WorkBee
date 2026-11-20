from django.contrib.auth.models import Group, Permission
from django.db.models.signals import post_save, post_migrate
from django.dispatch import receiver

from .models import CustomUser, StudentProfile


def add_user_to_role_group(user):
    student_group, _ = Group.objects.get_or_create(name='Students')
    business_group, _ = Group.objects.get_or_create(name='Businesses')

    if user.user_type == 'student':
        user.groups.add(student_group)
        user.groups.remove(business_group)
    elif user.user_type == 'business':
        user.groups.add(business_group)
        user.groups.remove(student_group)
    else:
        user.groups.remove(student_group, business_group)


@receiver(post_save, sender=CustomUser)
def update_user_role(sender, instance, created, **kwargs):
    add_user_to_role_group(instance)

    if instance.user_type == 'student':
        StudentProfile.objects.get_or_create(
            user=instance,
            defaults={
                'full_name': instance.get_full_name(),
                'college': '',
            },
        )


@receiver(post_migrate)
def add_role_permissions(sender, **kwargs):
    student_group, _ = Group.objects.get_or_create(name='Students')
    business_group, _ = Group.objects.get_or_create(name='Businesses')

    student_models = [
        ('student_dashboard', 'application'),
        ('student_dashboard', 'project'),
        ('student_dashboard', 'gig'),
    ]
    business_models = [
        ('student_dashboard', 'gig'),
        ('student_dashboard', 'application'),
    ]

    for app_label, model_name in student_models:
        permissions = Permission.objects.filter(
            content_type__app_label=app_label,
            content_type__model=model_name,
        )
        if model_name == 'gig':
            permissions = permissions.filter(codename__in=['view_gig'])
        elif model_name == 'application':
            permissions = permissions.filter(
                codename__in=['add_application', 'view_application', 'change_application']
            )
        elif model_name == 'project':
            permissions = permissions.filter(codename__in=['view_project'])
        student_group.permissions.add(*permissions)

    for app_label, model_name in business_models:
        permissions = Permission.objects.filter(
            content_type__app_label=app_label,
            content_type__model=model_name,
        )
        if model_name == 'gig':
            permissions = permissions.filter(
                codename__in=[
                    'add_gig',
                    'change_gig',
                    'delete_gig',
                    'view_gig',
                ]
            )
        elif model_name == 'application':
            permissions = permissions.filter(codename__in=['view_application', 'change_application'])
        business_group.permissions.add(*permissions)
