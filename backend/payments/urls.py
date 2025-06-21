from django.urls import path
from .views import InitiatePaymentView, stripe_webhook

app_name = 'payments'

urlpatterns = [
    path('initiate/<int:appointment_id>/', InitiatePaymentView.as_view(), name='initiate-payment'),
    path('webhook/', stripe_webhook, name='stripe-webhook'),
]
