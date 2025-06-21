from django.db import models
from django.conf import settings
from django.contrib.contenttypes.fields import GenericForeignKey
from django.contrib.contenttypes.models import ContentType
import uuid

class Notification(models.Model):
    """
    Represents a notification for a user.
    Uses a generic relation to link to any model (e.g., Appointment, Payment).
    """
    class NotificationType(models.TextChoices):
        APPOINTMENT_CREATED = 'appointment_created', 'Appointment Created'
        APPOINTMENT_REMINDER = 'appointment_reminder', 'Appointment Reminder'
        APPOINTMENT_CANCELLED = 'appointment_cancelled', 'Appointment Cancelled'
        PAYMENT_SUCCESS = 'payment_success', 'Payment Successful'
        PAYMENT_FAILED = 'payment_failed', 'Payment Failed'
        ACCOUNT_VERIFIED = 'account_verified', 'Account Verified'
        NEW_MESSAGE = 'new_message', 'New Message'
        GENERAL = 'general', 'General'

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    recipient = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='notifications')
    message = models.TextField()
    notification_type = models.CharField(max_length=50, choices=NotificationType.choices)
    is_read = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    # Generic foreign key to link to the object that triggered the notification
    content_type = models.ForeignKey(ContentType, on_delete=models.CASCADE, null=True, blank=True)
    object_id = models.CharField(max_length=255, null=True, blank=True)
    content_object = GenericForeignKey('content_type', 'object_id')

    def __str__(self):
        return f"Notification for {self.recipient.email} - {self.notification_type}"

    class Meta:
        ordering = ['-created_at']
        verbose_name = "Notification"
        verbose_name_plural = "Notifications"
