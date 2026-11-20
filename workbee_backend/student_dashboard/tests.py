from datetime import date, timedelta

from django.test import TestCase
from rest_framework.test import APIClient
from accounts.models import CustomUser
from .models import Gig, Application


class GigApiTests(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.student = CustomUser.objects.create_user(
            username='student@example.com',
            email='student@example.com',
            password='strong-password',
            user_type='student',
        )
        self.business = CustomUser.objects.create_user(
            username='business@example.com',
            email='business@example.com',
            password='strong-password',
            user_type='business',
            first_name='Example',
        )
        self.gig = Gig.objects.create(
            owner=self.business,
            title='Logo design',
            business_name='Example Studio',
            location='Kathmandu',
            budget_npr=4000,
            duration_days=5,
            due_date=date.today() + timedelta(days=7),
            description='Create a clean logo.',
            category='design',
        )

    def login(self, user):
        response = self.client.post('/api/accounts/login/', {
            'email': user.email,
            'password': 'strong-password',
        })
        self.assertEqual(response.status_code, 200)
        token = response.json()['access']
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {token}')

    def test_student_can_list_and_apply_for_gig_once(self):
        self.login(self.student)
        listed = self.client.get('/api/student-dashboard/gigs/')
        self.assertEqual(listed.status_code, 200)
        self.assertEqual(len(listed.json()), 1)

        first = self.client.post(
            f'/api/student-dashboard/gigs/{self.gig.id}/apply/',
            {'cover_letter': 'I can help.'},
            format='json',
        )
        self.assertEqual(first.status_code, 201)

        second = self.client.post(
            f'/api/student-dashboard/gigs/{self.gig.id}/apply/',
            {'cover_letter': 'Still interested.'},
            format='json',
        )
        self.assertEqual(second.status_code, 409)
        self.assertEqual(Application.objects.filter(student=self.student, gig=self.gig).count(), 1)

    def test_business_can_post_gig_but_student_cannot(self):
        self.login(self.business)
        created = self.client.post('/api/student-dashboard/gigs/', {
            'title': 'Website content',
            'location': 'Pokhara',
            'budget_npr': 3000,
            'duration_days': 3,
            'due_date': (date.today() + timedelta(days=5)).isoformat(),
            'description': 'Write product pages.',
            'category': 'writing',
        }, format='json')
        self.assertEqual(created.status_code, 201)

        self.login(self.student)
        denied = self.client.post('/api/student-dashboard/gigs/', {
            'title': 'Not allowed',
            'location': 'Kathmandu',
            'budget_npr': 1000,
            'duration_days': 2,
            'due_date': (date.today() + timedelta(days=5)).isoformat(),
        }, format='json')
        self.assertEqual(denied.status_code, 403)
