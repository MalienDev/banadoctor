from django_filters.rest_framework import DjangoFilterBackend, FilterSet, CharFilter, NumberFilter, DateFilter
from rest_framework import generics, permissions, filters
from users.models import User
from users.serializers import DoctorProfileSerializer
from django.db.models import Q

class DoctorFilter(FilterSet):
    """
    FilterSet for advanced doctor searching.
    """
    specialization = CharFilter(field_name='doctor_profile__specializations__name', lookup_expr='icontains')
    city = CharFilter(field_name='city', lookup_expr='icontains')
    min_fee = NumberFilter(field_name='doctor_profile__consultation_fee', lookup_expr='gte')
    max_fee = NumberFilter(field_name='doctor_profile__consultation_fee', lookup_expr='lte')
    available_on = DateFilter(method='filter_available_on', label="Available on a specific date (YYYY-MM-DD)")

    class Meta:
        model = User
        fields = ['specialization', 'city', 'min_fee', 'max_fee', 'available_on']

    def filter_available_on(self, queryset, name, value):
        """
        Filters doctors who are available on a specific date.
        """
        if value:
            day_of_week = value.weekday()
            # Filter based on DoctorAvailability model
            return queryset.filter(
                availabilities__day_of_week=day_of_week,
                availabilities__is_available=True
            ).distinct()
        return queryset


class DoctorSearchView(generics.ListAPIView):
    """
    Provides a search endpoint for finding doctors based on various criteria.
    Supports filtering by specialization, location, consultation fee, and availability.
    Also supports full-text search on name, bio, and specialization.
    """
    queryset = User.objects.filter(
        user_type='doctor',
        is_doctor_verified=True,
        is_active=True
    ).select_related('doctor_profile').prefetch_related('doctor_profile__specializations', 'availabilities')
    
    serializer_class = DoctorProfileSerializer
    permission_classes = [permissions.AllowAny]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_class = DoctorFilter
    search_fields = ('first_name', 'last_name', 'doctor_profile__bio', 'doctor_profile__specializations__name')
    ordering_fields = ('doctor_profile__average_rating', 'doctor_profile__years_of_experience', 'first_name')
    ordering = ('-doctor_profile__average_rating',)
