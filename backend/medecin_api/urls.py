"""
URL configuration for medecin_api project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/5.2/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path, include
from django.shortcuts import redirect
from django.conf import settings
from django.conf.urls.static import static
from django.http import HttpResponse

# REST Framework imports
from rest_framework_simplejwt.views import (
    TokenObtainPairView,
    TokenRefreshView,
    TokenVerifyView,
)

# Define a simple view for the API root
def api_v1_root_view(request):
    return HttpResponse("Welcome to the Medecin API v1. Available endpoints: /auth/, /appointments/, /token/verify/, /token/refresh/")

# API URL patterns
api_patterns = [
    path('', api_v1_root_view, name='api_v1_root'),
    # Authentication
    path('auth/', include('users.urls')),
    
    # Appointments
    path('appointments/', include('appointments.urls')),
    
    # JWT Token endpoints
    path('token/verify/', TokenVerifyView.as_view(), name='token_verify'),
    path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
]

urlpatterns = [
    # Root URL redirects to API v1
    path('', lambda request: redirect('api/v1/')),
    
    # Admin site
    path('admin/', admin.site.urls),
    
    # API endpoints (versioned)
    path('api/v1/', include(api_patterns)),
]

# Serve media files in development
if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)

# Add API documentation URL (will be added later with drf-yasg or drf-spectacular)
# from drf_yasg.views import get_schema_view
# from drf_yasg import openapi
# 
# schema_view = get_schema_view(
#     openapi.Info(
#         title="Medecin Africa API",
#         default_version='v1',
#         description="API for Medecin Africa - Medical Appointment Platform",
#     ),
#     public=True,
# )
# 
# urlpatterns += [
#     path('api/docs/', schema_view.with_ui('swagger', cache_timeout=0), name='schema-swagger-ui'),
#     path('api/redoc/', schema_view.with_ui('redoc', cache_timeout=0), name='schema-redoc'),
# ]
