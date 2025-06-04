from django.contrib.gis.db import models as gis_models
from django.contrib.auth.models import AbstractUser
from django.conf import settings
from django.utils.translation import gettext_lazy as _


class User(AbstractUser):
    """Custom user model that extends the default User model with additional fields."""
    is_medecin = models.BooleanField(
        _('medecin status'),
        default=False,
        help_text=_('Designates whether the user is a doctor or not.')
    )
    phone_number = models.CharField(
        _('phone number'),
        max_length=15,
        blank=True,
        help_text=_('User\'s phone number for communication')
    )
    date_of_birth = models.DateField(
        _('date of birth'),
        null=True,
        blank=True,
        help_text=_('User\'s date of birth')
    )
    gender = models.CharField(
        _('gender'),
        max_length=10,
        choices=[
            ('M', _('Male')),
            ('F', _('Female')),
            ('O', _('Other')),
        ],
        blank=True,
        help_text=_('User\'s gender')
    )
    address = models.TextField(
        _('address'),
        blank=True,
        help_text=_('User\'s physical address')
    )
    city = models.CharField(
        _('city'),
        max_length=100,
        blank=True,
        help_text=_('User\'s city of residence')
    )
    country = models.CharField(
        _('country'),
        max_length=100,
        default='Senegal',
        help_text=_('User\'s country of residence')
    )
    location = gis_models.PointField(
        _('location'),
        null=True,
        blank=True,
        srid=4326,
        help_text=_('Geographic location (longitude and latitude)')
    )
    profile_picture = models.ImageField(
        _('profile picture'),
        upload_to='profile_pics/',
        null=True,
        blank=True,
        help_text=_('User\'s profile picture')
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = _('user')
        verbose_name_plural = _('users')
        ordering = ['-date_joined']

    def __str__(self):
        return f"{self.get_full_name() or self.username} ({'Doctor' if self.is_medecin else 'Patient'})"


class DoctorProfile(models.Model):
    """Extended profile for doctors with professional information."""
    user = models.OneToOneField(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='doctor_profile',
        limit_choices_to={'is_medecin': True}
    )
    specialization = models.CharField(
        _('specialization'),
        max_length=100,
        help_text=_('Medical specialization of the doctor')
    )
    license_number = models.CharField(
        _('license number'),
        max_length=50,
        unique=True,
        help_text=_('Medical license number')
    )
    years_of_experience = models.PositiveIntegerField(
        _('years of experience'),
        default=0,
        help_text=_('Number of years of professional experience')
    )
    bio = models.TextField(
        _('biography'),
        blank=True,
        help_text=_('Professional biography and qualifications')
    )
    consultation_fee = models.DecimalField(
        _('consultation fee'),
        max_digits=10,
        decimal_places=2,
        default=0.00,
        help_text=_('Standard consultation fee in local currency')
    )
    languages = models.JSONField(
        _('languages spoken'),
        default=list,
        help_text=_('List of languages spoken by the doctor')
    )
    is_available = models.BooleanField(
        _('available for appointments'),
        default=True,
        help_text=_('Whether the doctor is currently accepting new patients')
    )
    rating = models.FloatField(
        _('rating'),
        default=0.0,
        help_text=_('Average rating from patient reviews')
    )
    review_count = models.PositiveIntegerField(
        _('review count'),
        default=0,
        help_text=_('Total number of reviews received')
    )

    class Meta:
        verbose_name = _('doctor profile')
        verbose_name_plural = _('doctor profiles')

    def __str__(self):
        return f"{self.user.get_full_name()} - {self.specialization}"


class PatientProfile(models.Model):
    """Extended profile for patients with medical information."""
    BLOOD_GROUPS = [
        ('A+', 'A+'), ('A-', 'A-'),
        ('B+', 'B+'), ('B-', 'B-'),
        ('AB+', 'AB+'), ('AB-', 'AB-'),
        ('O+', 'O+'), ('O-', 'O-'),
    ]

    user = models.OneToOneField(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='patient_profile',
        limit_choices_to={'is_medecin': False}
    )
    blood_group = models.CharField(
        _('blood group'),
        max_length=3,
        choices=BLOOD_GROUPS,
        blank=True,
        help_text=_('Patient\'s blood group')
    )
    height = models.DecimalField(
        _('height (cm)'),
        max_digits=5,
        decimal_places=2,
        null=True,
        blank=True,
        help_text=_('Height in centimeters')
    )
    weight = models.DecimalField(
        _('weight (kg)'),
        max_digits=5,
        decimal_places=2,
        null=True,
        blank=True,
        help_text=_('Weight in kilograms')
    )
    allergies = models.TextField(
        _('allergies'),
        blank=True,
        help_text=_('Any known allergies')
    )
    medical_history = models.TextField(
        _('medical history'),
        blank=True,
        help_text=_('Summary of medical history')
    )
    current_medications = models.TextField(
        _('current medications'),
        blank=True,
        help_text=_('Current medications being taken')
    )
    emergency_contact_name = models.CharField(
        _('emergency contact name'),
        max_length=100,
        blank=True,
        help_text=_('Name of emergency contact person')
    )
    emergency_contact_phone = models.CharField(
        _('emergency contact phone'),
        max_length=15,
        blank=True,
        help_text=_('Phone number of emergency contact person')
    )

    class Meta:
        verbose_name = _('patient profile')
        verbose_name_plural = _('patient profiles')

    def __str__(self):
        return f"{self.user.get_full_name()} - Patient"

    @property
    def bmi(self):
        """Calculate and return the Body Mass Index (BMI)."""
        if self.height and self.weight:
            # Convert height from cm to meters
            height_m = float(self.height) / 100
            return round(float(self.weight) / (height_m * height_m), 1)
        return None
