import logging
from django.contrib.auth import get_user_model
from django.contrib.auth.tokens import default_token_generator
from django.shortcuts import get_object_or_404
from django.utils.encoding import force_str
from django.utils.http import urlsafe_base64_decode
from rest_framework import generics, permissions, status, viewsets
from rest_framework.exceptions import ValidationError
from rest_framework.parsers import JSONParser, MultiPartParser
from rest_framework.response import Response
from rest_framework.views import APIView

from .models import (
    DoctorAvailability, DoctorEducation, DoctorVerificationDocument, User
)
from .serializers import (
    ChangePasswordSerializer, CustomTokenObtainPairSerializer, DoctorAvailabilitySerializer,
    DoctorEducationSerializer, DoctorProfileSerializer, DoctorVerificationDocumentSerializer,
    ResetPasswordEmailSerializer, SetNewPasswordSerializer, UserProfileSerializer, UserSerializer
)
from .utils import Util

logger = logging.getLogger(__name__)

class IsOwnerOrReadOnly(permissions.BasePermission):
    """
    Custom permission to only allow owners of an object to edit it.
    """
    def has_object_permission(self, request, view, obj):
        if request.method in permissions.SAFE_METHODS:
            return True
        return obj == request.user

# --- User Account & Authentication Views ---

class UserRegistrationView(generics.CreateAPIView):
    queryset = User.objects.all()
    permission_classes = [permissions.AllowAny]
    serializer_class = UserSerializer

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.save()
        try:
            Util.send_verification_email(user, request)
        except Exception as e:
            logger.error(f"Failed to send verification email for {user.email}: {e}")
        headers = self.get_success_headers(serializer.data)
        return Response(serializer.data, status=status.HTTP_201_CREATED, headers=headers)

class UserLoginView(APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request, *args, **kwargs):
        serializer = CustomTokenObtainPairSerializer(data=request.data)
        try:
            serializer.is_valid(raise_exception=True)
        except Exception:
            return Response({'error': 'Email or password incorrect.'}, status=status.HTTP_401_UNAUTHORIZED)
        
        user = serializer.user
        if not user.is_verified:
            return Response({'error': 'Please verify your email address before logging in.'}, status=status.HTTP_403_FORBIDDEN)
        
        if user.user_type == 'doctor' and not user.is_doctor_verified:
            return Response({'error': 'Your doctor account is pending verification.'}, status=status.HTTP_403_FORBIDDEN)
        
        return Response(serializer.validated_data, status=status.HTTP_200_OK)

class VerifyEmailView(APIView):
    permission_classes = [permissions.AllowAny]

    def get(self, request, uidb64, token):
        try:
            uid = force_str(urlsafe_base64_decode(uidb64))
            user = User.objects.get(pk=uid)
        except (TypeError, ValueError, OverflowError, User.DoesNotExist):
            user = None

        if user is not None and default_token_generator.check_token(user, token):
            user.is_verified = True
            user.save()
            return Response({'message': 'Email verified successfully!'}, status=status.HTTP_200_OK)
        else:
            return Response({'error': 'Invalid or expired verification link.'}, status=status.HTTP_400_BAD_REQUEST)

