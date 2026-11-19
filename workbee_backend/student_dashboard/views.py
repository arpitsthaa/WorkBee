from django.db.models import Avg
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView
from .models import Gig, Application, Project

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

        applications = Application.objects.filter(student=user)
        projects = Project.objects.filter(student=user)

        avg_rating = projects.filter(rating__isnull=False).aggregate(Avg('rating'))
        avg_rating = avg_rating['rating__avg']
        if avg_rating is None:
            avg_rating = 0.0

        return Response({
            'first_name': first_name,
            'initials': initials,
            'is_verified': getattr(user, 'is_verified', True),
            'profile_completion': completion,
            'profile_tip': profile_tip,
            'recommended_gigs': recommended_gigs,
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