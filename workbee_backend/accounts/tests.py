from django.test import TestCase
from .models import CustomUser


class AccountRoleTests(TestCase):
    def test_only_named_admin_has_staff_status(self):
        student = CustomUser.objects.create_user(
            username='student@example.com',
            email='student@example.com',
            password='strong-password',
            user_type='student',
            is_staff=True,
        )
        business = CustomUser.objects.create_user(
            username='business@example.com',
            email='business@example.com',
            password='strong-password',
            user_type='business',
            is_staff=True,
        )

        student.refresh_from_db()
        business.refresh_from_db()
        self.assertFalse(student.is_staff)
        self.assertFalse(business.is_staff)

    def test_named_admin_is_staff_and_superuser(self):
        admin, _ = CustomUser.objects.get_or_create(
            email='admin@gmail.com',
            defaults={
                'username': 'admin@gmail.com',
                'user_type': 'business',
            },
        )
        admin.set_password('123')
        admin.save()
        admin.refresh_from_db()
        self.assertTrue(admin.is_staff)
        self.assertTrue(admin.is_superuser)
