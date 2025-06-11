import logging
from datetime import datetime, timedelta
from django.utils import timezone
from django.db.models import Q
from django.shortcuts import get_object_or_404
from rest_framework import status, generics, permissions, filters
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated, IsAdminUser
from django_filters.rest_framework import DjangoFilterBackend

from .models import Appointment, AppointmentReminder, DoctorSchedule, TimeSlot
from .serializers import (
    AppointmentListSerializer, AppointmentCreateSerializer, AppointmentUpdateSerializer,
    DoctorScheduleSerializer, TimeSlotSerializer, DoctorAvailabilitySerializer,
    BookAppointmentSerializer, AppointmentReminderSerializer
)
from users.models import User

logger = logging.getLogger(__name__)

class AppointmentListView(generics.ListAPIView):
    """View for listing appointments with filtering"""
    serializer_class = AppointmentListSerializer
    permission_classes = [IsAuthenticated]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['status', 'appointment_type', 'doctor', 'patient', 'is_paid']
    search_fields = ['patient__first_name', 'patient__last_name', 'doctor__first_name', 'doctor__last_name']
    ordering_fields = ['scheduled_date', 'start_time', 'created_at']
    
    def get_queryset(self):
        user = self.request.user
        queryset = Appointment.objects.select_related('patient', 'doctor').all()
        
        # Patients can only see their own appointments
        if user.is_patient:
            return queryset.filter(patient=user)
        # Doctors can see their own appointments and those of their patients
        elif user.is_doctor:
            return queryset.filter(Q(doctor=user) | Q(patient__doctor_appointments__doctor=user)).distinct()
        # Admin can see all appointments
        elif user.is_staff:
            return queryset
        
        return queryset.none()

class AppointmentCreateView(generics.CreateAPIView):
    """View for creating a new appointment"""
    serializer_class = AppointmentCreateSerializer
    permission_classes = [IsAuthenticated]
    
    def perform_create(self, serializer):
        serializer.save(patient=self.request.user)
        # TODO: Send confirmation email/notification

class AppointmentDetailView(generics.RetrieveUpdateDestroyAPIView):
    """View for retrieving, updating, or deleting an appointment"""
    queryset = Appointment.objects.all()
    permission_classes = [IsAuthenticated]
    
    def get_serializer_class(self):
        if self.request.method in ['PUT', 'PATCH']:
            return AppointmentUpdateSerializer
        return AppointmentListSerializer
    
    def get_queryset(self):
        user = self.request.user
        queryset = super().get_queryset()
        
        if user.is_patient:
            return queryset.filter(patient=user)
        elif user.is_doctor:
            return queryset.filter(doctor=user)
        # Admin can see all appointments
        return queryset
    
    def perform_update(self, serializer):
        appointment = self.get_object()
        old_status = appointment.status
        updated_appointment = serializer.save()
        
        # If status changed, log it and send notifications if needed
        if old_status != updated_appointment.status:
            logger.info(f"Appointment {appointment.id} status changed from {old_status} to {updated_appointment.status}")
            # TODO: Send status update notification to patient/doctor

class DoctorScheduleView(generics.ListCreateAPIView):
    """View for managing doctor's schedule"""
    serializer_class = DoctorScheduleSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        # Doctors can only see their own schedule
        if self.request.user.is_doctor:
            return DoctorSchedule.objects.filter(doctor=self.request.user)
        # Admin can see all schedules
        elif self.request.user.is_staff:
            return DoctorSchedule.objects.all()
        return DoctorSchedule.objects.none()
    
    def perform_create(self, serializer):
        if self.request.user.is_doctor:
            serializer.save(doctor=self.request.user)
        else:
            serializer.save()

class TimeSlotListView(generics.ListAPIView):
    """View for listing available time slots"""
    serializer_class = TimeSlotSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        doctor_id = self.request.query_params.get('doctor_id')
        date = self.request.query_params.get('date')
        
        queryset = TimeSlot.objects.filter(is_available=True)
        
        if doctor_id:
            queryset = queryset.filter(doctor_id=doctor_id)
        if date:
            queryset = queryset.filter(date=date)
        
        return queryset

