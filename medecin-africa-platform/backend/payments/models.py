import uuid
from django.db import models
from django.conf import settings
from django.utils import timezone
from django.utils.translation import gettext_lazy as _
from django.core.validators import MinValueValidator
from django.db.models import Sum, F


class PaymentMethod(models.Model):
    """Available payment methods for the platform."""
    PAYMENT_METHOD_CHOICES = [
        ('mobile_money', _('Mobile Money')),
        ('credit_card', _('Credit Card')),
        ('debit_card', _('Debit Card')),
        ('bank_transfer', _('Bank Transfer')),
        ('cash', _('Cash')),
        ('insurance', _('Insurance')),
        ('wallet', _('Wallet')),
    ]
    
    name = models.CharField(
        _('name'),
        max_length=50,
        choices=PAYMENT_METHOD_CHOICES,
        unique=True,
        help_text=_('Name of the payment method')
    )
    is_active = models.BooleanField(
        _('is active'),
        default=True,
        help_text=_('Whether this payment method is currently available')
    )
    processing_fee_percentage = models.DecimalField(
        _('processing fee percentage'),
        max_digits=5,
        decimal_places=2,
        default=0.0,
        help_text=_('Percentage fee for processing this payment method')
    )
    minimum_amount = models.DecimalField(
        _('minimum amount'),
        max_digits=10,
        decimal_places=2,
        default=0.0,
        help_text=_('Minimum amount allowed for this payment method')
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = _('payment method')
        verbose_name_plural = _('payment methods')
        ordering = ['name']

    def __str__(self):
        return self.get_name_display()


class Transaction(models.Model):
    """Records all financial transactions in the system."""
    TRANSACTION_TYPES = [
        ('payment', _('Payment')),
        ('refund', _('Refund')),
        ('withdrawal', _('Withdrawal')),
        ('deposit', _('Deposit')),
    ]

    STATUS_CHOICES = [
        ('pending', _('Pending')),
        ('completed', _('Completed')),
        ('failed', _('Failed')),
        ('cancelled', _('Cancelled')),
    ]

    CURRENCY_CHOICES = [
        ('XOF', 'West African CFA Franc (XOF)'),
        ('USD', 'US Dollar (USD)'),
        ('EUR', 'Euro (EUR)'),
    ]

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    reference = models.CharField(
        _('reference'),
        max_length=100,
        unique=True,
        help_text=_('Unique transaction reference')
    )
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        related_name='transactions',
        help_text=_('User who initiated the transaction')
    )
    transaction_type = models.CharField(
        _('transaction type'),
        max_length=20,
        choices=TRANSACTION_TYPES,
        help_text=_('Type of transaction')
    )
    amount = models.DecimalField(
        _('amount'),
        max_digits=12,
        decimal_places=2,
        validators=[MinValueValidator(0.01)],
        help_text=_('Transaction amount')
    )
    currency = models.CharField(
        _('currency'),
        max_length=3,
        choices=CURRENCY_CHOICES,
        default='XOF',
        help_text=_('Currency code')
    )
    fee = models.DecimalField(
        _('fee'),
        max_digits=10,
        decimal_places=2,
        default=0.0,
        help_text=_('Transaction fee')
    )
    payment_method = models.ForeignKey(
        PaymentMethod,
        on_delete=models.PROTECT,
        related_name='transactions',
        help_text=_('Payment method used')
    )
    status = models.CharField(
        _('status'),
        max_length=20,
        choices=STATUS_CHOICES,
        default='pending',
        help_text=_('Current status of the transaction')
    )
    metadata = models.JSONField(
        _('metadata'),
        default=dict,
        blank=True,
        help_text=_('Additional metadata for the transaction')
    )
    description = models.TextField(
        _('description'),
        blank=True,
        help_text=_('Description of the transaction')
    )
    processed_at = models.DateTimeField(
        _('processed at'),
        null=True,
        blank=True,
        help_text=_('When the transaction was processed')
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = _('transaction')
        verbose_name_plural = _('transactions')
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['reference']),
            models.Index(fields=['user', 'status']),
            models.Index(fields=['transaction_type', 'status']),
        ]

    def __str__(self):
        return f"{self.get_transaction_type_display()}: {self.amount} {self.currency} ({self.get_status_display()})"

    def save(self, *args, **kwargs):
        """Generate reference and update timestamps before saving."""
        if not self.reference:
            self.reference = f"TXN-{timezone.now().strftime('%Y%m%d')}-{str(uuid.uuid4())[:8].upper()}"
            
        if self.status == 'completed' and not self.processed_at:
            self.processed_at = timezone.now()
            
        super().save(*args, **kwargs)


