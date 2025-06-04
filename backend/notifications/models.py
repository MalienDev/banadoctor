import json
from django.db import models
from django.conf import settings
from django.utils import timezone
from django.utils.translation import gettext_lazy as _
from django.core.serializers.json import DjangoJSONEncoder
from django.db.models import JSONField


class Notification(models.Model):
    """Base notification model for storing all types of notifications."""
    NOTIFICATION_TYPES = [
        ('appointment_reminder', _('Appointment Reminder')),
        ('appointment_confirmation', _('Appointment Confirmation')),
        ('appointment_cancellation', _('Appointment Cancellation')),
        ('appointment_reschedule', _('Appointment Reschedule')),
        ('payment_received', _('Payment Received')),
        ('payment_failed', _('Payment Failed')),
        ('prescription_ready', _('Prescription Ready')),
        ('test_result_ready', _('Test Result Ready')),
        ('doctor_message', _('Message from Doctor')),
        ('patient_message', _('Message from Patient')),
        ('system_alert', _('System Alert')),
        ('promotional', _('Promotional')),
    ]

    CHANNEL_CHOICES = [
        ('email', _('Email')),
        ('sms', _('SMS')),
        ('push', _('Push Notification')),
        ('in_app', _('In-App Notification')),
        ('ussd', _('USSD')),
    ]

    PRIORITY_CHOICES = [
        ('low', _('Low')),
        ('medium', _('Medium')),
        ('high', _('High')),
        ('urgent', _('Urgent')),
    ]

    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='notifications',
        help_text=_('Recipient of the notification')
    )
    notification_type = models.CharField(
        _('notification type'),
        max_length=50,
        choices=NOTIFICATION_TYPES,
        help_text=_('Type of notification')
    )
    title = models.CharField(
        _('title'),
        max_length=255,
        help_text=_('Notification title')
    )
    message = models.TextField(
        _('message'),
        help_text=_('Notification message content')
    )
    data = JSONField(
        _('data'),
        encoder=DjangoJSONEncoder,
        default=dict,
        blank=True,
        help_text=_('Additional data related to the notification')
    )
    channels = JSONField(
        _('channels'),
        default=list,
        help_text=_('Channels through which the notification was sent')
    )
    priority = models.CharField(
        _('priority'),
        max_length=10,
        choices=PRIORITY_CHOICES,
        default='medium',
        help_text=_('Priority level of the notification')
    )
    is_read = models.BooleanField(
        _('is read'),
        default=False,
        help_text=_('Whether the notification has been read')
    )
    scheduled_for = models.DateTimeField(
        _('scheduled for'),
        null=True,
        blank=True,
        help_text=_('When the notification is scheduled to be sent')
    )
    sent_at = models.DateTimeField(
        _('sent at'),
        null=True,
        blank=True,
        help_text=_('When the notification was actually sent')
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = _('notification')
        verbose_name_plural = _('notifications')
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['user', 'is_read']),
            models.Index(fields=['notification_type']),
            models.Index(fields=['scheduled_for']),
            models.Index(fields=['sent_at']),
        ]

    def __str__(self):
        return f"{self.get_notification_type_display()}: {self.title}"

    def mark_as_read(self):
        """Mark the notification as read."""
        self.is_read = True
        self.save(update_fields=['is_read', 'updated_at'])

    def mark_as_unread(self):
        """Mark the notification as unread."""
        self.is_read = False
        self.save(update_fields=['is_read', 'updated_at'])

    def send(self):
        """
        Send the notification through the specified channels.
        This method should be implemented by subclasses or called with appropriate handlers.
        """
        from .tasks import send_notification_async
        
        if not self.sent_at:
            self.sent_at = timezone.now()
            self.save(update_fields=['sent_at', 'updated_at'])
            
            # Send notification asynchronously
            send_notification_async.delay(self.id)


