from django.urls import path
from .views import (
    StudentDashboardView,
    GigListView,
    GigApplyView,
    MyApplicationsView,
)

urlpatterns = [
    path('', StudentDashboardView.as_view(), name='student_dashboard'),
    path('gigs/', GigListView.as_view(), name='gig_list'),
    path('gigs/<int:gig_id>/apply/', GigApplyView.as_view(), name='gig_apply'),
    path('applications/', MyApplicationsView.as_view(), name='my_applications'),
]