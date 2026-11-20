import json

from django.test import TestCase
from rest_framework.test import APIClient
from .models import CustomUser, StudentProfile, BusinessProfile


class AccountRoleTests(TestCase):
    def login_api(self, user):
        client = APIClient()
        response = client.post('/api/accounts/login/', {
            'email': user.email,
            'password': 'strong-password',
        })
        self.assertEqual(response.status_code, 200)
        token = response.json()['access']
        client.credentials(HTTP_AUTHORIZATION=f'Bearer {token}')
        return client

    def test_users_are_added_to_role_groups(self):
        student = CustomUser.objects.create_user(
            username='group-student@example.com',
            email='group-student@example.com',
            password='strong-password',
            user_type='student',
        )
        business = CustomUser.objects.create_user(
            username='group-business@example.com',
            email='group-business@example.com',
            password='strong-password',
            user_type='business',
        )

        self.assertTrue(student.groups.filter(name='Students').exists())
        self.assertFalse(student.groups.filter(name='Businesses').exists())
        self.assertTrue(business.groups.filter(name='Businesses').exists())
        self.assertFalse(business.groups.filter(name='Students').exists())

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
        profile = StudentProfile.objects.get(user=student)
        profile.college = 'Test College'
        profile.save()

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

        student.refresh_from_db()
        self.assertEqual(student.student_profile.college, 'Test College')
        self.assertEqual(
            business.business_profile.business_name,
            'Test Business',
        )

    def test_student_profile_can_be_updated(self):
        student = CustomUser.objects.create_user(
            username='edit-student@example.com',
            email='edit-student@example.com',
            password='strong-password',
            user_type='student',
        )
        profile = StudentProfile.objects.get(user=student)
        profile.full_name = 'Old Name'
        profile.college = 'Old College'
        profile.save()
        client = self.login_api(student)
        response = client.patch(
            '/api/accounts/profile/student/',
            json.dumps({
                'full_name': 'New Name',
                'college': 'New College',
                'bio': 'I am ready to work.',
            }),
            content_type='application/json',
        )
        self.assertEqual(response.status_code, 200)
        profile = StudentProfile.objects.get(user=student)
        self.assertEqual(profile.full_name, 'New Name')
        self.assertEqual(profile.college, 'New College')

    def test_business_profile_can_be_updated(self):
        business = CustomUser.objects.create_user(
            username='edit-business@example.com',
            email='edit-business@example.com',
            password='strong-password',
            user_type='business',
        )
        BusinessProfile.objects.create(
            user=business,
            business_name='Old Business',
            contact_person='Old Person',
            phone='9800000000',
            location='Old Location',
            pan_number='987654321',
        )
        client = self.login_api(business)
        response = client.patch(
            '/api/accounts/profile/business/',
            json.dumps({
                'business_name': 'New Business',
                'location': 'Kathmandu',
            }),
            content_type='application/json',
        )
        self.assertEqual(response.status_code, 200)
        profile = BusinessProfile.objects.get(user=business)
        self.assertEqual(profile.business_name, 'New Business')
        self.assertEqual(profile.location, 'Kathmandu')

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
        profile = StudentProfile.objects.get(user=student)
        profile.college = 'Test College'
        profile.save()

        self.client.force_login(admin)
        response = self.client.get(
            f'/admin/accounts/customuser/{student.pk}/change/'
        )
        self.assertEqual(response.status_code, 200)
