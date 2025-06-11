import logging
from django.db.models.signals import post_save, pre_save, post_delete
from django.dispatch import receiver
from django.utils import timezone
from django.core.mail import send_mail
from django.template.loader import render_to_string
from django.conf import settings

from .models import Appointment, AppointmentReminder, TimeSlot

logger = logging.getLogger(__name__)

@receiver(post_save, sender=Appointment)
def handle_appointment_save(sender, instance, created, **kwargs):
    """
    Handle post-save signals for the Appointment model.
    Sends notifications when an appointment is created or updated.
    """
    if created:
        # New appointment created
        logger.info(f"New appointment created: {instance}")
        
        # Create a reminder for the appointment
        reminder_time = instance.scheduled_date - timezone.timedelta(hours=24)
        
        # Only create reminder if it's in the future
        if reminder_time > timezone.now():
            AppointmentReminder.objects.create(
                appointment=instance,
                reminder_type='email',  # or get from user preferences
                scheduled_time=reminder_time
            )
        
        # Send confirmation email
        send_appointment_confirmation(instance)
        
    else:
        # Existing appointment updated
        logger.info(f"Appointment updated: {instance}")
        
        # Check if status changed
        if 'status' in instance.get_dirty_fields():
            send_appointment_status_update(instance)

@receiver(pre_save, sender=Appointment)
def handle_appointment_pre_save(sender, instance, **kwargs):
    """
    Handle pre-save signals for the Appointment model.
    Validates appointment changes and updates related models.
    """
    if instance.pk:
        # Existing appointment being updated
        old_instance = Appointment.objects.get(pk=instance.pk)
        
        # If time or date changed, update the related TimeSlot
        if (instance.scheduled_date != old_instance.scheduled_date or
            instance.start_time != old_instance.start_time or
            instance.end_time != old_instance.end_time):
            
            # Free up the old time slot
            TimeSlot.objects.filter(appointment=instance).update(is_available=True)
            
            # Find and reserve the new time slot
            new_slot = TimeSlot.objects.filter(
                doctor=instance.doctor,
                date=instance.scheduled_date,
                start_time=instance.start_time,
                end_time=instance.end_time,
                is_available=True
            ).first()
            
            if new_slot:
                new_slot.is_available = False
                new_slot.appointment = instance
                new_slot.save()

@receiver(post_save, sender=TimeSlot)
def handle_timeslot_save(sender, instance, created, **kwargs):
    """
    Handle post-save signals for the TimeSlot model.
    Ensures time slots don't overlap.
    """
    if created and not instance.is_available:
        # Mark overlapping time slots as unavailable
        TimeSlot.objects.filter(
            doctor=instance.doctor,
            date=instance.date,
            start_time__lt=instance.end_time,
            end_time__gt=instance.start_time
        ).exclude(pk=instance.pk).update(is_available=False)

def send_appointment_confirmation(appointment):
    """
    Send a confirmation email for a new appointment.
    """
    if not settings.SEND_EMAILS:
        return
    
    subject = f"Confirmation de rendez-vous - {appointment.get_appointment_type_display()}"
    
    # Render email templates
    context = {
        'appointment': appointment,
        'doctor': appointment.doctor,
        'patient': appointment.patient,
    }
    
    text_content = render_to_string('emails/appointment_confirmation.txt', context)
    html_content = render_to_string('emails/appointment_confirmation.html', context)
    
    try:
        send_mail(
            subject=subject,
            message=text_content,
            from_email=settings.DEFAULT_FROM_EMAIL,
            recipient_list=[appointment.patient.email],
            html_message=html_content,
            fail_silently=False,
        )
        logger.info(f"Appointment confirmation email sent to {appointment.patient.email}")
    except Exception as e:
        logger.error(f"Failed to send appointment confirmation email: {e}")

def send_appointment_status_update(appointment):
    """
    Send a notification when an appointment status changes.
    """
    if not settings.SEND_EMAILS:
        return
    
    subject = f"Mise à jour de votre rendez-vous - {appointment.get_status_display()}"
    
    context = {
        'appointment': appointment,
        'status_display': appointment.get_status_display(),
        'patient': appointment.patient,
    }
    
    text_content = render_to_string('emails/appointment_status_update.txt', context)
    html_content = render_to_string('emails/appointment_status_update.html', context)
    
    try:
        send_mail(
            subject=subject,
            message=text_content,
            from_email=settings.DEFAULT_FROM_EMAIL,
            recipient_list=[appointment.patient.email],
            html_message=html_content,
            fail_silently=False,
        )
        logger.info(f"Appointment status update email sent to {appointment.patient.email}")
    except Exception as e:
        logger.error(f"Failed to send appointment status update email: {e}")
