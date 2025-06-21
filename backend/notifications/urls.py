from django.urls import path
from .views import (
    NotificationListView,
    MarkNotificationAsReadView,
    MarkAllNotificationsAsReadView
)

app_name = 'notifications'

urlpatterns = [
    path('', NotificationListView.as_view(), name='notification-list'),
    path('<uuid:notification_id>/mark-as-read/', MarkNotificationAsReadView.as_view(), name='mark-notification-as-read'),
    path('mark-all-as-read/', MarkAllNotificationsAsReadView.as_view(), name='mark-all-notifications-as-read'),
]