class SMSTemplate(models.Model):
    """Template for SMS notifications."""
    name = models.CharField(
        _('name'),
        max_length=100,
        unique=True,
        help_text=_('Unique name for the template')
    )
    slug = models.SlugField(
        _('slug'),
        max_length=100,
        unique=True,
        help_text=_('Unique identifier for the template')
    )
    template = models.TextField(
        _('template'),
        help_text=_('SMS template with placeholders in {curly_braces}')
    )
    description = models.TextField(
        _('description'),
        blank=True,
        help_text=_('Description of when and how this template is used')
    )
    is_active = models.BooleanField(
        _('is active'),
        default=True,
        help_text=_('Whether this template is active and can be used')
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = _('SMS template')
        verbose_name_plural = _('SMS templates')
        ordering = ['name']

    def __str__(self):
        return self.name

    def render(self, context=None):
        """
        Render the template with the given context.
        
        Args:
            context (dict): Dictionary of variables to use when rendering the template.
            
        Returns:
            str: Rendered template with placeholders replaced by context values.
        """
        if context is None:
            context = {}
            
        try:
            return self.template.format(**context)
        except KeyError as e:
            raise ValueError(f"Missing context variable: {e}")


class EmailTemplate(models.Model):
    """Template for email notifications."""
    name = models.CharField(
        _('name'),
        max_length=100,
        unique=True,
        help_text=_('Unique name for the template')
    )
    slug = models.SlugField(
        _('slug'),
        max_length=100,
        unique=True,
        help_text=_('Unique identifier for the template')
    )
    subject = models.CharField(
        _('subject'),
        max_length=255,
        help_text=_('Email subject template')
    )
    html_template = models.TextField(
        _('HTML template'),
        help_text=_('HTML email template with placeholders in {curly_braces}')
    )
    text_template = models.TextField(
        _('text template'),
        help_text=_('Plain text email template with placeholders in {curly_braces}')
    )
    description = models.TextField(
        _('description'),
        blank=True,
        help_text=_('Description of when and how this template is used')
    )
    is_active = models.BooleanField(
        _('is active'),
        default=True,
        help_text=_('Whether this template is active and can be used')
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = _('email template')
        verbose_name_plural = _('email templates')
        ordering = ['name']

    def __str__(self):
        return self.name

    def render_subject(self, context=None):
        """Render the email subject with the given context."""
        if context is None:
            context = {}
        return self.subject.format(**context)
    
    def render_html(self, context=None):
        """Render the HTML email body with the given context."""
        if context is None:
            context = {}
        return self.html_template.format(**context)
    
    def render_text(self, context=None):
        """Render the plain text email body with the given context."""
        if context is None:
            context = {}
        return self.text_template.format(**context)


class PushNotificationTemplate(models.Model):
    """Template for push notifications."""
    PLATFORM_CHOICES = [
        ('android', _('Android')),
        ('ios', _('iOS')),
        ('web', _('Web')),
        ('all', _('All Platforms')),
    ]
    
    name = models.CharField(
        _('name'),
        max_length=100,
        unique=True,
        help_text=_('Unique name for the template')
    )
    slug = models.SlugField(
        _('slug'),
        max_length=100,
        unique=True,
        help_text=_('Unique identifier for the template')
    )
    title_template = models.CharField(
        _('title template'),
        max_length=255,
        help_text=_('Push notification title template with placeholders in {curly_braces}')
    )
    message_template = models.TextField(
        _('message template'),
        help_text=_('Push notification message template with placeholders in {curly_braces}')
    )
    platform = models.CharField(
        _('platform'),
        max_length=10,
        choices=PLATFORM_CHOICES,
        default='all',
        help_text=_('Target platform for this push notification')
    )
    data = JSONField(
        _('data'),
        default=dict,
        blank=True,
        help_text=_('Additional data to be sent with the push notification')
    )
    description = models.TextField(
        _('description'),
        blank=True,
        help_text=_('Description of when and how this template is used')
    )
    is_active = models.BooleanField(
        _('is active'),
        default=True,
        help_text=_('Whether this template is active and can be used')
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = _('push notification template')
        verbose_name_plural = _('push notification templates')
        ordering = ['name']
        unique_together = ['slug', 'platform']

    def __str__(self):
        return f"{self.name} ({self.get_platform_display()})"

    def render_title(self, context=None):
        """Render the push notification title with the given context."""
        if context is None:
            context = {}
        return self.title_template.format(**context)
    
    def render_message(self, context=None):
        """Render the push notification message with the given context."""
        if context is None:
            context = {}
        return self.message_template.format(**context)


class NotificationPreference(models.Model):
    """User preferences for notification channels and types."""
    user = models.OneToOneField(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='notification_preferences',
        help_text=_('User these preferences belong to')
    )
    email_enabled = models.BooleanField(
        _('email notifications enabled'),
        default=True,
        help_text=_('Whether email notifications are enabled')
    )
    sms_enabled = models.BooleanField(
        _('SMS notifications enabled'),
        default=True,
        help_text=_('Whether SMS notifications are enabled')
    )
    push_enabled = models.BooleanField(
        _('push notifications enabled'),
        default=True,
        help_text=_('Whether push notifications are enabled')
    )
    in_app_enabled = models.BooleanField(
        _('in-app notifications enabled'),
        default=True,
        help_text=_('Whether in-app notifications are enabled')
    )
    notification_types = JSONField(
        _('notification types'),
        default=dict,
        help_text=_('Preferences for specific notification types')
    )
    quiet_hours_start = models.TimeField(
        _('quiet hours start'),
        null=True,
        blank=True,
        help_text=_('Start time for quiet hours (no notifications)')
    )
    quiet_hours_end = models.TimeField(
        _('quiet hours end'),
        null=True,
        blank=True,
        help_text=_('End time for quiet hours (no notifications)')
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = _('notification preference')
        verbose_name_plural = _('notification preferences')

    def __str__(self):
        return f"Notification preferences for {self.user.get_full_name()}"

    def is_quiet_time(self, dt=None):
        """
        Check if the given datetime (or now) is within quiet hours.
        
        Args:
            dt (datetime, optional): Datetime to check. Defaults to now.
            
        Returns:
            bool: True if within quiet hours, False otherwise.
        """
        if not all([self.quiet_hours_start, self.quiet_hours_end]):
            return False
            
        if dt is None:
            dt = timezone.now().time()
            
        if self.quiet_hours_start < self.quiet_hours_end:
            return self.quiet_hours_start <= dt <= self.quiet_hours_end
        else:  # Overnight
            return dt >= self.quiet_hours_start or dt <= self.quiet_hours_end
