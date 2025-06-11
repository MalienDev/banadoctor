from django.urls import path
from rest_framework.routers import DefaultRouter
from . import views

app_name = 'appointments'

router = DefaultRouter()

urlpatterns = [
    # Appointments
    path('', views.AppointmentListView.as_view(), name='appointment-list'),
    path('create/', views.AppointmentCreateView.as_view(), name='appointment-create'),
    path('<int:pk>/', views.AppointmentDetailView.as_view(), name='appointment-detail'),
    path('<int:appointment_id>/cancel/', views.cancel_appointment, name='appointment-cancel'),
    
    # Doctor schedule
    path('doctor/schedule/', views.DoctorScheduleView.as_view(), name='doctor-schedule'),
    
    # Time slots
    path('timeslots/', views.TimeSlotListView.as_view(), name='timeslot-list'),
    
    # Doctor availability
    path('doctor/<int:doctor_id>/availability/', views.DoctorAvailabilityView.as_view(), name='doctor-availability'),
    
    # Book appointment
    path('book/', views.BookAppointmentView.as_view(), name='book-appointment'),
    
    # Reminders
    path('<int:appointment_id>/reminders/', views.AppointmentReminderView.as_view(), name='appointment-reminders'),
]
