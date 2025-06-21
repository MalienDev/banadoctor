from rest_framework import serializers
from django.contrib.auth import get_user_model
from .models import DoctorAvailability, DoctorReview, DoctorEducation, DoctorVerificationDocument
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer
from django.contrib.auth.password_validation import validate_password
from django.utils import timezone
from datetime import timedelta
import logging

logger = logging.getLogger(__name__)

User = get_user_model()

class UserSerializer(serializers.ModelSerializer):
    """Serializer for the user object"""
    password = serializers.CharField(write_only=True, required=True, validators=[validate_password])
    password2 = serializers.CharField(write_only=True, required=True)
    
    class Meta:
        model = User
        fields = ('id', 'email', 'first_name', 'last_name', 'password', 'password2', 'user_type')
        extra_kwargs = {
            'first_name': {'required': True},
            'last_name': {'required': True},
        }
    
    def validate(self, attrs):
        if attrs['password'] != attrs.pop('password2'):
            raise serializers.ValidationError({"password": "Password fields didn't match."})
        return attrs
    
    def create(self, validated_data):
        # Remove password2 from the data
        validated_data.pop('password2', None)
        
        # Set user as inactive until email is verified
        user_type = validated_data.get('user_type', 'patient')
        if user_type == 'doctor':
            validated_data['is_active'] = False  # Inactive until admin verifies documents
        
        user = User.objects.create_user(**validated_data)
        
        # Generate verification token
        from django.utils import timezone
        from django.utils.crypto import get_random_string
        from datetime import timedelta
        
        user.verification_token = get_random_string(50)
        user.verification_token_created_at = timezone.now()
        user.save(update_fields=['verification_token', 'verification_token_created_at'])
        
        return user

class DoctorVerificationDocumentSerializer(serializers.ModelSerializer):
    """Serializer for doctor verification documents"""
    class Meta:
        model = DoctorVerificationDocument
        fields = ('id', 'document_type', 'document_file', 'status', 'notes', 'created_at', 'updated_at')
        read_only_fields = ('id', 'status', 'created_at', 'updated_at', 'notes')
        extra_kwargs = {
            'document_file': {'required': True},
            'document_type': {'required': True}
        }
    
    def validate_document_file(self, value):
        """Validate document file size and type"""
        max_size = 10 * 1024 * 1024  # 10MB
        if value.size > max_size:
            raise serializers.ValidationError(f"File size should be less than {max_size/1024/1024}MB")
        
        # Add more validations for file types if needed
        valid_extensions = ['.pdf', '.jpg', '.jpeg', '.png']
        if not any(value.name.lower().endswith(ext) for ext in valid_extensions):
            raise serializers.ValidationError("Unsupported file type. Supported types: " + ", ".join(valid_extensions))
        
        return value


class DoctorEducationSerializer(serializers.ModelSerializer):
    """Serializer for doctor's education"""
    class Meta:
        model = DoctorEducation
        fields = ('id', 'degree', 'institution', 'year_completed', 'description')
        read_only_fields = ('id',)

    def validate_year_completed(self, value):
        """Validate that the year is not in the future."""
        if value > timezone.now().year:
            raise serializers.ValidationError("Year completed cannot be in the future.")
        return value


class DoctorProfileSerializer(serializers.ModelSerializer):
    """
    Serializer for doctor-specific profile details.
    Includes nested education records.
    """
    specializations = serializers.StringRelatedField(
        source='doctor_profile.specializations', many=True, read_only=True
    )
    license_number = serializers.CharField(source='doctor_profile.license_number', read_only=True)
    years_of_experience = serializers.IntegerField(source='doctor_profile.years_of_experience', read_only=True)
    bio = serializers.CharField(source='doctor_profile.bio', read_only=True)
    consultation_fee = serializers.DecimalField(
        source='doctor_profile.consultation_fee', max_digits=10, decimal_places=2, read_only=True
    )
    average_rating = serializers.FloatField(source='doctor_profile.average_rating', read_only=True)
    total_reviews = serializers.IntegerField(source='doctor_profile.total_reviews', read_only=True)
    awards = serializers.CharField(source='doctor_profile.awards', read_only=True, allow_blank=True)
    memberships = serializers.CharField(source='doctor_profile.memberships', read_only=True, allow_blank=True)
    publications = serializers.CharField(source='doctor_profile.publications', read_only=True, allow_blank=True)
    research_interests = serializers.CharField(source='doctor_profile.research_interests', read_only=True, allow_blank=True)
    educations = DoctorEducationSerializer(many=True, read_only=True)
    
    class Meta:
        model = User
        fields = (
            'id', 'first_name', 'last_name', 'email', 'profile_picture', 
            'address', 'city', 'country', 'is_verified', 'is_doctor_verified',
            'specializations', 'license_number', 'years_of_experience', 'bio',
            'consultation_fee', 'average_rating', 'total_reviews', 'educations',
            'awards', 'memberships', 'publications', 'research_interests'
        )


