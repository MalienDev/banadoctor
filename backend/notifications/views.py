from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView
from .models import Notification
from .serializers import NotificationSerializer

class NotificationListView(generics.ListAPIView):
    """
    List all notifications for the authenticated user.
    Optionally filters for unread notifications only.
    """
    serializer_class = NotificationSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        queryset = Notification.objects.filter(recipient=user)
        
        # Filter for unread notifications if the 'unread' query param is present
        unread_only = self.request.query_params.get('unread', 'false').lower() == 'true'
        if unread_only:
            queryset = queryset.filter(is_read=False)
            
        return queryset

class MarkNotificationAsReadView(APIView):
    """
    Mark a specific notification as read.
    """
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, notification_id, *args, **kwargs):
        try:
            notification = Notification.objects.get(id=notification_id, recipient=request.user)
        except Notification.DoesNotExist:
            return Response({'error': 'Notification not found.'}, status=status.HTTP_404_NOT_FOUND)

        if not notification.is_read:
            notification.is_read = True
            notification.save()

        return Response({'status': 'Notification marked as read.'}, status=status.HTTP_200_OK)

class MarkAllNotificationsAsReadView(APIView):
    """
    Mark all unread notifications for the authenticated user as read.
    """
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, *args, **kwargs):
        updated_count = Notification.objects.filter(recipient=request.user, is_read=False).update(is_read=True)
        return Response({'status': f'{updated_count} notifications marked as read.'}, status=status.HTTP_200_OK)

