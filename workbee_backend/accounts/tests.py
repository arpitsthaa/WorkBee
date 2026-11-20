from django.test import TestCase
from .models import CustomUser, StudentProfile, BusinessProfile


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
        self.assertEqual(admin.user_type, 'admin')

    def test_student_and_business_profiles_are_separate(self):
        student = CustomUser.objects.create_user(
            username='profile-student@example.com',
            email='profile-student@example.com',
            password='strong-password',
            user_type='student',
        )
        StudentProfile.objects.create(
            user=student,
            college='Test College',
        )

        business = CustomUser.objects.create_user(
            username='profile-business@example.com',
            email='profile-business@example.com',
            password='strong-password',
            user_type='business',
        )
        BusinessProfile.objects.create(
            user=business,
            business_name='Test Business',
            contact_person='Test Person',
            phone='9800000000',
            location='Kathmandu',
            pan_number='123456789',
        )

        self.assertEqual(student.student_profile.college, 'Test College')
        self.assertEqual(
            business.business_profile.business_name,
            'Test Business',
        )

    def test_admin_can_open_user_change_page(self):
        admin, _ = CustomUser.objects.get_or_create(
            email='admin@gmail.com',
            defaults={
                'username': 'admin@gmail.com',
                'user_type': 'admin',
            },
        )
        admin.set_password('123')
        admin.save()
        student = CustomUser.objects.create_user(
            username='change@example.com',
            email='change@example.com',
            password='strong-password',
            user_type='student',
        )
        StudentProfile.objects.create(
            user=student,
            college='Test College',
        )

        self.client.force_login(admin)
        response = self.client.get(
            f'/admin/accounts/customuser/{student.pk}/change/'
        )
        self.assertEqual(response.status_code, 200)
