from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from .models import CustomUser, StudentProfile, BusinessProfile


class StudentProfileInline(admin.StackedInline):
    model = StudentProfile
    extra = 0
    max_num = 1


class BusinessProfileInline(admin.StackedInline):
    model = BusinessProfile
    extra = 0
    max_num = 1


@admin.register(CustomUser)
class CustomUserAdmin(UserAdmin):
    list_display = ('email', 'username', 'user_type', 'is_active', 'is_staff')
    list_filter = ('user_type', 'is_active', 'is_staff')
    search_fields = ('email', 'username', 'first_name', 'last_name')
    ordering = ('email',)
    fieldsets = UserAdmin.fieldsets + (
        ('WorkBee account type', {
            'fields': ('user_type',),
        }),
    )
    add_fieldsets = (
        (None, {
            'classes': ('wide',),
            'fields': ('email', 'username', 'password1', 'password2', 'user_type', 'is_active'),
        }),
    )

    def get_inline_instances(self, request, obj=None):
        if obj is None:
            return []
        if obj.user_type == 'student':
            return [StudentProfileInline(self.model, self.admin_site)]
        if obj.user_type == 'business':
            return [BusinessProfileInline(self.model, self.admin_site)]
        return []
