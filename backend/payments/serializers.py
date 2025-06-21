from rest_framework import serializers
from .models import Payment

class PaymentSerializer(serializers.ModelSerializer):
    """
    Serializer for the Payment model.
    """
    class Meta:
        model = Payment
        fields = '__all__'
        read_only_fields = ('id', 'status', 'created_at', 'updated_at')
