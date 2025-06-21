from rest_framework.permissions import BasePermission

class IsDoctorOrAdmin(BasePermission):
    """
    Custom permission to only allow doctors or admins to access certain views.
    """
    def has_permission(self, request, view):
        return request.user.user_type in ['doctor', 'admin']
