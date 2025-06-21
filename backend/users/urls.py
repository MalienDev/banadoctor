from django.urls import path, include
from rest_framework.routers import DefaultRouter
from rest_framework_simplejwt.views import (
    TokenObtainPairView,
    TokenRefreshView,
    TokenVerifyView,
)
from .views import (
    AdminVerifyDoctorView, ChangePasswordView, CheckEmailView, DashboardStatsView,
    DoctorAvailabilityListView, DoctorAvailabilityViewSet, DoctorDetailView,
    DoctorDocumentListView, DoctorDocumentUploadView, DoctorEducationViewSet,
    DoctorListView, DoctorReviewListView, ResendVerificationEmailView,
    SendPasswordResetEmailView, UserLoginView, UserPasswordResetView,
    UserProfileView, UserRegistrationView, VerifyEmailView
)
from search.views import DoctorSearchView

router = DefaultRouter()
router.register(r'doctors/availability', DoctorAvailabilityViewSet, basename='doctor-availability')
router.register(r'doctors/education', DoctorEducationViewSet, basename='doctor-education')

# API v1 URL patterns
v1_urlpatterns = [
    # Authentication endpoints under /auth/
    path('auth/', include([
        # User registration and authentication
        path('register/', UserRegistrationView.as_view(), name='register'),
        path('login/', UserLoginView.as_view(), name='login'),
        path('check-email/', CheckEmailView.as_view(), name='check-email'),
        
        # Email verification
        path('verify-email/<str:uidb64>/<str:token>/', VerifyEmailView.as_view(), name='verify-email'),
        path('resend-verification/', ResendVerificationEmailView.as_view(), name='resend-verification'),
        
        # JWT token endpoints
        path('token/', TokenObtainPairView.as_view(), name='token_obtain_pair'),
        path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
        path('token/verify/', TokenVerifyView.as_view(), name='token_verify'),
        
        # Alias endpoints to match frontend expectations
        path('users/token/refresh/', TokenRefreshView.as_view(), name='token_refresh_alias'),
        
        # Password management
        path('change-password/', ChangePasswordView.as_view(), name='change-password'),
        path('send-reset-password-email/', SendPasswordResetEmailView.as_view(), 
             name='send-reset-password-email'),
        path('reset-password/<uidb64>/<token>/', 
             UserPasswordResetView.as_view(), name='reset-password'),
        
        # Dashboard
        path('dashboard-stats/', DashboardStatsView.as_view(), name='dashboard-stats'),
    ])),
    
    # Doctor verification endpoints
    path('doctor/verification/', include([
        path('documents/', DoctorDocumentUploadView.as_view(), name='doctor-upload-documents'),
        path('documents/list/', DoctorDocumentListView.as_view(), name='doctor-documents-list'),
    ])),
    
    # Admin endpoints for doctor verification
    path('admin/doctors/<int:doctor_id>/verify/', AdminVerifyDoctorView.as_view(), 
         name='admin-verify-doctor'),
    
    # User profile management
    path('users/profile/', UserProfileView.as_view(), name='user-profile'),
    
    # User availability endpoint
    path('users/availability/', DoctorAvailabilityViewSet.as_view({'get': 'list', 'post': 'create'}), 
         name='user-availability'),

    # Search for doctors
    path('users/search-doctors/', DoctorSearchView.as_view(), name='doctor-search'),

    # Doctor related endpoints
    path('users/doctors/', DoctorListView.as_view(), name='doctor-list'),
    path('users/doctors/<int:pk>/', DoctorDetailView.as_view(), name='doctor-detail'),
    path('users/doctors/<int:pk>/availability/', DoctorAvailabilityListView.as_view(), name='doctor-availability-list'),
    path('users/doctors/<int:pk>/reviews/', DoctorReviewListView.as_view(), name='doctor-reviews-list'),

    # Doctor availability bulk operations
    path('users/doctors/availability/bulk/',
         DoctorAvailabilityViewSet.as_view({'get': 'bulk_availability'}),
         name='doctor-availability-bulk'),
    path('users/doctors/availability/bulk-update/',
         DoctorAvailabilityViewSet.as_view({'post': 'bulk_update'}),
         name='doctor-availability-bulk-update'),

    # Router URLs for ViewSets - Keep this last
    path('', include(router.urls)),
]

urlpatterns = v1_urlpatterns
