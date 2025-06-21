import stripe
from django.conf import settings
from django.db import transaction
from django.shortcuts import get_object_or_404
from django.http import HttpResponse
from django.views.decorators.csrf import csrf_exempt
from rest_framework import permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView

from appointments.models import Appointment
from .models import Payment

# Set Stripe API key from settings
stripe.api_key = settings.STRIPE_SECRET_KEY

# This should be an environment variable in a real application
FRONTEND_DOMAIN = 'http://localhost:3000'

class InitiatePaymentView(APIView):
    """
    Creates a Stripe Checkout Session for an appointment and returns the payment URL.
    """
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, *args, **kwargs):
        appointment_id = self.kwargs.get('appointment_id')
        appointment = get_object_or_404(Appointment, id=appointment_id, patient=request.user)

        if appointment.is_paid:
            return Response({'error': 'This appointment has already been paid for.'}, status=status.HTTP_400_BAD_REQUEST)

        try:
            checkout_session = stripe.checkout.Session.create(
                payment_method_types=['card'],
                line_items=[
                    {
                        'price_data': {
                            'currency': 'usd',
                            'product_data': {
                                'name': f'Appointment with Dr. {appointment.doctor.user.get_full_name()}',
                                'description': f'Scheduled on {appointment.scheduled_date} at {appointment.start_time}',
                            },
                            'unit_amount': int(appointment.amount * 100),  # Amount in cents
                        },
                        'quantity': 1,
                    }
                ],
                mode='payment',
                success_url=f'{FRONTEND_DOMAIN}/payment/success?session_id={{CHECKOUT_SESSION_ID}}',
                cancel_url=f'{FRONTEND_DOMAIN}/payment/cancel',
                client_reference_id=str(appointment.id),
            )

            Payment.objects.update_or_create(
                appointment=appointment,
                defaults={
                    'amount': appointment.amount,
                    'status': 'pending',
                    'session_id': checkout_session.id,
                    'payment_method': 'stripe'
                }
            )

            return Response({'payment_url': checkout_session.url}, status=status.HTTP_201_CREATED)

        except Exception as e:
            return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)


@csrf_exempt
def stripe_webhook(request):
    """
    Stripe webhook view to handle payment confirmation events.
    """
    payload = request.body
    sig_header = request.META.get('HTTP_STRIPE_SIGNATURE')
    endpoint_secret = settings.STRIPE_WEBHOOK_SECRET
    event = None

    try:
        event = stripe.Webhook.construct_event(
            payload, sig_header, endpoint_secret
        )
    except ValueError:
        # Invalid payload
        return HttpResponse(status=400)
    except stripe.error.SignatureVerificationError:
        # Invalid signature
        return HttpResponse(status=400)

    if event['type'] == 'checkout.session.completed':
        session = event['data']['object']
        session_id = session.get('id')

        try:
            with transaction.atomic():
                payment = Payment.objects.get(session_id=session_id)
                
                if payment.status == 'completed':
                    return HttpResponse(status=200)

                payment.status = 'completed'
                payment.transaction_id = session.get('payment_intent')
                payment.save()

                appointment = payment.appointment
                appointment.is_paid = True
                appointment.status = 'confirmed'
                appointment.save()

                # TODO: Send confirmation notifications

        except Payment.DoesNotExist:
            return HttpResponse(status=404)
        except Exception as e:
            print(f"Error processing webhook: {e}")
            return HttpResponse(status=500)

    return HttpResponse(status=200)
