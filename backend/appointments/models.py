from django.db import models
from django.conf import settings
from django.utils import timezone
from django.core.validators import MinValueValidator, MaxValueValidator
from django.core.exceptions import ValidationError

class Appointment(models.Model):
    """Model representing a medical appointment"""
    STATUS_CHOICES = (
        ('pending', 'En attente'),
        ('confirmed', 'Confirmé'),
        ('completed', 'Terminé'),
        ('cancelled', 'Annulé'),
        ('no_show', 'Non venu'),
    )
    
    APPOINTMENT_TYPE_CHOICES = (
        ('consultation', 'Consultation'),
        ('follow_up', 'Suivi'),
        ('emergency', 'Urgence'),
        ('vaccination', 'Vaccination'),
        ('other', 'Autre'),
    )
    
    patient = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='patient_appointments',
        limit_choices_to={'user_type': 'patient'}
    )
    
    doctor = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='doctor_appointments',
        limit_choices_to={'user_type': 'doctor'}
    )
    
    appointment_type = models.CharField(
        max_length=20,
        choices=APPOINTMENT_TYPE_CHOICES,
        default='consultation'
    )
    
    status = models.CharField(
        max_length=20,
        choices=STATUS_CHOICES,
        default='pending'
    )
    
    scheduled_date = models.DateField()
    start_time = models.TimeField()
    end_time = models.TimeField()
    
    reason = models.TextField(blank=True, null=True)
    symptoms = models.TextField(blank=True, null=True)
    diagnosis = models.TextField(blank=True, null=True)
    prescription = models.TextField(blank=True, null=True)
    notes = models.TextField(blank=True, null=True)
    
    is_paid = models.BooleanField(default=False)
    amount = models.DecimalField(max_digits=10, decimal_places=2, default=0.00)
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        ordering = ['-scheduled_date', 'start_time']
        unique_together = ('doctor', 'scheduled_date', 'start_time')
    
    def __str__(self):
        return f"{self.patient.get_full_name()} - {self.doctor.get_full_name()} - {self.scheduled_date} {self.start_time}"
    
    def clean(self):
        """Validate appointment times"""
        if self.start_time >= self.end_time:
            raise ValidationError('End time must be after start time')
        
        if self.scheduled_date < timezone.now().date():
            raise ValidationError('Cannot schedule appointment in the past')
        
        # Check for overlapping appointments
        if self.pk is None:  # New appointment
            overlapping = Appointment.objects.filter(
                doctor=self.doctor,
                scheduled_date=self.scheduled_date,
                start_time__lt=self.end_time,
                end_time__gt=self.start_time,
                status__in=['pending', 'confirmed']
            ).exists()
        else:  # Existing appointment
            overlapping = Appointment.objects.filter(
                doctor=self.doctor,
                scheduled_date=self.scheduled_date,
                start_time__lt=self.end_time,
                end_time__gt=self.start_time,
                status__in=['pending', 'confirmed']
            ).exclude(pk=self.pk).exists()
            
        if overlapping:
            raise ValidationError('This time slot is already booked. Please choose another time.')
    
    def save(self, *args, **kwargs):
        self.full_clean()
        super().save(*args, **kwargs)
    
    @property
    def is_upcoming(self):
        """Check if the appointment is in the future"""
        from django.utils import timezone
        now = timezone.now()
        appointment_datetime = timezone.datetime.combine(
            self.scheduled_date,
            self.start_time
        )
        return appointment_datetime > now and self.status in ['pending', 'confirmed']
    
    @property
    def duration_minutes(self):
        """Calculate appointment duration in minutes"""
        from datetime import datetime
        start = datetime.combine(self.scheduled_date, self.start_time)
        end = datetime.combine(self.scheduled_date, self.end_time)
        return (end - start).seconds // 60

class AppointmentReminder(models.Model):
    """Model to track appointment reminders"""
    appointment = models.ForeignKey(
        Appointment,
        on_delete=models.CASCADE,
        related_name='reminders'
    )
    
    REMINDER_TYPE_CHOICES = (
        ('email', 'Email'),
        ('sms', 'SMS'),
        ('push', 'Push Notification'),
    )
    
    reminder_type = models.CharField(max_length=10, choices=REMINDER_TYPE_CHOICES)
    scheduled_time = models.DateTimeField()
    sent_time = models.DateTimeField(null=True, blank=True)
    is_sent = models.BooleanField(default=False)
    
    created_at = models.DateTimeField(auto_now_add=True)
    
    def __str__(self):
        return f"{self.get_reminder_type_display()} - {self.appointment}"

class DoctorSchedule(models.Model):
    """Model to store doctor's working hours"""
    DAYS_OF_WEEK = (
        (0, 'Monday'),
        (1, 'Tuesday'),
        (2, 'Wednesday'),
        (3, 'Thursday'),
        (4, 'Friday'),
        (5, 'Saturday'),
        (6, 'Sunday'),
    )
    
    doctor = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='schedules',
        limit_choices_to={'user_type': 'doctor'}
    )
    
    day_of_week = models.IntegerField(choices=DAYS_OF_WEEK)
    start_time = models.TimeField()
    end_time = models.TimeField()
    is_working_day = models.BooleanField(default=True)
    
    class Meta:
        ordering = ['day_of_week', 'start_time']
        unique_together = ('doctor', 'day_of_week')
    
    def __str__(self):
        return f"{self.doctor.get_full_name()} - {self.get_day_of_week_display()} {self.start_time} to {self.end_time}"
    
    def clean(self):
        if self.start_time >= self.end_time:
            raise ValidationError('End time must be after start time')

class TimeSlot(models.Model):
    """Model to manage available time slots for appointments"""
    doctor = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='time_slots',
        limit_choices_to={'user_type': 'doctor'}
    )
    
    date = models.DateField()
    start_time = models.TimeField()
    end_time = models.TimeField()
    is_available = models.BooleanField(default=True)
    appointment = models.OneToOneField(
        Appointment,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='time_slot'
    )
    
    class Meta:
        ordering = ['date', 'start_time']
        unique_together = ('doctor', 'date', 'start_time', 'end_time')
    
    def __str__(self):
        return f"{self.doctor.get_full_name()} - {self.date} {self.start_time} to {self.end_time}"
    
    def clean(self):
        if self.start_time >= self.end_time:
            raise ValidationError('End time must be after start time')
        
        # Check for overlapping time slots
        if self.pk is None:  # New time slot
            overlapping = TimeSlot.objects.filter(
                doctor=self.doctor,
                date=self.date,
                start_time__lt=self.end_time,
                end_time__gt=self.start_time,
                is_available=True
            ).exists()
        else:  # Existing time slot
            overlapping = TimeSlot.objects.filter(
                doctor=self.doctor,
                date=self.date,
                start_time__lt=self.end_time,
                end_time__gt=self.start_time,
                is_available=True
            ).exclude(pk=self.pk).exists()
            
        if overlapping:
            raise ValidationError('This time slot overlaps with an existing slot')
    
    def save(self, *args, **kwargs):
        self.full_clean()
        super().save(*args, **kwargs)
