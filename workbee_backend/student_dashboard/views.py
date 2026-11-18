from django.db.models import Avg
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView
from .models import Gig, Application, Project

class StudentDashboardView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        user = request.user

        first_name = user.first_name.strip() if user.first_name else user.email.split('@')[0]
        last_initial = user.last_name.strip()[0].upper() if user.last_name.strip() else ''
        initials = f"{first_name[0].upper()}{last_initial}" if first_name else "WB"

        checks = [
            bool(user.first_name),
            bool(user.email),
            bool(user.college),
            bool(getattr(user, 'bio', '')),
            bool(getattr(user, 'portfolio_url', '')),
        ]
        completion = int((sum(checks) / len(checks)) * 100)
        if not getattr(user, 'portfolio_url', ''):
            profile_tip = "Add one more portfolio sample to stand out."
        elif not getattr(user, 'bio', ''):
            profile_tip = "Add a short bio so businesses know your skills."
        else:
            profile_tip = "Your profile is complete and ready for top gigs."

        gigs_qs = Gig.objects.filter(is_active=True).order_by('-created_at')[:5]
        recommended_gigs = [
            {
                'id': gig.id,
                'title': gig.title,
                'business_name': gig.business_name,
                'location': gig.location,
                'budget_npr': f"NPR {gig.budget_npr:,}",
                'duration': f"{gig.duration_days} days",
                'due_date': f"Due {gig.due_date.strftime('%d %b')}",
            }
            for gig in gigs_qs
        ]

        user_apps = Application.objects.filter(student=user)
        user_projects = Project.objects.filter(student=user)

        apps_total = user_apps.count()
        apps_pending = user_apps.filter(status='pending').count()
        apps_shortlisted = user_apps.filter(status='shortlisted').count()

        projects_total = user_projects.count()
        projects_active = user_projects.filter(status='active').count()
        projects_approved = user_projects.filter(status='approved').count()

        avg_rating = user_projects.filter(rating__isnull=False).aggregate(Avg('rating'))['rating__avg']
        formatted_rating = round(float(avg_rating), 1) if avg_rating is not None else 0.0

        return Response({
            'first_name': first_name,
            'initials': initials,
            'is_verified': getattr(user, 'is_verified', True),
            'profile_completion': completion,
            'profile_tip': profile_tip,
            'recommended_gigs': recommended_gigs,
            'applications': {
                'total': apps_total,
                'pending': apps_pending,
                'shortlisted': apps_shortlisted,
            },
            'projects': {
                'total': projects_total,
                'active': projects_active,
                'approved': projects_approved,
            },
            'passport': {
                'verified_projects': projects_approved,
                'average_rating': formatted_rating,
            }
        })