class BookAppointmentView(APIView):
    """View for booking an appointment"""
    permission_classes = [IsAuthenticated]
    
    def post(self, request, *args, **kwargs):
        serializer = BookAppointmentSerializer(
            data=request.data,
            context={'request': request}
        )
        
        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        
        data = serializer.validated_data
        
        try:
            # Mark the time slot as unavailable
            time_slot = TimeSlot.objects.get(
                doctor=data['doctor_id'],
                date=data['date'],
                start_time=data['start_time'],
                end_time=data['end_time'],
                is_available=True
            )
            
            # Create the appointment
            appointment = Appointment.objects.create(
                patient=request.user,
                doctor=data['doctor_id'],
                scheduled_date=data['date'],
                start_time=data['start_time'],
                end_time=data['end_time'],
                appointment_type=data['appointment_type'],
                reason=data.get('reason', ''),
                symptoms=data.get('symptoms', ''),
                amount=0.00  # This would be calculated based on doctor's fee
            )
            
            # Update the time slot
            time_slot.is_available = False
            time_slot.appointment = appointment
            time_slot.save()
            
            # Create a reminder (e.g., 24 hours before)
            reminder_time = timezone.make_aware(
                datetime.combine(appointment.scheduled_date, appointment.start_time) - timedelta(hours=24)
            )
            
            AppointmentReminder.objects.create(
                appointment=appointment,
                reminder_type='email',  # or 'sms' based on user preference
                scheduled_time=reminder_time
            )
            
            # TODO: Send confirmation email/SMS
            
            return Response(
                {"message": "Appointment booked successfully", "appointment_id": appointment.id},
                status=status.HTTP_201_CREATED
            )
            
        except TimeSlot.DoesNotExist:
            return Response(
                {"error": "The selected time slot is no longer available"},
                status=status.HTTP_400_BAD_REQUEST
            )
        except Exception as e:
            logger.error(f"Error booking appointment: {str(e)}")
            return Response(
                {"error": "An error occurred while booking the appointment"},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

class DoctorAvailabilityView(APIView):
    """View for checking doctor's availability"""
    permission_classes = [IsAuthenticated]
    
    def get(self, request, doctor_id, *args, **kwargs):
        date_str = request.query_params.get('date')
        
        try:
            doctor = User.objects.get(id=doctor_id, user_type='doctor')
        except User.DoesNotExist:
            return Response(
                {"error": "Doctor not found"}, 
                status=status.HTTP_404_NOT_FOUND
            )
        
        try:
            if date_str:
                date = datetime.strptime(date_str, '%Y-%m-%d').date()
            else:
                date = timezone.now().date()
        except ValueError:
            return Response(
                {"error": "Invalid date format. Use YYYY-MM-DD"},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Get doctor's schedule for the day of the week
        day_of_week = date.weekday()
        schedule = DoctorSchedule.objects.filter(
            doctor=doctor,
            day_of_week=day_of_week,
            is_working_day=True
        ).first()
        
        if not schedule:
            return Response(
                {"message": "Doctor is not available on this day"},
                status=status.HTTP_200_OK
            )
        
        # Get all time slots for the doctor on this date
        time_slots = TimeSlot.objects.filter(
            doctor=doctor,
            date=date,
            is_available=True
        ).order_by('start_time')
        
        # Format available time slots
        available_slots = [
            {"start_time": slot.start_time, "end_time": slot.end_time}
            for slot in time_slots
        ]
        
        return Response({
            "doctor_id": doctor.id,
            "doctor_name": doctor.get_full_name(),
            "date": date,
            "available_slots": available_slots,
            "working_hours": {
                "start_time": schedule.start_time,
                "end_time": schedule.end_time
            }
        })

class AppointmentReminderView(generics.ListAPIView):
    """View for managing appointment reminders"""
    serializer_class = AppointmentReminderSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        appointment_id = self.kwargs.get('appointment_id')
        return AppointmentReminder.objects.filter(appointment_id=appointment_id)

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def cancel_appointment(request, appointment_id):
    """Cancel an appointment"""
    try:
        appointment = Appointment.objects.get(id=appointment_id)
        
        # Check permissions
        if not (request.user.is_staff or 
                request.user == appointment.patient or 
                request.user == appointment.doctor):
            return Response(
                {"error": "You don't have permission to cancel this appointment"},
                status=status.HTTP_403_FORBIDDEN
            )
        
        # Only allow cancelling future appointments
        if not appointment.is_upcoming:
            return Response(
                {"error": "Cannot cancel a past or already completed appointment"},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Update appointment status
        appointment.status = 'cancelled'
        appointment.save()
        
        # Free up the time slot
        TimeSlot.objects.filter(appointment=appointment).update(is_available=True)
        
        # TODO: Send cancellation notification
        
        return Response(
            {"message": "Appointment cancelled successfully"},
            status=status.HTTP_200_OK
        )
        
    except Appointment.DoesNotExist:
        return Response(
            {"error": "Appointment not found"},
            status=status.HTTP_404_NOT_FOUND
        )
    except Exception as e:
        logger.error(f"Error cancelling appointment: {str(e)}")
        return Response(
            {"error": "An error occurred while cancelling the appointment"},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )
