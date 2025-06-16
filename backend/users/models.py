from django.conf import settings # Import settings
from django.contrib.auth.models import AbstractUser, BaseUserManager
from django.db import models
from django.utils.translation import gettext_lazy as _

# Define a simple fallback for PointField when GIS is not available
class FallbackPointField(models.CharField):
    def __init__(self, *args, **kwargs):
        kwargs.pop('geography', None)  # Remove unsupported kwarg for CharField
        kwargs.setdefault('max_length', 255)  # Default max_length for CharField
        kwargs.setdefault('null', True)
        kwargs.setdefault('blank', True)
        super().__init__(*args, **kwargs)

# Try to import GIS models, fall back to regular models if not available
try:
    from django.contrib.gis.db import models as gis_models_real
    PointField = gis_models_real.PointField
    USING_GIS = True
except (ImportError, ModuleNotFoundError):
    PointField = FallbackPointField
    USING_GIS = False


class UserManager(BaseUserManager):
    """Custom user model manager where email is the unique identifier."""
    def create_user(self, email, password=None, **extra_fields):
        if not email:
            raise ValueError(_('The Email must be set'))
        email = self.normalize_email(email)
        user = self.model(email=email, **extra_fields)
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, email, password, **extra_fields):
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)
        extra_fields.setdefault('is_active', True)

        if extra_fields.get('is_staff') is not True:
            raise ValueError(_('Superuser must have is_staff=True.'))
        if extra_fields.get('is_superuser') is not True:
            raise ValueError(_('Superuser must have is_superuser=True.'))
        return self.create_user(email, password, **extra_fields)

class User(AbstractUser):
    """Custom user model that supports using email instead of username"""
    USER_TYPE_CHOICES = (
        ('patient', 'Patient'),
        ('doctor', 'Doctor'),
        ('admin', 'Admin'),
    )
    
    GENDER_CHOICES = (
        ('M', 'Male'),
        ('F', 'Female'),
        ('O', 'Other'),
    )
    
    # Remove username field, use email instead
    username = None
    email = models.EmailField(_('email address'), unique=True)
    user_type = models.CharField(max_length=10, choices=USER_TYPE_CHOICES, default='patient')
    phone_number = models.CharField(max_length=20, blank=True, null=True)
    date_of_birth = models.DateField(null=True, blank=True)
    gender = models.CharField(max_length=1, choices=GENDER_CHOICES, blank=True, null=True)
    profile_picture = models.ImageField(upload_to='profile_pics/', null=True, blank=True)
    is_verified = models.BooleanField(default=False, help_text="Email verification status")
    is_doctor_verified = models.BooleanField(default=False, help_text="Doctor verification status")
    verification_token = models.CharField(max_length=255, blank=True, null=True)
    verification_token_created_at = models.DateTimeField(blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    # Location fields
    address = models.TextField(blank=True, null=True)
    city = models.CharField(max_length=100, blank=True, null=True)
    country = models.CharField(max_length=100, blank=True, null=True)
    location = PointField(geography=True, null=True, blank=True)  # Use the conditionally defined PointField
    
    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = []
    
    objects = UserManager()
    
    def __str__(self):
        return self.get_full_name() or self.email
    
    @property
    def is_doctor(self):
        return self.user_type == 'doctor'
    
    @property
    def is_patient(self):
        return self.user_type == 'patient'

class DoctorAvailability(models.Model):
    """Model to store doctor's availability schedule"""
    DAYS_OF_WEEK = (
        (0, 'Monday'),
        (1, 'Tuesday'),
        (2, 'Wednesday'),
        (3, 'Thursday'),
        (4, 'Friday'),
        (5, 'Saturday'),
        (6, 'Sunday'),
    )
    
    doctor = models.ForeignKey(User, on_delete=models.CASCADE, related_name='availabilities')
    day_of_week = models.IntegerField(choices=DAYS_OF_WEEK)
    start_time = models.TimeField()
    end_time = models.TimeField()
    is_available = models.BooleanField(default=True)
    
    class Meta:
        verbose_name_plural = 'Doctor Availabilities'
        unique_together = ('doctor', 'day_of_week', 'start_time', 'end_time')
        ordering = ['day_of_week', 'start_time']
    
    def __str__(self):
        return f"{self.doctor.get_full_name()} - {self.get_day_of_week_display()} {self.start_time} to {self.end_time}"

class DoctorSpecialization(models.Model):
    """Model to store doctor specializations"""
    name = models.CharField(max_length=100, unique=True)
    description = models.TextField(blank=True, null=True)
    
    def __str__(self):
        return self.name

class DoctorProfile(models.Model):
    """Model to store doctor-specific profile information"""
    user = models.OneToOneField(
        User,
        on_delete=models.CASCADE,
        related_name='doctor_profile',
        primary_key=True
    )
    
    # Professional Information
    specialization = models.CharField(max_length=100, blank=True, null=True)
    license_number = models.CharField(max_length=50, blank=True, null=True)
    years_of_experience = models.PositiveIntegerField(null=True, blank=True)
    bio = models.TextField(blank=True, null=True)
    consultation_fee = models.DecimalField(
        max_digits=10,
        decimal_places=2,
        default=0.00
    )
    
    # Additional Professional Details
    qualifications = models.TextField(blank=True, null=True, help_text="Degrees and certifications")
    hospital_affiliations = models.TextField(blank=True, null=True)
    awards = models.TextField(blank=True, null=True)
    memberships = models.TextField(blank=True, null=True, help_text="Professional organization memberships")
    publications = models.TextField(blank=True, null=True)
    research_interests = models.TextField(blank=True, null=True)
    
    # Practice Information
    languages_spoken = models.JSONField(
        default=list,
        blank=True,
        help_text="List of languages spoken by the doctor"
    )
    
    # Ratings and Reviews
    average_rating = models.FloatField(default=0.0)
    total_reviews = models.PositiveIntegerField(default=0)
    
    # Timestamps
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        verbose_name = "Doctor Profile"
        verbose_name_plural = "Doctor Profiles"
    
    def __str__(self):
        return f"{self.user.get_full_name()}'s Profile"


class DoctorVerificationDocument(models.Model):
    """Model to store doctor verification documents"""
    DOCUMENT_TYPES = (
        ('license', 'Medical License'),
        ('diploma', 'Medical Diploma'),
        ('id_card', 'National ID Card'),
        ('certificate', 'Specialty Certificate'),
        ('other', 'Other'),
    )
    
    STATUS_CHOICES = (
        ('pending', 'Pending Review'),
        ('approved', 'Approved'),
        ('rejected', 'Rejected'),
    )
    
    doctor = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name='verification_documents',
        limit_choices_to={'user_type': 'doctor'}
    )
    document_type = models.CharField(max_length=20, choices=DOCUMENT_TYPES)
    document_file = models.FileField(upload_to='doctor_verification/')
    status = models.CharField(max_length=10, choices=STATUS_CHOICES, default='pending')
    notes = models.TextField(blank=True, null=True, help_text="Admin notes about this document")
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    reviewed_by = models.ForeignKey(
        User,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='reviewed_documents',
        limit_choices_to={'is_staff': True}
    )
    reviewed_at = models.DateTimeField(null=True, blank=True)
    
    class Meta:
        ordering = ['-created_at']
        verbose_name = 'Doctor Verification Document'
        verbose_name_plural = 'Doctor Verification Documents'
    
    def __str__(self):
        return f"{self.get_document_type_display()} - {self.doctor.get_full_name()} ({self.status})"
    
    def save(self, *args, **kwargs):
        # If status is being updated to approved/rejected, set reviewed_at and reviewed_by
        if self.pk and self.status in ['approved', 'rejected'] and not self.reviewed_at:
            from django.utils import timezone
            self.reviewed_at = timezone.now()
            if not self.reviewed_by and hasattr(self, '_request_user'):
                self.reviewed_by = self._request_user
        super().save(*args, **kwargs)
    
    def update_rating(self):
        """Update the average rating and total reviews count"""
        from django.db.models import Avg, Count
        
        stats = self.user.reviews.aggregate(
            avg_rating=Avg('rating'),
            total_reviews=Count('id')
        )
        
        self.average_rating = stats['avg_rating'] or 0.0
        self.total_reviews = stats['total_reviews'] or 0
        self.save(update_fields=['average_rating', 'total_reviews', 'updated_at'])

class DoctorEducation(models.Model):
    """Model to store doctor's education background"""
    doctor = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name='educations'
    )
    degree = models.CharField(max_length=200)
    institution = models.CharField(max_length=200)
    year_completed = models.PositiveIntegerField()
    description = models.TextField(blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        ordering = ['-year_completed']
        verbose_name = "Doctor Education"
        verbose_name_plural = "Doctor Educations"
    
    def __str__(self):
        return f"{self.degree} at {self.institution} ({self.year_completed})"


class DoctorReview(models.Model):
    """Model to store patient reviews for doctors"""
    RATING_CHOICES = [
        (1, '1 - Poor'),
        (2, '2 - Fair'),
        (3, '3 - Good'),
        (4, '4 - Very Good'),
        (5, '5 - Excellent'),
    ]
    
    doctor = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name='reviews',
        limit_choices_to={'user_type': 'doctor'}
    )
    patient = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name='given_reviews',
        limit_choices_to={'user_type': 'patient'}
    )
    
    # Review content
    rating = models.PositiveSmallIntegerField(choices=RATING_CHOICES)
    comment = models.TextField(blank=True, null=True)
    
    # Additional rating metrics
    wait_time_rating = models.PositiveSmallIntegerField(
        choices=RATING_CHOICES,
        null=True,
        blank=True,
        help_text="Rating for the waiting time"
    )
    bedside_manner_rating = models.PositiveSmallIntegerField(
        choices=RATING_CHOICES,
        null=True,
        blank=True,
        help_text="Rating for the doctor's bedside manner"
    )
    overall_experience = models.PositiveSmallIntegerField(
        choices=RATING_CHOICES,
        null=True,
        blank=True,
        help_text="Overall experience rating"
    )
    
    # Metadata
    anonymous = models.BooleanField(
        default=False,
        help_text="Whether the review is anonymous"
    )
    
    # Timestamps
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        ordering = ['-created_at']
        verbose_name = "Doctor Review"
        verbose_name_plural = "Doctor Reviews"
        unique_together = ('doctor', 'patient')
    
    def __str__(self):
        return f"{self.patient.get_full_name()}'s review for Dr. {self.doctor.get_full_name()}"
    
    def save(self, *args, **kwargs):
        """Update doctor's rating when a new review is saved"""
        is_new = self._state.adding
        
        # Call the parent save method
        super().save(*args, **kwargs)
        
        # Update the doctor's average rating
        if is_new and hasattr(self.doctor, 'doctor_profile'):
            self.doctor.doctor_profile.update_rating()
    
    def delete(self, *args, **kwargs):
        """Update doctor's rating when a review is deleted"""
        doctor = self.doctor
        
        # Call the parent delete method
        super().delete(*args, **kwargs)
        
        # Update the doctor's average rating
        if hasattr(doctor, 'doctor_profile'):
            doctor.doctor_profile.update_rating()
