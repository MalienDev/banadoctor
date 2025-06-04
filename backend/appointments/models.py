from django.db import models
from django.conf import settings
from django.utils.translation import gettext_lazy as _
from django.utils import timezone
from django.core.validators import MinValueValidator, MaxValueValidator


class TimeSlot(models.Model):
    """Available time slots for doctor appointments."""
    DAYS_OF_WEEK = [
        (0, _('Monday')),
        (1, _('Tuesday')),
        (2, _('Wednesday')),
        (3, _('Thursday')),
        (4, _('Friday')),
        (5, _('Saturday')),
        (6, _('Sunday')),
    ]

    doctor = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='time_slots',
        limit_choices_to={'is_medecin': True},
        help_text=_('Doctor who owns this time slot')
    )
    day_of_week = models.PositiveSmallIntegerField(
        _('day of week'),
        choices=DAYS_OF_WEEK,
        help_text=_('Day of the week for this time slot')
    )
    start_time = models.TimeField(
        _('start time'),
        help_text=_('Start time of the time slot')
    )
    end_time = models.TimeField(
        _('end time'),
        help_text=_('End time of the time slot')
    )
    is_recurring = models.BooleanField(
        _('is recurring'),
        default=True,
        help_text=_('Whether this time slot repeats weekly')
    )
    is_active = models.BooleanField(
        _('is active'),
        default=True,
        help_text=_('Whether this time slot is currently active')
    )
    max_patients = models.PositiveSmallIntegerField(
        _('maximum patients'),
        default=1,
        help_text=_('Maximum number of patients that can book this slot')
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = _('time slot')
        verbose_name_plural = _('time slots')
        ordering = ['day_of_week', 'start_time']
        unique_together = ['doctor', 'day_of_week', 'start_time', 'end_time']

    def __str__(self):
        return f"{self.doctor.get_full_name()} - {self.get_day_of_week_display()} {self.start_time.strftime('%H:%M')}-{self.end_time.strftime('%H:%M')}"


class Appointment(models.Model):
    """Appointment model for scheduling doctor visits."""
    STATUS_CHOICES = [
        ('scheduled', _('Scheduled')),
        ('confirmed', _('Confirmed')),
        ('completed', _('Completed')),
        ('cancelled', _('Cancelled')),
        ('no_show', _('No Show')),
    ]

    APPOINTMENT_TYPES = [
        ('consultation', _('Consultation')),
        ('follow_up', _('Follow-up')),
        ('checkup', _('Routine Checkup')),
        ('emergency', _('Emergency')),
        ('other', _('Other')),
    ]

    patient = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='patient_appointments',
        limit_choices_to={'is_medecin': False},
        help_text=_('Patient who booked the appointment')
    )
    doctor = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='doctor_appointments',
        limit_choices_to={'is_medecin': True},
        help_text=_('Doctor for the appointment')
    )
    time_slot = models.ForeignKey(
        TimeSlot,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='appointments',
        help_text=_('Time slot for the appointment')
    )
    appointment_date = models.DateField(
        _('appointment date'),
        help_text=_('Date of the appointment')
    )
    start_time = models.TimeField(
        _('start time'),
        help_text=_('Start time of the appointment')
    )
    end_time = models.TimeField(
        _('end time'),
        help_text=_('End time of the appointment')
    )
    status = models.CharField(
        _('status'),
        max_length=20,
        choices=STATUS_CHOICES,
        default='scheduled',
        help_text=_('Current status of the appointment')
    )
    appointment_type = models.CharField(
        _('appointment type'),
        max_length=20,
        choices=APPOINTMENT_TYPES,
        default='consultation',
        help_text=_('Type of appointment')
    )
    reason = models.TextField(
        _('reason for visit'),
        blank=True,
        help_text=_('Reason for the appointment')
    )
    symptoms = models.TextField(
        _('symptoms'),
        blank=True,
        help_text=_('Patient-reported symptoms')
    )
    notes = models.TextField(
        _('doctor notes'),
        blank=True,
        help_text=_('Doctor\'s notes about the appointment')
    )
    is_paid = models.BooleanField(
        _('is paid'),
        default=False,
        help_text=_('Whether the appointment has been paid for')
    )
    payment_amount = models.DecimalField(
        _('payment amount'),
        max_digits=10,
        decimal_places=2,
        null=True,
        blank=True,
        help_text=_('Amount to be paid for the appointment')
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    reminder_sent = models.BooleanField(
        _('reminder sent'),
        default=False,
        help_text=_('Whether a reminder has been sent for this appointment')
    )
    cancellation_reason = models.TextField(
        _('cancellation reason'),
        blank=True,
        help_text=_('Reason for cancellation if appointment was cancelled')
    )

    class Meta:
        verbose_name = _('appointment')
        verbose_name_plural = _('appointments')
        ordering = ['appointment_date', 'start_time']
        indexes = [
            models.Index(fields=['appointment_date', 'start_time']),
            models.Index(fields=['status']),
        ]

    def __str__(self):
        return f"{self.patient.get_full_name()} - {self.doctor.get_full_name()} - {self.appointment_date} {self.start_time}"

    @property
    def duration_minutes(self):
        """Calculate the duration of the appointment in minutes."""
        if not all([self.start_time, self.end_time]):
            return 0
        
        start = timezone.datetime.combine(self.appointment_date, self.start_time)
        end = timezone.datetime.combine(self.appointment_date, self.end_time)
        duration = end - start
        return int(duration.total_seconds() / 60)

    def is_upcoming(self):
        """Check if the appointment is in the future."""
        now = timezone.now()
        appointment_datetime = timezone.datetime.combine(
            self.appointment_date,
            self.start_time,
            tzinfo=timezone.get_current_timezone()
        )
        return appointment_datetime > now

    def can_be_cancelled(self):
        """Check if the appointment can be cancelled."""
        if self.status in ['cancelled', 'completed', 'no_show']:
            return False
            
        # Allow cancellation up to 24 hours before the appointment
        appointment_datetime = timezone.datetime.combine(
            self.appointment_date,
            self.start_time,
            tzinfo=timezone.get_current_timezone()
        )
        return (appointment_datetime - timezone.timedelta(hours=24)) > timezone.now()


class AppointmentReschedule(models.Model):
    """Model to track appointment rescheduling."""
    appointment = models.ForeignKey(
        Appointment,
        on_delete=models.CASCADE,
        related_name='reschedules',
        help_text=_('The appointment being rescheduled')
    )
    old_date = models.DateField(
        _('old date'),
        help_text=_('Original date of the appointment')
    )
    new_date = models.DateField(
        _('new date'),
        help_text=_('New date for the appointment')
    )
    old_start_time = models.TimeField(
        _('old start time'),
        help_text=_('Original start time')
    )
    new_start_time = models.TimeField(
        _('new start time'),
        help_text=_('New start time')
    )
    old_end_time = models.TimeField(
        _('old end time'),
        help_text=_('Original end time')
    )
    new_end_time = models.TimeField(
        _('new end time'),
        help_text=_('New end time')
    )
    reason = models.TextField(
        _('reason for rescheduling'),
        help_text=_('Reason for rescheduling the appointment')
    )
    requested_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        related_name='requested_reschedules',
        help_text=_('User who requested the reschedule')
    )
    status = models.CharField(
        _('status'),
        max_length=20,
        choices=[
            ('pending', _('Pending')),
            ('approved', _('Approved')),
            ('rejected', _('Rejected')),
        ],
        default='pending',
        help_text=_('Status of the reschedule request')
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = _('appointment reschedule')
        verbose_name_plural = _('appointment reschedules')
        ordering = ['-created_at']

    def __str__(self):
        return f"Reschedule request for {self.appointment} - {self.status}"


class DoctorAvailabilityException(models.Model):
    """Model to handle exceptions to regular doctor availability."""
    doctor = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='availability_exceptions',
        limit_choices_to={'is_medecin': True},
        help_text=_('Doctor with modified availability')
    )
    date = models.DateField(
        _('date'),
        help_text=_('Date of the availability exception')
    )
    is_available = models.BooleanField(
        _('is available'),
        default=False,
        help_text=_('Whether the doctor is available on this date')
    )
    all_day = models.BooleanField(
        _('all day'),
        default=False,
        help_text=_('If true, the doctor is unavailable all day')
    )
    start_time = models.TimeField(
        _('start time'),
        null=True,
        blank=True,
        help_text=_('Start time of unavailability (if not all day)')
    )
    end_time = models.TimeField(
        _('end time'),
        null=True,
        blank=True,
        help_text=_('End time of unavailability (if not all day)')
    )
    reason = models.CharField(
        _('reason'),
        max_length=255,
        blank=True,
        help_text=_('Reason for the availability exception')
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = _('doctor availability exception')
        verbose_name_plural = _('doctor availability exceptions')
        ordering = ['date']
        unique_together = ['doctor', 'date']

    def __str__(self):
        status = 'Available' if self.is_available else 'Unavailable'
        return f"{self.doctor.get_full_name()} - {self.date} - {status}"

    def clean(self):
        from django.core.exceptions import ValidationError
        
        if not self.all_day and (not self.start_time or not self.end_time):
            raise ValidationError({
                'start_time': 'Start time and end time are required when not an all-day exception.',
                'end_time': 'Start time and end time are required when not an all-day exception.'
            })
        
        if self.start_time and self.end_time and self.start_time >= self.end_time:
            raise ValidationError({
                'start_time': 'Start time must be before end time.',
                'end_time': 'End time must be after start time.'
            })
