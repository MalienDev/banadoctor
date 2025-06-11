from django.contrib import admin
from .models import Appointment, AppointmentReminder, DoctorSchedule, TimeSlot
from django.utils.html import format_html
from django.utils import timezone

@admin.register(Appointment)
class AppointmentAdmin(admin.ModelAdmin):
    list_display = ('id', 'patient_info', 'doctor_info', 'scheduled_date', 'start_time', 'status', 'appointment_type')
    list_filter = ('status', 'appointment_type', 'scheduled_date')
    search_fields = ('patient__email', 'patient__first_name', 'patient__last_name',
                   'doctor__email', 'doctor__first_name', 'doctor__last_name')
    date_hierarchy = 'scheduled_date'
    ordering = ('-scheduled_date', '-start_time')
    
    fieldsets = (
        ('Rendez-vous', {
            'fields': ('patient', 'doctor', 'appointment_type', 'status')
        }),
        ('Date et Heure', {
            'fields': ('scheduled_date', 'start_time', 'end_time')
        }),
        ('Détails', {
            'fields': ('reason', 'notes', 'symptoms', 'diagnosis', 'prescription')
        }),
    )
    
    def patient_info(self, obj):
        return f"{obj.patient.get_full_name()} ({obj.patient.email})"
    patient_info.short_description = 'Patient'
    
    def doctor_info(self, obj):
        return f"Dr. {obj.doctor.get_full_name()}"
    doctor_info.short_description = 'Médecin'

@admin.register(AppointmentReminder)
class AppointmentReminderAdmin(admin.ModelAdmin):
    list_display = ('appointment', 'reminder_type', 'scheduled_time', 'is_sent', 'sent_time')
    list_filter = ('reminder_type', 'is_sent')
    search_fields = ('appointment__patient__email', 'appointment__patient__first_name', 
                   'appointment__patient__last_name')
    date_hierarchy = 'scheduled_time'
    ordering = ('-scheduled_time',)
    
    def has_add_permission(self, request):
        return False  # Les rappels sont généralement créés automatiquement

@admin.register(DoctorSchedule)
class DoctorScheduleAdmin(admin.ModelAdmin):
    list_display = ('doctor', 'get_day_of_week_display', 'start_time', 'end_time', 'is_working_day')
    list_filter = ('day_of_week', 'is_working_day')
    search_fields = ('doctor__email', 'doctor__first_name', 'doctor__last_name')
    ordering = ('doctor', 'day_of_week', 'start_time')

@admin.register(TimeSlot)
class TimeSlotAdmin(admin.ModelAdmin):
    list_display = ('doctor', 'date', 'start_time', 'end_time', 'is_available', 'has_appointment')
    list_filter = ('date', 'is_available')
    search_fields = ('doctor__email', 'doctor__first_name', 'doctor__last_name')
    date_hierarchy = 'date'
    ordering = ('-date', 'start_time')
    
    def has_appointment(self, obj):
        return obj.appointment is not None
    has_appointment.boolean = True
    has_appointment.short_description = 'Réservé'
