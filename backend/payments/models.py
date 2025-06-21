from django.db import models
from django.conf import settings
from appointments.models import Appointment
import uuid

class Payment(models.Model):
    session_id = models.CharField(max_length=255, blank=True, null=True, help_text="Stripe Checkout Session ID")
    """
    Represents a payment for an appointment.
    """
    class PaymentStatus(models.TextChoices):
        PENDING = 'pending', 'Pending'
        COMPLETED = 'completed', 'Completed'
        FAILED = 'failed', 'Failed'
        REFUNDED = 'refunded', 'Refunded'

    class PaymentMethod(models.TextChoices):
        CREDIT_CARD = 'credit_card', 'Credit Card'
        MOBILE_MONEY = 'mobile_money', 'Mobile Money'
        BANK_TRANSFER = 'bank_transfer', 'Bank Transfer'
        CASH = 'cash', 'Cash'

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    appointment = models.OneToOneField(Appointment, on_delete=models.CASCADE, related_name='payment')
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    status = models.CharField(max_length=20, choices=PaymentStatus.choices, default=PaymentStatus.PENDING)
    payment_method = models.CharField(max_length=20, choices=PaymentMethod.choices)
    transaction_id = models.CharField(max_length=100, blank=True, null=True, unique=True, help_text="The transaction ID from the payment gateway.")
    payment_provider = models.CharField(max_length=50, blank=True, null=True, help_text="e.g., Stripe, PayPal, CinetPay")
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"Payment {self.id} for Appointment {self.appointment.id} - {self.status}"

    class Meta:
        ordering = ['-created_at']
        verbose_name = "Payment"
        verbose_name_plural = "Payments"

