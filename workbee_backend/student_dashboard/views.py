from django.db.models import Avg, Q
from django.db import IntegrityError
from django.utils import timezone
from django.utils.dateparse import parse_date
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView
from .models import Gig, Application, Project


def gig_payload(gig, include_description=False):
    payload = {
        'id': gig.id,
        'title': gig.title,
        'business_name': gig.business_name,
        'location': gig.location,
        'budget_npr': f"NPR {gig.budget_npr:,}",
        'budget': gig.budget_npr,
        'duration': f"{gig.duration_days} days",
        'due_date': gig.due_date.isoformat(),
        'category': gig.category,
        'category_label': dict(Gig.CATEGORY_CHOICES).get(gig.category, gig.category),
        'work_type': dict(Gig.WORK_TYPE_CHOICES).get(gig.work_type, gig.work_type),
    }
    if include_description:
        payload['description'] = gig.description
    return payload


class GigListView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        gigs = Gig.objects.filter(
            is_active=True,
            due_date__gte=timezone.localdate(),
        ).order_by('-created_at')

        category = request.query_params.get('category')
        if category:
            gigs = gigs.filter(category__iexact=category)

        search = request.query_params.get('search', '').strip()
        if search:
            gigs = gigs.filter(
                Q(title__icontains=search)
                | Q(business_name__icontains=search)
                | Q(description__icontains=search)
            )

        return Response([gig_payload(gig, include_description=True) for gig in gigs])

    def post(self, request):
        if request.user.user_type != 'business':
            return Response(
                {'error': 'Only business accounts can post gigs.'},
                status=status.HTTP_403_FORBIDDEN,
            )

        required = ['title', 'location', 'budget_npr', 'duration_days', 'due_date']
        missing = [field for field in required if field not in request.data]
        if missing:
            return Response(
                {'error': f"Missing required fields: {', '.join(missing)}"},
                status=status.HTTP_400_BAD_REQUEST,
            )

        try:
            budget_npr = int(request.data['budget_npr'])
            duration_days = int(request.data['duration_days'])
        except (TypeError, ValueError):
            return Response(
                {'error': 'Budget and duration must be valid numbers.'},
                status=status.HTTP_400_BAD_REQUEST,
            )
        if budget_npr < 1 or duration_days < 1:
            return Response(
                {'error': 'Budget and duration must be greater than zero.'},
                status=status.HTTP_400_BAD_REQUEST,
            )
        if not str(request.data['title']).strip():
            return Response(
                {'error': 'Gig title cannot be empty.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        due_date = parse_date(str(request.data['due_date']))
        if due_date is None:
            return Response(
                {'error': 'Due date must use YYYY-MM-DD format.'},
                status=status.HTTP_400_BAD_REQUEST,
            )
        if due_date < timezone.localdate():
            return Response(
                {'error': 'Due date cannot be in the past.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        category = str(request.data.get('category', 'general'))
        if category not in dict(Gig.CATEGORY_CHOICES):
            return Response(
                {'error': 'Invalid gig category.'},
                status=status.HTTP_400_BAD_REQUEST,
            )
        work_type = str(request.data.get('work_type', 'flexible'))
        if work_type not in dict(Gig.WORK_TYPE_CHOICES):
            return Response(
                {'error': 'Invalid work type.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        business_name = (
            request.user.business_name.strip()
            if request.user.business_name.strip()
            else request.user.first_name.strip() or 'Business'
        )

        gig = Gig.objects.create(
            owner=request.user,
            title=str(request.data['title']).strip(),
            business_name=business_name,
            location=str(request.data['location']).strip(),
            budget_npr=budget_npr,
            duration_days=duration_days,
            due_date=due_date,
            description=str(request.data.get('description', '')).strip(),
            category=category,
            work_type=work_type,
        )
        return Response(gig_payload(gig, include_description=True), status=status.HTTP_201_CREATED)


class GigApplyView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, gig_id):
        if request.user.user_type != 'student':
            return Response(
                {'error': 'Only student accounts can apply for gigs.'},
                status=status.HTTP_403_FORBIDDEN,
            )

        gig = Gig.objects.filter(id=gig_id, is_active=True).first()
        if not gig:
            return Response({'error': 'Gig not found.'}, status=status.HTTP_404_NOT_FOUND)
        if gig.due_date < timezone.localdate():
            return Response({'error': 'This gig is no longer accepting applications.'}, status=status.HTTP_400_BAD_REQUEST)
        if Application.objects.filter(student=request.user, gig=gig).exists():
            return Response({'error': 'You have already applied for this gig.'}, status=status.HTTP_409_CONFLICT)

        try:
            application = Application.objects.create(
                student=request.user,
                gig=gig,
                cover_letter=str(request.data.get('cover_letter', '')).strip(),
            )
        except IntegrityError:
            return Response({'error': 'You have already applied for this gig.'}, status=status.HTTP_409_CONFLICT)

        return Response({
            'message': 'Application submitted successfully.',
            'application': {
                'id': application.id,
                'gig_id': gig.id,
                'status': application.status,
                'applied_at': application.applied_at.isoformat(),
            },
        }, status=status.HTTP_201_CREATED)


class MyApplicationsView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        applications = Application.objects.filter(student=request.user).select_related('gig').order_by('-applied_at')
        return Response([
            {
                'id': application.id,
                'gig': gig_payload(application.gig, include_description=True),
                'status': application.status,
                'cover_letter': application.cover_letter,
                'applied_at': application.applied_at.isoformat(),
            }
            for application in applications
        ])

class StudentDashboardView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        user = request.user

        first_name = user.first_name.strip()
        if not first_name:
            first_name = user.email.split('@')[0]

        last_name = user.last_name.strip()
        initials = first_name[0].upper()
        if last_name:
            initials += last_name[0].upper()

        checks = [
            bool(user.first_name),
            bool(user.email),
            bool(user.college),
            bool(user.bio),
            bool(user.portfolio_url),
        ]
        completion = int((sum(checks) / len(checks)) * 100)
        if not user.portfolio_url:
            profile_tip = "Add one more portfolio sample to stand out."
        elif not user.bio:
            profile_tip = "Add a short bio so businesses know your skills."
        else:
            profile_tip = "Your profile is complete and ready for top gigs."

        gigs_qs = Gig.objects.filter(
            is_active=True,
            due_date__gte=timezone.localdate(),
        ).order_by('-created_at')[:5]
        recommended_gigs = [
            gig_payload(gig, include_description=True)
            for gig in gigs_qs
        ]

        applications = Application.objects.filter(student=user)
        projects = Project.objects.filter(student=user)

        avg_rating = projects.filter(rating__isnull=False).aggregate(Avg('rating'))
        avg_rating = avg_rating['rating__avg']
        if avg_rating is None:
            avg_rating = 0.0

        return Response({
            'first_name': first_name,
            'initials': initials,
            'email': user.email,
            'is_verified': getattr(user, 'is_verified', True),
            'profile_completion': completion,
            'profile_tip': profile_tip,
            'recommended_gigs': recommended_gigs,
            'applications_detail': [
                {
                    'gig_title': application.gig.title,
                    'business_name': application.gig.business_name,
                    'status': application.status,
                    'status_label': dict(Application.STATUS_CHOICES).get(application.status, application.status),
                    'applied_at': application.applied_at.isoformat(),
                }
                for application in applications.select_related('gig').order_by('-applied_at')
            ],
            'projects_detail': [
                {
                    'gig_title': project.gig.title,
                    'business_name': project.gig.business_name,
                    'status': project.status,
                    'status_label': dict(Project.STATUS_CHOICES).get(project.status, project.status),
                    'rating': float(project.rating) if project.rating is not None else None,
                }
                for project in projects.select_related('gig').order_by('-id')
            ],
            'applications': {
                'total': applications.count(),
                'pending': applications.filter(status='pending').count(),
                'shortlisted': applications.filter(status='shortlisted').count(),
            },
            'projects': {
                'total': projects.count(),
                'active': projects.filter(status='active').count(),
                'approved': projects.filter(status='approved').count(),
            },
            'passport': {
                'verified_projects': projects.filter(status='approved').count(),
                'average_rating': round(float(avg_rating), 1),
            }
        })