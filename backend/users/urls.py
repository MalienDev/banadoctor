from django.urls import path
from rest_framework_simplejwt.views import TokenRefreshView
from . import views

urlpatterns = [
    # Authentication
    path('register/', views.RegisterView.as_view(), name='register'),
    path('login/', views.CustomTokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    
    # User profile
    path('profile/', views.UserProfileView.as_view(), name='user-profile'),
    
    # Password management
    path('change-password/', views.ChangePasswordView.as_view(), name='change-password'),
    path('request-reset-email/', views.RequestPasswordResetEmail.as_view(), 
         name='request-reset-email'),
    path('password-reset/<uidb64>/<token>/', 
         views.PasswordTokenCheckAPI.as_view(), name='password-reset-confirm'),
    path('password-reset-complete/', views.SetNewPasswordAPIView.as_view(),
         name='password-reset-complete'),
    
    # Utilities
    path('check-email/', views.check_email_availability, name='check-email'),
    
    # Doctor specific
    path('doctor/availability/', views.DoctorAvailabilityView.as_view(), 
         name='doctor-availability'),

    # Dashboard stats
    path('dashboard-stats/', views.DashboardStatsView.as_view(), name='dashboard-stats'),
]
