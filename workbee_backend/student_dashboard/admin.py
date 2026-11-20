from django.contrib import admin
from .models import Gig, Application, Project


@admin.register(Gig)
class GigAdmin(admin.ModelAdmin):
    list_display = ('title', 'business_name', 'category', 'budget_npr', 'due_date', 'is_active')
    list_filter = ('category', 'work_type', 'is_active')
    search_fields = ('title', 'business_name', 'location', 'description')
    autocomplete_fields = ('owner',)


@admin.register(Application)
class ApplicationAdmin(admin.ModelAdmin):
    list_display = ('student', 'gig', 'status', 'applied_at')
    list_filter = ('status', 'applied_at')
    search_fields = ('student__email', 'gig__title')
    autocomplete_fields = ('student', 'gig')


@admin.register(Project)
class ProjectAdmin(admin.ModelAdmin):
    list_display = ('student', 'gig', 'status', 'rating')
    list_filter = ('status',)