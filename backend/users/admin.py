
from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from .models import User, DoctorAvailability, DoctorSpecialization, DoctorEducation

class CustomUserAdmin(UserAdmin):
    list_display = ('email', 'first_name', 'last_name', 'user_type', 'is_staff')
    list_filter = ('user_type', 'is_staff', 'is_superuser', 'is_active')
    search_fields = ('email', 'first_name', 'last_name')
    ordering = ('email',)

    fieldsets = (
        (None, {'fields': ('email', 'password')}),
        ('Personal info', {'fields': ('first_name', 'last_name', 'phone_number')}),
        ('Permissions', {'fields': ('is_active', 'is_staff', 'is_superuser', 'user_permissions')}),
        ('Important dates', {'fields': ('last_login', 'date_joined')}),
        ('User Type', {'fields': ('user_type',)}),
    )

    add_fieldsets = (
        (None, {
            'classes': ('wide',),
            'fields': ('email', 'password1', 'password2', 'user_type'),
        }),
    )

@admin.register(DoctorAvailability)
class DoctorAvailabilityAdmin(admin.ModelAdmin):
    list_display = ('doctor', 'get_day_of_week_display', 'start_time', 'end_time', 'is_available')
    list_filter = ('day_of_week', 'is_available')
    search_fields = ('doctor__email', 'doctor__first_name', 'doctor__last_name')

@admin.register(DoctorSpecialization)
class DoctorSpecializationAdmin(admin.ModelAdmin):
    list_display = ('name', 'description')
    search_fields = ('name',)

@admin.register(DoctorEducation)
class DoctorEducationAdmin(admin.ModelAdmin):
    list_display = ('doctor', 'degree', 'institution', 'year_completed')
    search_fields = ('doctor__email', 'degree', 'institution')
    list_filter = ('year_completed',)

# Désenregistrer le modèle User par défaut s'il est déjà enregistré
from django.contrib.auth.models import Group
admin.site.unregister(Group)  # Optionnel : désenregistre le groupe par défaut si non utilisé

# Enregistrer notre modèle User personnalisé avec la classe d'administration personnalisée
admin.site.register(User, CustomUserAdmin)
