from rest_framework import serializers
from .models import Notification

class NotificationSerializer(serializers.ModelSerializer):
    """
    Serializer for the Notification model.
    """
    class Meta:
        model = Notification
        fields = ('id', 'recipient', 'message', 'notification_type', 'is_read', 'created_at', 'content_type', 'object_id')
        read_only_fields = ('id', 'created_at')