class ResendVerificationEmailView(APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        email = request.data.get('email')
        if not email:
            return Response({'error': 'Email is required.'}, status=status.HTTP_400_BAD_REQUEST)
        try:
            user = User.objects.get(email=email)
            if user.is_verified:
                return Response({'error': 'This email is already verified.'}, status=status.HTTP_400_BAD_REQUEST)
            
            Util.send_verification_email(user, request)
            return Response({'message': 'Verification email has been resent.'}, status=status.HTTP_200_OK)
        except User.DoesNotExist:
            return Response({'error': 'No user found with this email.'}, status=status.HTTP_404_NOT_FOUND)
        except Exception as e:
            logger.error(f"Error resending verification email for {email}: {e}")
            return Response({'error': 'Failed to send verification email.'}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

class CheckEmailView(APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request, *args, **kwargs):
        email = request.data.get('email')
        if not email:
            return Response({'error': 'Email not provided.'}, status=status.HTTP_400_BAD_REQUEST)
        exists = User.objects.filter(email=email).exists()
        return Response({'exists': exists})


# --- User Profile and Password Management ---

class UserProfileView(generics.RetrieveUpdateAPIView):
    queryset = User.objects.all()
    serializer_class = UserProfileSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_object(self):
        return self.request.user

class ChangePasswordView(generics.UpdateAPIView):
    serializer_class = ChangePasswordSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_object(self):
        return self.request.user

    def update(self, request, *args, **kwargs):
        user = self.get_object()
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        if not user.check_password(serializer.data.get("old_password")):
            return Response({"old_password": ["Wrong password."]}, status=status.HTTP_400_BAD_REQUEST)
        
        user.set_password(serializer.data.get("new_password"))
        user.save()
        return Response(status=status.HTTP_204_NO_CONTENT)

class SendPasswordResetEmailView(generics.GenericAPIView):
    permission_classes = [permissions.AllowAny]
    serializer_class = ResetPasswordEmailSerializer

    def post(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        email = serializer.validated_data['email']
        try:
            user = User.objects.get(email=email)
            Util.send_password_reset_email(user, request)
        except User.DoesNotExist:
            pass # Do not reveal if user exists
        except Exception as e:
            logger.error(f"Failed to send password reset email for {email}: {e}")
        
        return Response({'message': 'If an account with this email exists, a password reset link has been sent.'}, status=status.HTTP_200_OK)

class UserPasswordResetView(generics.GenericAPIView):
    permission_classes = [permissions.AllowAny]
    serializer_class = SetNewPasswordSerializer

    def post(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response({'message': 'Password reset successful.'}, status=status.HTTP_200_OK)


# --- Doctor Specific Views ---

class DoctorListView(generics.ListAPIView):
    queryset = User.objects.filter(user_type='doctor', is_doctor_verified=True, is_active=True)
    serializer_class = DoctorProfileSerializer
    permission_classes = [permissions.AllowAny]

class DoctorDetailView(generics.RetrieveUpdateAPIView):
    queryset = User.objects.filter(user_type='doctor', is_doctor_verified=True)
    serializer_class = DoctorProfileSerializer
    permission_classes = [IsOwnerOrReadOnly]
    lookup_field = 'pk'


class DoctorAvailabilityListView(generics.ListAPIView):
    serializer_class = DoctorAvailabilitySerializer
    permission_classes = [permissions.AllowAny]

    def get_queryset(self):
        doctor_id = self.kwargs.get('pk')
        return DoctorAvailability.objects.filter(doctor_id=doctor_id)


class DoctorReviewListView(generics.ListAPIView):
    # TODO: Create and import ReviewSerializer
    # serializer_class = ReviewSerializer
    permission_classes = [permissions.AllowAny]

    def get_queryset(self):
        # TODO: Create a Review model and filter by doctor_id
        # doctor_id = self.kwargs.get('pk')
        # return Review.objects.filter(doctor_id=doctor_id)
        return [] # Returning empty list as a placeholder


class DoctorAvailabilityViewSet(viewsets.ModelViewSet):
    serializer_class = DoctorAvailabilitySerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return DoctorAvailability.objects.filter(doctor=self.request.user)

    def perform_create(self, serializer):
        if self.request.user.user_type != 'doctor':
            raise ValidationError("Only doctors can set availability.")
        serializer.save(doctor=self.request.user)

class DoctorEducationViewSet(viewsets.ModelViewSet):
    serializer_class = DoctorEducationSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return DoctorEducation.objects.filter(doctor=self.request.user)

    def perform_create(self, serializer):
        if self.request.user.user_type != 'doctor':
            raise ValidationError("Only doctors can add education.")
        serializer.save(doctor=self.request.user)


# --- Doctor Verification Views ---

class DoctorDocumentUploadView(generics.CreateAPIView):
    serializer_class = DoctorVerificationDocumentSerializer
    permission_classes = [permissions.IsAuthenticated]
    parser_classes = [MultiPartParser, JSONParser]

    def perform_create(self, serializer):
        if self.request.user.user_type != 'doctor':
            raise ValidationError("Only doctors can upload documents.")
        serializer.save(doctor=self.request.user)

class DoctorDocumentListView(generics.ListAPIView):
    serializer_class = DoctorVerificationDocumentSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return DoctorVerificationDocument.objects.filter(doctor=self.request.user)

class AdminVerifyDoctorView(APIView):
    permission_classes = [permissions.IsAdminUser]

    def post(self, request, doctor_id):
        doctor = get_object_or_404(User, pk=doctor_id, user_type='doctor')
        doctor.is_doctor_verified = True
        doctor.is_active = True
        doctor.save()
        try:
            Util.send_template_email(
                'emails/doctor_approved.html',
                {'user': doctor},
                'Your Doctor Account Has Been Approved',
                doctor.email
            )
        except Exception as e:
            logger.error(f"Error sending approval email to {doctor.email}: {e}")
        return Response({'message': 'Doctor verified successfully.'}, status=status.HTTP_200_OK)


# --- Dashboard Views ---

class DashboardStatsView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, *args, **kwargs):
        # This is a placeholder. Implement actual logic later.
        stats = {
            "appointments": 0,
            "patients": 0,
            "revenue": "0.00"
        }
        return Response(stats)