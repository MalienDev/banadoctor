from rest_framework import serializers
from django.utils import timezone
from django.conf import settings
from .models import Appointment, AppointmentReminder, DoctorSchedule, TimeSlot
from users.models import User

class TimeSlotSerializer(serializers.ModelSerializer):
    """Serializer for TimeSlot model"""
    class Meta:
        model = TimeSlot
        fields = ['id', 'date', 'start_time', 'end_time', 'is_available']
        read_only_fields = ['is_available']

class DoctorScheduleSerializer(serializers.ModelSerializer):
    """Serializer for DoctorSchedule model"""
    day_name = serializers.CharField(source='get_day_of_week_display', read_only=True)
    
    class Meta:
        model = DoctorSchedule
        fields = ['id', 'day_of_week', 'day_name', 'start_time', 'end_time', 'is_working_day']

class AppointmentReminderSerializer(serializers.ModelSerializer):
    """Serializer for AppointmentReminder model"""
    class Meta:
        model = AppointmentReminder
        fields = ['id', 'reminder_type', 'scheduled_time', 'sent_time', 'is_sent']
        read_only_fields = ['sent_time', 'is_sent']

class AppointmentListSerializer(serializers.ModelSerializer):
    """Serializer for listing appointments"""
    patient_name = serializers.CharField(source='patient.get_full_name', read_only=True)
    doctor_name = serializers.CharField(source='doctor.get_full_name', read_only=True)
    status_display = serializers.CharField(source='get_status_display', read_only=True)
    type_display = serializers.CharField(source='get_appointment_type_display', read_only=True)
    
    class Meta:
        model = Appointment
        fields = [
            'id', 'scheduled_date', 'start_time', 'end_time', 'status', 'status_display',
            'appointment_type', 'type_display', 'patient_name', 'doctor_name', 'is_paid', 'amount'
        ]

class AppointmentCreateSerializer(serializers.ModelSerializer):
    """Serializer for creating appointments"""
    class Meta:
        model = Appointment
        fields = [
            'id', 'patient', 'doctor', 'scheduled_date', 'start_time', 'end_time',
            'appointment_type', 'reason', 'symptoms', 'amount'
        ]
        extra_kwargs = {
            'patient': {'required': False},
            'status': {'read_only': True},
            'is_paid': {'read_only': True},
        }
    
    def validate(self, data):
        # Set the patient to the current user if not provided
        if 'patient' not in data:
            data['patient'] = self.context['request'].user
        
        # Ensure the patient is a patient
        if not data['patient'].is_patient:
            raise serializers.ValidationError({"patient": "The selected user is not a patient."})
        
        # Ensure the doctor is a doctor
        if not data['doctor'].is_doctor:
            raise serializers.ValidationError({"doctor": "The selected user is not a doctor."})
        
        # Check if the appointment is in the past
        appointment_datetime = timezone.datetime.combine(
            data['scheduled_date'],
            data['start_time']
        )
        if appointment_datetime < timezone.now():
            raise serializers.ValidationError("Cannot schedule an appointment in the past.")
        
        return data

class AppointmentUpdateSerializer(serializers.ModelSerializer):
    """Serializer for updating appointments"""
    class Meta:
        model = Appointment
        fields = [
            'status', 'diagnosis', 'prescription', 'notes', 'is_paid', 'amount'
        ]
        read_only_fields = ['patient', 'doctor', 'scheduled_date', 'start_time', 'end_time']
    
    def validate_status(self, value):
        user = self.context['request'].user
        appointment = self.instance
        
        # Only allow doctors to update status to completed or no_show
        if value in ['completed', 'no_show'] and not user.is_doctor:
            raise serializers.ValidationError(
                "Only doctors can mark appointments as completed or no-show."
            )
        
        # Only allow cancelling future appointments
        if value == 'cancelled' and not appointment.is_upcoming:
            raise serializers.ValidationError(
                "Cannot cancel a past or already completed appointment."
            )
            
        return value

class DoctorAvailabilitySerializer(serializers.Serializer):
    """Serializer for doctor availability"""
    date = serializers.DateField()
    available_slots = serializers.ListField(
        child=serializers.DictField(
            child=serializers.TimeField(),
            allow_empty=True
        ),
        allow_empty=True
    )

class BookAppointmentSerializer(serializers.Serializer):
    """Serializer for booking an appointment"""
    doctor_id = serializers.PrimaryKeyRelatedField(
        queryset=User.objects.filter(user_type='doctor'),
        required=True
    )
    date = serializers.DateField(required=True)
    start_time = serializers.TimeField(required=True)
    end_time = serializers.TimeField(required=True)
    appointment_type = serializers.ChoiceField(
        choices=Appointment.APPOINTMENT_TYPE_CHOICES,
        default='consultation'
    )
    reason = serializers.CharField(required=False, allow_blank=True)
    symptoms = serializers.CharField(required=False, allow_blank=True)
    
    class Meta:
        fields = ['doctor_id', 'date', 'start_time', 'end_time', 'appointment_type', 'reason', 'symptoms']
    
    def validate(self, data):
        # Check if end time is after start time
        if data['start_time'] >= data['end_time']:
            raise serializers.ValidationError({
                "end_time": "End time must be after start time."
            })
        
        # Check if the selected time slot is available
        is_available = TimeSlot.objects.filter(
            doctor=data['doctor_id'],
            date=data['date'],
            start_time=data['start_time'],
            end_time=data['end_time'],
            is_available=True
        ).exists()
        
        if not is_available:
            raise serializers.ValidationError("The selected time slot is not available.")
        
        return data
