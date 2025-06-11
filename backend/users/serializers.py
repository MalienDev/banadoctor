from rest_framework import serializers
from django.contrib.auth import get_user_model
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer
from django.contrib.auth.password_validation import validate_password

User = get_user_model()

class UserSerializer(serializers.ModelSerializer):
    """Serializer for the user object"""
    password = serializers.CharField(write_only=True, required=True, validators=[validate_password])
    password2 = serializers.CharField(write_only=True, required=True)
    
    class Meta:
        model = User
        fields = ('id', 'email', 'first_name', 'last_name', 'phone_number', 
                 'password', 'password2', 'user_type', 'date_of_birth', 'gender')
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
        user = User.objects.create_user(**validated_data)
        return user

class DoctorProfileSerializer(serializers.ModelSerializer):
    """Serializer for doctor-specific profile details"""
    class Meta:
        model = User
        fields = ('specialization', 'license_number', 'years_of_experience', 
                 'bio', 'consultation_fee', 'address', 'city', 'country')
        extra_kwargs = {
            'specialization': {'required': True},
            'license_number': {'required': True},
        }

class UserProfileSerializer(serializers.ModelSerializer):
    """Serializer for user profile details"""
    doctor_profile = DoctorProfileSerializer(required=False)
    
    class Meta:
        model = User
        fields = ('id', 'email', 'first_name', 'last_name', 'phone_number', 
                'date_of_birth', 'gender', 'profile_picture', 'is_verified',
                'created_at', 'updated_at', 'doctor_profile')
        read_only_fields = ('id', 'email', 'is_verified', 'created_at', 'updated_at')
    
    def update(self, instance, validated_data):
        doctor_profile_data = validated_data.pop('doctor_profile', None)
        
        # Update user fields
        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        
        # Update doctor profile if user is a doctor and data is provided
        if instance.is_doctor and doctor_profile_data is not None:
            for attr, value in doctor_profile_data.items():
                setattr(instance, attr, value)
        
        instance.save()
        return instance

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
