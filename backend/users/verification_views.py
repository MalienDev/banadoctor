import logging
from django.utils import timezone
from datetime import timedelta
from django.conf import settings
from django.shortcuts import get_object_or_404
from django.utils.http import urlsafe_base64_decode
from django.utils.encoding import force_str
from rest_framework import status, generics, permissions
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.parsers import MultiPartParser, JSONParser
from rest_framework.exceptions import ValidationError, NotFound
from rest_framework.permissions import IsAuthenticated, IsAdminUser
from .models import User, DoctorVerificationDocument
from .serializers import DoctorVerificationDocumentSerializer
from .utils import Util

logger = logging.getLogger(__name__)

class VerifyEmailView(APIView):
    """View to verify user's email address"""
    permission_classes = [permissions.AllowAny]
    
    def get(self, request, uidb64, token):
        try:
            # Decode user ID
            uid = force_str(urlsafe_base64_decode(uidb64))
            user = User.objects.get(pk=uid)
            
            # Check if token is valid and not expired (24 hours)
            token_expiry = user.verification_token_created_at + timedelta(hours=24)
            if (user.verification_token != token or 
                not user.verification_token_created_at or
                timezone.now() > token_expiry):
                return Response(
                    {'error': 'Invalid or expired verification link.'}, 
                    status=status.HTTP_400_BAD_REQUEST
                )
            
            # Mark email as verified
            user.is_verified = True
            user.verification_token = None
            user.verification_token_created_at = None
            user.save()
            
            # Redirect to appropriate page based on user type
            if user.user_type == 'doctor':
                return Response({
                    'message': 'Email verified successfully! Please upload your verification documents.',
                    'redirect_to': '/doctor/upload-documents'
                })
            else:
                return Response({
                    'message': 'Email verified successfully! You can now log in.',
                    'redirect_to': '/login'
                })
                
        except (TypeError, ValueError, OverflowError, User.DoesNotExist) as e:
            logger.error(f"Email verification error: {str(e)}")
            return Response(
                {'error': 'Invalid verification link.'}, 
                status=status.HTTP_400_BAD_REQUEST
            )


class DoctorDocumentUploadView(generics.CreateAPIView):
    """View for doctors to upload verification documents"""
    serializer_class = DoctorVerificationDocumentSerializer
    permission_classes = [IsAuthenticated]
    parser_classes = [MultiPartParser, JSONParser]
    
    def get_queryset(self):
        # Only return documents for the current user
        return DoctorVerificationDocument.objects.filter(doctor=self.request.user)
    
    def perform_create(self, serializer):
        # Ensure the user is a doctor
        if not self.request.user.is_doctor:
            raise ValidationError({"error": "Only doctors can upload verification documents."})
        
        # Save the document with the current user as the doctor
        serializer.save(doctor=self.request.user)
    
    def post(self, request, *args, **kwargs):
        # Check if user is verified
        if not request.user.is_verified:
            return Response(
                {"error": "Please verify your email before uploading documents."},
                status=status.HTTP_403_FORBIDDEN
            )
        
        return super().post(request, *args, **kwargs)


class DoctorDocumentListView(generics.ListAPIView):
    """View for doctors to list their verification documents"""
    serializer_class = DoctorVerificationDocumentSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        # Only return documents for the current user
        return DoctorVerificationDocument.objects.filter(doctor=self.request.user)


class AdminVerifyDoctorView(APIView):
    """View for admin to verify a doctor's documents"""
    permission_classes = [IsAdminUser]
    
    def post(self, request, doctor_id):
        doctor = get_object_or_404(User, pk=doctor_id, user_type='doctor')
        
        # Check if all required documents are approved
        required_docs = ['license', 'diploma', 'id_card']
        approved_docs = DoctorVerificationDocument.objects.filter(
            doctor=doctor,
            document_type__in=required_docs,
            status='approved'
        ).values_list('document_type', flat=True).distinct()
        
        missing_docs = set(required_docs) - set(approved_docs)
        if missing_docs:
            return Response({
                'error': f'Missing or not approved documents: {", ".join(missing_docs)}',
                'status': 'incomplete_documents'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        # Approve the doctor
        doctor.is_doctor_verified = True
        doctor.is_active = True  # Activate the account
        doctor.save()
        
        # Send approval email
        try:
            Util.send_template_email(
                'emails/doctor_approved.html',
                {'user': doctor, 'site_name': request.get_host()},
                'Your Doctor Account Has Been Approved',
                doctor.email
            )
        except Exception as e:
            logger.error(f"Error sending approval email: {str(e)}")
        
        return Response({
            'message': 'Doctor verified successfully!',
            'status': 'approved'
        })


class ResendVerificationEmailView(APIView):
    """View to resend verification email"""
    permission_classes = [permissions.AllowAny]
    
    def post(self, request):
        email = request.data.get('email')
        if not email:
            return Response(
                {'error': 'Email is required'}, 
                status=status.HTTP_400_BAD_REQUEST
            )
        
        try:
            user = User.objects.get(email=email)
            
            # Check if already verified
            if user.is_verified:
                return Response(
                    {'error': 'Email is already verified'}, 
                    status=status.HTTP_400_BAD_REQUEST
                )
            
            # Send verification email
            try:
                Util.send_verification_email(user, request)
                return Response({
                    'message': 'Verification email has been resent. Please check your email.'
                })
            except Exception as e:
                logger.error(f"Error sending verification email: {str(e)}")
                return Response(
                    {'error': 'Failed to send verification email. Please try again later.'},
                    status=status.HTTP_500_INTERNAL_SERVER_ERROR
                )
                
        except User.DoesNotExist:
            return Response(
                {'error': 'No user found with this email'}, 
                status=status.HTTP_404_NOT_FOUND
            )