class DoctorProfileUpdateSerializer(DoctorProfileSerializer):
    """
    Serializer for updating doctor profiles.
    Handles nested education records.
    """
    class Meta(DoctorProfileSerializer.Meta):
        fields = DoctorProfileSerializer.Meta.fields + ('educations',)
    
    def update(self, instance, validated_data):
        """Handle nested education records during update."""
        educations_data = validated_data.pop('educations', [])
        
        # Update the doctor profile
        instance = super().update(instance, validated_data)
        
        # Update or create education records
        if educations_data:
            self.update_educations(instance, educations_data)
            
        return instance
    
    def update_educations(self, doctor, educations_data):
        """Update or create education records for a doctor."""
        education_ids = []
        
        for education_data in educations_data:
            education_id = education_data.get('id', None)
            
            if education_id:
                # Update existing education record
                try:
                    education = DoctorEducation.objects.get(
                        id=education_id,
                        doctor=doctor
                    )
                    
                    # Remove ID to prevent "id is a non-updatable field" error
                    education_data.pop('id', None)
                    
                    for attr, value in education_data.items():
                        setattr(education, attr, value)
                    education.save()
                    education_ids.append(education.id)
                except DoctorEducation.DoesNotExist:
                    pass
            else:
                # Create new education record
                education = DoctorEducation.objects.create(
                    doctor=doctor,
                    **education_data
                )
                education_ids.append(education.id)
        
        # Delete educations not included in the update
        DoctorEducation.objects.filter(doctor=doctor).exclude(id__in=education_ids).delete()


class DoctorReviewSerializer(serializers.ModelSerializer):
    """Serializer for doctor reviews"""
    patient_name = serializers.CharField(source='patient.get_full_name', read_only=True)
    patient_photo = serializers.SerializerMethodField()
    
    class Meta:
        model = DoctorReview
        fields = (
            'id', 'rating', 'comment', 'created_at', 'patient_name', 'patient_photo',
            'wait_time_rating', 'bedside_manner_rating', 'overall_experience', 'anonymous'
        )
        read_only_fields = ('id', 'created_at', 'patient_name', 'patient_photo')
    
    def get_patient_photo(self, obj):
        """Get the URL of the patient's profile photo if available."""
        if obj.anonymous:
            return None
            
        request = self.context.get('request')
        if obj.patient.profile_picture and hasattr(obj.patient.profile_picture, 'url'):
            return request.build_absolute_uri(obj.patient.profile_picture.url)
        return None
    
    def validate_rating(self, value):
        """Validate that rating is between 1 and 5."""
        if not 1 <= value <= 5:
            raise serializers.ValidationError("Rating must be between 1 and 5.")
        return value
    
    def create(self, validated_data):
        """Ensure a patient can only review a doctor once."""
        doctor = validated_data['doctor']
        patient = self.context['request'].user
        
        # Check if the patient has already reviewed this doctor
        if DoctorReview.objects.filter(doctor=doctor, patient=patient).exists():
            raise serializers.ValidationError("You have already reviewed this doctor.")
        
        return super().create(validated_data)