class Invoice(models.Model):
    """Invoices for payments made on the platform."""
    INVOICE_STATUS = [
        ('draft', _('Draft')),
        ('unpaid', _('Unpaid')),
        ('partially_paid', _('Partially Paid')),
        ('paid', _('Paid')),
        ('cancelled', _('Cancelled')),
    ]

    BILLING_TYPES = [
        ('appointment', _('Appointment')),
        ('consultation', _('Consultation')),
        ('procedure', _('Medical Procedure')),
        ('medication', _('Medication')),
    ]

    invoice_number = models.CharField(
        _('invoice number'),
        max_length=50,
        unique=True,
        help_text=_('Unique invoice number')
    )
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.PROTECT,
        related_name='invoices',
        help_text=_('User who is being billed')
    )
    billing_type = models.CharField(
        _('billing type'),
        max_length=20,
        choices=BILLING_TYPES,
        help_text=_('Type of billing')
    )
    reference_id = models.CharField(
        _('reference ID'),
        max_length=100,
        blank=True,
        help_text=_('ID of the referenced item (e.g., appointment ID)')
    )
    status = models.CharField(
        _('status'),
        max_length=20,
        choices=INVOICE_STATUS,
        default='draft',
        help_text=_('Current status of the invoice')
    )
    subtotal = models.DecimalField(
        _('subtotal'),
        max_digits=12,
        decimal_places=2,
        default=0.0,
        help_text=_('Amount before taxes and fees')
    )
    tax_amount = models.DecimalField(
        _('tax amount'),
        max_digits=12,
        decimal_places=2,
        default=0.0,
        help_text=_('Tax amount')
    )
    total_amount = models.DecimalField(
        _('total amount'),
        max_digits=12,
        decimal_places=2,
        help_text=_('Total amount to be paid')
    )
    amount_paid = models.DecimalField(
        _('amount paid'),
        max_digits=12,
        decimal_places=2,
        default=0.0,
        help_text=_('Amount that has been paid')
    )
    currency = models.CharField(
        _('currency'),
        max_length=3,
        choices=Transaction.CURRENCY_CHOICES,
        default='XOF',
        help_text=_('Currency code')
    )
    due_date = models.DateField(
        _('due date'),
        help_text=_('Date when payment is due')
    )
    paid_date = models.DateTimeField(
        _('paid date'),
        null=True,
        blank=True,
        help_text=_('When the invoice was fully paid')
    )
    notes = models.TextField(
        _('notes'),
        blank=True,
        help_text=_('Additional notes about the invoice')
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = _('invoice')
        verbose_name_plural = _('invoices')
        ordering = ['-created_at']

    def __str__(self):
        return f"Invoice #{self.invoice_number} - {self.user.get_full_name()}"

    def save(self, *args, **kwargs):
        """Calculate totals and update status before saving."""
        if not self.invoice_number:
            self.invoice_number = f"INV-{timezone.now().strftime('%Y%m')}-{str(uuid.uuid4())[:8].upper()}"
        
        self.total_amount = self.subtotal + self.tax_amount
        
        # Update status based on payments
        if self.amount_paid <= 0:
            self.status = 'unpaid'
        elif self.amount_paid >= self.total_amount:
            self.status = 'paid'
            if not self.paid_date:
                self.paid_date = timezone.now()
        elif self.amount_paid > 0:
            self.status = 'partially_paid'
            
        super().save(*args, **kwargs)


class Wallet(models.Model):
    """User wallet for storing credit."""
    user = models.OneToOneField(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='wallet',
        help_text=_('User who owns this wallet')
    )
    balance = models.DecimalField(
        _('balance'),
        max_digits=12,
        decimal_places=2,
        default=0.0,
        help_text=_('Current wallet balance')
    )
    currency = models.CharField(
        _('currency'),
        max_length=3,
        choices=Transaction.CURRENCY_CHOICES,
        default='XOF',
        help_text=_('Currency of the wallet')
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = _('wallet')
        verbose_name_plural = _('wallets')

    def __str__(self):
        return f"{self.user.get_full_name()}'s Wallet - {self.balance} {self.currency}"

    def deposit(self, amount, reference=None):
        """
        Deposit funds into the wallet.
        
        Args:
            amount: The amount to deposit
            reference: Optional reference for the transaction
            
        Returns:
            Transaction: The created transaction
        """
        from .models import Transaction, PaymentMethod
        
        # Get or create the wallet payment method
        payment_method, _ = PaymentMethod.objects.get_or_create(
            name='wallet',
            defaults={'is_active': True}
        )
        
        # Create a deposit transaction
        transaction = Transaction.objects.create(
            reference=reference,
            user=self.user,
            transaction_type='deposit',
            amount=amount,
            currency=self.currency,
            payment_method=payment_method,
            status='completed',
            description=f"Wallet deposit of {amount} {self.currency}",
            metadata={'wallet_id': str(self.id)}
        )
        
        # Update wallet balance
        self.balance = F('balance') + amount
        self.save(update_fields=['balance', 'updated_at'])
        self.refresh_from_db()
        
        return transaction

    def withdraw(self, amount, reference=None):
        """
        Withdraw funds from the wallet.
        
        Args:
            amount: The amount to withdraw
            reference: Optional reference for the transaction
            
        Returns:
            Transaction: The created transaction if successful, None otherwise
        """
        if self.balance < amount:
            return None
            
        from .models import Transaction, PaymentMethod
        
        # Get or create the wallet payment method
        payment_method, _ = PaymentMethod.objects.get_or_create(
            name='wallet',
            defaults={'is_active': True}
        )
        
        # Create a withdrawal transaction
        transaction = Transaction.objects.create(
            reference=reference,
            user=self.user,
            transaction_type='withdrawal',
            amount=amount,
            currency=self.currency,
            payment_method=payment_method,
            status='completed',
            description=f"Wallet withdrawal of {amount} {self.currency}",
            metadata={'wallet_id': str(self.id)}
        )
        
        # Update wallet balance
        self.balance = F('balance') - amount
        self.save(update_fields=['balance', 'updated_at'])
        self.refresh_from_db()
        
        return transaction
