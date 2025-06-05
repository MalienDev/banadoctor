import logging

from django.contrib.auth import get_user_model
from django.contrib.auth.tokens import default_token_generator
from django.core.exceptions import PermissionDenied
from django.utils.encoding import force_str
from django.utils.http import urlsafe_base64_decode
from rest_framework import generics, status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework_simplejwt.views import TokenObtainPairView

from .models import DoctorAvailability
from .serializers import (
    ChangePasswordSerializer,
    CustomTokenObtainPairSerializer,
    ResetPasswordEmailSerializer,
    SetNewPasswordSerializer,
    UserProfileSerializer,
    UserSerializer,
)

User = get_user_model()
logger = logging.getLogger(__name__)


class RegisterView(generics.CreateAPIView):
    """View for user registration"""
    queryset = User.objects.all()
    permission_classes = (AllowAny,)
    serializer_class = UserSerializer

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        
        # In a real app, you would send a verification email here
        # send_verification_email(user)
        
        return Response(
            {"message": "User registered successfully. Please check your email for verification."},
            status=status.HTTP_201_CREATED
        )



class CustomTokenObtainPairView(TokenObtainPairView):
    """Custom token obtain view to use our serializer"""
    serializer_class = CustomTokenObtainPairSerializer



class UserProfileView(generics.RetrieveUpdateAPIView):
    """View to retrieve and update user profile"""
    permission_classes = (IsAuthenticated,)
    serializer_class = UserProfileSerializer

    def get_object(self):
        return self.request.user



class ChangePasswordView(generics.UpdateAPIView):
    """View for changing user password"""
    permission_classes = (IsAuthenticated,)
    serializer_class = ChangePasswordSerializer

    def update(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        
        # Check old password
        if not request.user.check_password(serializer.data.get("old_password")):
            return Response(
                {"old_password": ["Wrong password."]}, 
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Set new password
        request.user.set_password(serializer.data.get("new_password"))
        request.user.save()
        
        return Response({"message": "Password updated successfully"}, status=status.HTTP_200_OK)



class RequestPasswordResetEmail(generics.GenericAPIView):
    """View for requesting password reset email"""
    permission_classes = (AllowAny,)
    serializer_class = ResetPasswordEmailSerializer

    def post(self, request):
        serializer = self.serializer_class(data=request.data)
        serializer.is_valid(raise_exception=True)
        email = serializer.validated_data['email']
        
        if User.objects.filter(email=email).exists():
            # In a real app, you would send a password reset email here
            # send_password_reset_email(user)
            pass
        
        # Always return success to prevent email enumeration
        return Response(
            {'message': 'If an account exists with this email, you will receive a password reset link.'},
            status=status.HTTP_200_OK
        )



class PasswordTokenCheckAPI(generics.GenericAPIView):
    """View to verify password reset token"""
    permission_classes = (AllowAny,)
    
    def get(self, request, uidb64, token):
        try:
            id = force_str(urlsafe_base64_decode(uidb64))
            user = User.objects.get(id=id)
            
            if not default_token_generator.check_token(user, token):
                return Response(
                    {'error': 'Token is not valid, please request a new one'},
                    status=status.HTTP_401_UNAUTHORIZED
                )
                
            return Response({
                'success': True,
                'message': 'Credentials Valid',
                'uidb64': uidb64,
                'token': token
            }, status=status.HTTP_200_OK)
            
        except Exception:
            return Response(
                {'error': 'Link is no longer valid'},
                status=status.HTTP_401_UNAUTHORIZED
            )



class SetNewPasswordAPIView(generics.GenericAPIView):
    """View to set a new password after password reset"""
    permission_classes = (AllowAny,)
    serializer_class = SetNewPasswordSerializer
    
    def patch(self, request):
        serializer = self.serializer_class(data=request.data)
        serializer.is_valid(raise_exception=True)
        
        try:
            id = force_str(urlsafe_base64_decode(serializer.data.get('uidb64')))
            user = User.objects.get(id=id)
            
            if not default_token_generator.check_token(user, serializer.data.get('token')):
                return Response(
                    {'error': 'Token is not valid, please request a new one'},
                    status=status.HTTP_401_UNAUTHORIZED
                )
            
            user.set_password(serializer.data.get('password'))
            user.save()
            
            return Response(
                {'message': 'Password reset successful'},
                status=status.HTTP_200_OK
            )
            
        except Exception:
            logger.error("An error occurred while resetting the password")
            return Response(
                {'error': 'Something went wrong'},
                status=status.HTTP_400_BAD_REQUEST
            )



class DoctorAvailabilityView(generics.ListCreateAPIView):
    """View to manage doctor's availability"""
    permission_classes = (IsAuthenticated,)
    serializer_class = None  # You'll need to create this serializer
    
    def get_queryset(self):
        return DoctorAvailability.objects.filter(doctor=self.request.user)
    
    def perform_create(self, serializer):
        if not self.request.user.is_doctor:
            raise PermissionDenied("Only doctors can set availability")
        serializer.save(doctor=self.request.user)


@api_view(['GET'])
@permission_classes([AllowAny])
def check_email_availability(request):
    """Check if an email is available for registration"""
    email = request.query_params.get('email', None)
    if not email:
        return Response(
            {'error': 'Email parameter is required'},
            status=status.HTTP_400_BAD_REQUEST
        )
    
    is_available = not User.objects.filter(email__iexact=email).exists()
    return Response({'available': is_available}, status=status.HTTP_200_OK)