class UserProfileSerializer(serializers.ModelSerializer):
    """
    Serializer for user profile details with nested doctor profile.
    Handles both retrieval and updates of user and doctor profiles.
    """
    doctor_profile = DoctorProfileSerializer(required=False)
    full_name = serializers.SerializerMethodField()
    
    class Meta:
        model = User
        fields = [
            'id', 'email', 'first_name', 'last_name', 'full_name',
            'phone_number', 'date_of_birth', 'gender', 'user_type',
            'profile_picture', 'is_verified', 'date_joined', 'last_login',
            'doctor_profile', 'is_active', 'is_staff', 'city', 'address', 'country'
        ]
        read_only_fields = [
            'id', 'email', 'user_type', 'is_verified', 'date_joined',
            'last_login', 'is_active', 'is_staff'
        ]
        extra_kwargs = {
            'first_name': {'required': True},
            'last_name': {'required': True},
            'phone_number': {'required': True},
        }
    
    def get_full_name(self, obj):
        """Return the full name of the user."""
        return obj.get_full_name()
    
    def to_representation(self, instance):
        """Customize the representation of the serializer."""
        representation = super().to_representation(instance)
        
        # Add doctor profile details if user is a doctor
        if instance.user_type == 'doctor' and hasattr(instance, 'doctor_profile'):
            representation['doctor_profile'] = DoctorProfileSerializer(
                instance.doctor_profile,
                context=self.context
            ).data
        
        # Remove sensitive fields if not admin or self
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            if not (request.user.is_staff or request.user == instance):
                # Remove sensitive fields for non-admin users viewing other profiles
                sensitive_fields = ['email', 'phone_number', 'date_of_birth']
                for field in sensitive_fields:
                    representation.pop(field, None)
        
        return representation
    
    def update(self, instance, validated_data):
        """
        Handle updates to user profile and nested doctor profile.
        
        Args:
            instance: User instance being updated
            validated_data: Validated data from the serializer
            
        Returns:
            User: Updated user instance
        """
        doctor_profile_data = validated_data.pop('doctor_profile', None)
        
        # Handle profile picture update
        profile_picture = validated_data.pop('profile_picture', None)
        if profile_picture is not None:
            instance.profile_picture = profile_picture
        
        # Update user fields
        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        
        # Save user instance
        instance.save()
        
        # Update or create doctor profile if data is provided and user is a doctor
        if doctor_profile_data is not None and instance.user_type == 'doctor':
            self._update_doctor_profile(instance, doctor_profile_data)
        
        return instance
    
    def _update_doctor_profile(self, user, profile_data):
        """
        Update or create a doctor profile for the user.
        
        Args:
            user: User instance
            profile_data: Dictionary of doctor profile data
        """
        from .models import DoctorProfile
        
        try:
            doctor_profile = user.doctor_profile
            # Update existing profile
            for attr, value in profile_data.items():
                setattr(doctor_profile, attr, value)
            doctor_profile.save()
        except DoctorProfile.DoesNotExist:
            # Create new profile
            DoctorProfile.objects.create(user=user, **profile_data)
        except Exception as e:
            logger.error(f"Error updating doctor profile for user {user.id}: {str(e)}")
            raise serializers.ValidationError({
                'doctor_profile': 'Failed to update doctor profile.'
            })

class DoctorAvailabilitySerializer(serializers.ModelSerializer):
    """Serializer for doctor's availability schedule"""
    class Meta:
        model = DoctorAvailability
        fields = ['id', 'day_of_week', 'start_time', 'end_time', 'is_available']


class CustomTokenObtainPairSerializer(TokenObtainPairSerializer):
    """Custom token obtain pair serializer to include user details in the response"""
    def validate(self, attrs):
        data = super().validate(attrs)
        refresh = self.get_token(self.user)
        
        # Add custom claims
        data['refresh'] = str(refresh)
        data['access'] = str(refresh.access_token)
        data['user'] = {
            'id': self.user.id,
            'email': self.user.email,
            'first_name': self.user.first_name,
            'last_name': self.user.last_name,
            'user_type': self.user.user_type,
            'is_verified': self.user.is_verified,
        }
        return data

class ChangePasswordSerializer(serializers.Serializer):
    """Serializer for password change endpoint."""
    old_password = serializers.CharField(required=True)
    new_password = serializers.CharField(required=True, validators=[validate_password])

class ResetPasswordEmailSerializer(serializers.Serializer):
    """Serializer for requesting a password reset e-mail."""
    email = serializers.EmailField(required=True)

class SetNewPasswordSerializer(serializers.Serializer):
    """Serializer for setting a new password after reset."""
    password = serializers.CharField(required=True, validators=[validate_password])
    token = serializers.CharField(required=True)
    uidb64 = serializers.CharField(required=True)
