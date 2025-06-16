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
from django.urls import path, include, re_path
from django.shortcuts import redirect
from django.conf import settings
from django.conf.urls.static import static
from django.http import HttpResponse, JsonResponse
from django.views.generic import TemplateView, RedirectView
from django.contrib.staticfiles.storage import staticfiles_storage

# REST Framework imports
from rest_framework_simplejwt.views import (
    TokenObtainPairView,
    TokenRefreshView,
    TokenVerifyView,
)


# Define a simple view for the API root
def api_v1_root_view(request):
    return HttpResponse("Welcome to the Medecin API v1. Available endpoints: /auth/, /appointments/, /token/verify/, /token/refresh/")

# API v1 URL patterns
v1_patterns = [
    # Include all URLs from the 'users' app under this version
    path('', include('users.urls')),
    
    # Include all URLs from the 'appointments' app
    path('appointments/', include('appointments.urls')),
]

urlpatterns = [
    # Admin site
    path('admin/', admin.site.urls),

    # API routes - versioned under /api/v1/
    path('api/v1/', include(v1_patterns)),

    # Health check endpoint
    path('health/', lambda r: JsonResponse({'status': 'ok'})),
    
    # Favicon
    path('favicon.ico', RedirectView.as_view(url=staticfiles_storage.url('images/favicon.ico')), name='favicon'),

    # Frontend catch-all for client-side routing
    re_path(r'^(?!api/|admin/|media/|static/).*$',
            TemplateView.as_view(template_name='index.html'),
            name='frontend'),

    # Root path should be last as a catch-all or redirect
    path('', api_v1_root_view, name='project_root'),
]

# Serve media files in development
if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
    urlpatterns += static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)
    
    # Debug toolbar
    import debug_toolbar
    urlpatterns = [
        path('__debug__/', include(debug_toolbar.urls)),
    ] + urlpatterns

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
