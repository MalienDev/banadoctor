'use client';

import { useState, useEffect } from 'react';
import { useParams, useRouter } from 'next/navigation';
import { StarIcon, MapPinIcon, CalendarIcon, CheckCircleIcon, PhoneIcon, EnvelopeIcon } from '@heroicons/react/24/solid';
import api from '@/lib/api';
import { useAuth } from '@/contexts/AuthContext';

// Types matching backend structure
type DoctorProfile = {
  specialization: string;
  bio: string;
  consultation_fee: number;
  address: string;
  city: string;
  country: string;
};

type Doctor = {
  id: number;
  first_name: string;
  last_name: string;
  email: string;
  phone_number: string;
  profile_picture: string | null;
  doctor_profile: DoctorProfile | null;
};

type AvailabilitySlot = {
  id: number;
  start_time: string;
  end_time: string;
  is_booked: boolean;
};

export default function DoctorDetailPage() {
  const { id: doctorId } = useParams();
  const router = useRouter();
  const { user } = useAuth();

  const [doctor, setDoctor] = useState<Doctor | null>(null);
  const [availability, setAvailability] = useState<AvailabilitySlot[]>([]);
  const [selectedDate, setSelectedDate] = useState(new Date().toISOString().split('T')[0]);
  const [selectedSlot, setSelectedSlot] = useState<AvailabilitySlot | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [bookingError, setBookingError] = useState<string | null>(null);

  useEffect(() => {
    const fetchDoctorDetails = async () => {
      if (!doctorId) return;
      try {
        setLoading(true);
        const res = await api.get(`/users/doctors/${doctorId}/`);
        setDoctor(res.data);
      } catch (err) {
        setError('Failed to fetch doctor details.');
      } finally {
        setLoading(false);
      }
    };
    fetchDoctorDetails();
  }, [doctorId]);

  useEffect(() => {
    const fetchAvailability = async () => {
      if (!doctorId || !selectedDate) return;
      try {
        const res = await api.get(`/users/doctors/${doctorId}/availability/?date=${selectedDate}`);
        setAvailability(res.data);
      } catch (err) {
        console.error('Failed to fetch availability:', err);
        setAvailability([]);
      }
    };
    fetchAvailability();
  }, [doctorId, selectedDate]);

  const handleBooking = async () => {
    if (!user || !selectedSlot || !doctor) {
      setBookingError('Please select a time slot and ensure you are logged in.');
      return;
    }
    setBookingError(null);

    try {
      // 1. Create the appointment
      const appointmentResponse = await api.post('/appointments/create/', {
        doctor_id: doctor.id,
        patient_id: user.id,
        scheduled_date: selectedDate,
        start_time: selectedSlot.start_time,
        end_time: selectedSlot.end_time,
        reason: 'Consultation',
        notes: 'Patient booked via web.',
        amount: doctor?.doctor_profile?.consultation_fee,
      });

      const appointmentId = appointmentResponse.data.id;

      // 2. Initiate payment
      const paymentResponse = await api.post(`/payments/initiate/${appointmentId}/`);
      const { payment_url } = paymentResponse.data;

      // 3. Redirect to payment gateway
      if (payment_url) {
        router.push(payment_url);
      } else {
        setBookingError('Could not retrieve payment URL. Please try again.');
      }

    } catch (err: any) {
      console.error('Booking failed:', err);
      const errorMessage = err.response?.data?.detail || 'An unexpected error occurred during booking.';
      setBookingError(errorMessage);
    }
  };

  if (loading) return <div className="flex justify-center items-center h-screen">Loading...</div>;
  if (error) return <div className="flex justify-center items-center h-screen text-red-500">{error}</div>;
  if (!doctor) return <div className="flex justify-center items-center h-screen">Doctor not found.</div>;

  if (!doctor.doctor_profile) {
    return (
      <div className="min-h-screen bg-gray-50 flex justify-center items-center">
        <div className="text-center p-8 bg-white shadow-lg rounded-lg">
          <h1 className="text-2xl font-bold text-gray-800">{`Dr. ${doctor.first_name} ${doctor.last_name}`}</h1>
          <p className="mt-2 text-gray-600">This doctor has not yet completed their profile.</p>
          <p className="mt-1 text-gray-500 text-sm">Please check back later for more details.</p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <header className="bg-white shadow">
        <div className="max-w-7xl mx-auto py-6 px-4 sm:px-6 lg:px-8">
          <h1 className="text-3xl font-bold text-gray-900">Profil du médecin</h1>
        </div>
      </header>

      <main className="max-w-7xl mx-auto py-6 sm:px-6 lg:px-8">
        <div className="bg-white shadow overflow-hidden sm:rounded-lg">
          <div className="px-4 py-5 sm:px-6 border-b border-gray-200">
            <div className="flex flex-col md:flex-row md:items-center md:justify-between">
              <div className="flex items-center">
                <div className="h-24 w-24 rounded-full bg-gray-200 overflow-hidden flex-shrink-0">
                  {doctor.profile_picture ? (
                    <img className="h-full w-full object-cover" src={doctor.profile_picture} alt={`${doctor.first_name} ${doctor.last_name}`} />
                  ) : (
                    <div className="h-full w-full flex items-center justify-center text-3xl font-bold text-gray-500">
                      {doctor.first_name.charAt(0)}{doctor.last_name.charAt(0)}
                    </div>
                  )}
                </div>
                <div className="ml-6">
                  <h2 className="text-2xl font-bold text-gray-900">Dr. {doctor.first_name} {doctor.last_name}</h2>
                  <p className="text-lg text-gray-600">{doctor.doctor_profile.specialization}</p>
                  <div className="mt-1 flex items-center">
                    <MapPinIcon className="h-5 w-5 text-gray-400 mr-1" />
                    <span className="text-gray-600">{doctor.doctor_profile.address}, {doctor.doctor_profile.city}</span>
                  </div>
                </div>
              </div>
              <div className="mt-4 md:mt-0">
                <span className="text-3xl font-bold text-gray-900">{doctor.doctor_profile.consultation_fee}€</span>
                <span className="text-base text-gray-500"> / consultation</span>
              </div>
            </div>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-8 px-4 py-5 sm:p-6">
            <div className="md:col-span-2">
              <div className="space-y-6">
                <div>
                  <h3 className="font-medium text-gray-900">À propos</h3>
                  <p className="mt-2 text-sm text-gray-600">{doctor.doctor_profile.bio}</p>
                </div>
                <div className="mt-6 border-t border-gray-200 pt-6">
                  <h4 className="text-sm font-medium text-gray-900 mb-3">Contact</h4>
                  <div className="space-y-2">
                    <div className="flex items-center">
                      <PhoneIcon className="h-5 w-5 text-gray-400 mr-2" />
                      <span className="text-sm text-gray-600">{doctor.phone_number}</span>
                    </div>
                    <div className="flex items-center">
                      <EnvelopeIcon className="h-5 w-5 text-gray-400 mr-2" />
                      <span className="text-sm text-blue-600">{doctor.email}</span>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <div className="md:col-span-1">
              <div className="bg-gray-100 p-6 rounded-lg shadow-inner">
                <h3 className="text-lg font-bold text-gray-900">Prendre un rendez-vous</h3>
                <div className="mt-4 space-y-4">
                  <div>
                    <label htmlFor="date" className="block text-sm font-medium text-gray-700">Date</label>
                    <div className="mt-1 relative rounded-md shadow-sm">
                      <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                        <CalendarIcon className="h-5 w-5 text-gray-400" />
                      </div>
                      <input
                        type="date"
                        name="date"
                        id="date"
                        value={selectedDate}
                        onChange={(e) => setSelectedDate(e.target.value)}
                        className="focus:ring-primary-500 focus:border-primary-500 block w-full pl-10 sm:text-sm border-gray-300 rounded-md h-10"
                        min={new Date().toISOString().split('T')[0]}
                      />
                    </div>
                  </div>

                  <div>
                    <label className="block text-sm font-medium text-gray-700">Heure</label>
                    <div className="mt-2 grid grid-cols-3 gap-2">
                      {availability.length > 0 ? (
                        availability.map((slot) => (
                          <button
                            key={slot.id}
                            onClick={() => setSelectedSlot(slot)}
                            disabled={slot.is_booked}
                            className={`px-3 py-2 text-sm rounded-md text-center ${slot.is_booked ? 'bg-gray-300 cursor-not-allowed' : selectedSlot?.id === slot.id ? 'bg-primary-600 text-white' : 'bg-white hover:bg-primary-100'}`}
                          >
                            {new Date(`1970-01-01T${slot.start_time}`).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                          </button>
                        ))
                      ) : (
                        <p className="col-span-3 text-sm text-gray-500">Aucune disponibilité pour cette date.</p>
                      )}
                    </div>
                  </div>

                  {bookingError && <p className="text-sm text-red-600">{bookingError}</p>}

                  <div className="pt-2">
                    <button
                      type="button"
                      onClick={handleBooking}
                      disabled={!selectedSlot || loading}
                      className="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-primary-600 hover:bg-primary-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500 disabled:bg-gray-400"
                    >
                      {loading ? 'Réservation...' : `Confirmer et payer (${doctor.doctor_profile.consultation_fee}€)`}
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </main>
    </div>
  );
}
