"use client";
import { CalendarIcon, ClockIcon, MapPinIcon, VideoCameraIcon, UserIcon } from '@heroicons/react/24/solid';
import { useRouter } from 'next/navigation';
import { useState } from 'react';

type Appointment = {
  id: number;
  doctor: {
    name: string;
    specialty: string;
    avatar: string;
  };
  currentDate: string;
  currentTime: string;
  type: 'in-person' | 'video';
  location?: string;
  availableSlots: {
    date: string;
    times: string[];
  }[];
};

// Mock data for the appointment
const appointment: Appointment = {
  id: 1,
  doctor: {
    name: 'Dr. Marie Dupont',
    specialty: 'Cardiologue',
    avatar: '/doctors/doctor1.jpg',
  },
  currentDate: '2025-06-15',
  currentTime: '10:00',
  type: 'in-person',
  location: '123 Rue de Paris, 75001 Paris',
  availableSlots: [
    {
      date: '2025-06-15',
      times: ['09:00', '09:30', '10:00', '10:30', '14:00', '14:30', '15:00', '15:30', '16:00', '16:30', '17:00'],
    },
    {
      date: '2025-06-16',
      times: ['09:00', '09:30', '10:00', '10:30', '14:00', '14:30', '15:00', '15:30', '16:00', '16:30', '17:00'],
    },
    {
      date: '2025-06-17',
      times: ['09:00', '09:30', '10:00', '10:30', '14:00', '14:30', '15:00', '15:30', '16:00', '16:30', '17:00'],
    },
    {
      date: '2025-06-18',
      times: ['09:00', '09:30', '10:00', '10:30', '14:00', '14:30', '15:00', '15:30', '16:00', '16:30', '17:00'],
    },
    {
      date: '2025-06-19',
      times: ['09:00', '09:30', '10:00', '10:30', '14:00', '14:30', '15:00', '15:30', '16:00', '16:30', '17:00'],
    },
  ],
};

export default function EditAppointmentPage() {
  const router = useRouter();
  const [selectedDate, setSelectedDate] = useState(appointment.currentDate);
  const [selectedTime, setSelectedTime] = useState(appointment.currentTime);
  const [appointmentType, setAppointmentType] = useState(appointment.type);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [isCancelling, setIsCancelling] = useState(false);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setIsSubmitting(true);
    
    // Simulate API call
    setTimeout(() => {
      console.log('Appointment updated:', { selectedDate, selectedTime, appointmentType });
      setIsSubmitting(false);
      router.push('/appointments');
    }, 1000);
  };

  const handleCancel = () => {
    if (window.confirm('Êtes-vous sûr de vouloir annuler ce rendez-vous ?')) {
      setIsCancelling(true);
      
      // Simulate API call
      setTimeout(() => {
        console.log('Appointment cancelled');
        setIsCancelling(false);
        router.push('/appointments');
      }, 1000);
    }
  };

  const selectedDateData = appointment.availableSlots.find(slot => slot.date === selectedDate);
  const availableTimes = selectedDateData?.times || [];

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white shadow">
        <div className="max-w-7xl mx-auto py-6 px-4 sm:px-6 lg:px-8">
          <h1 className="text-3xl font-bold text-gray-900">Modifier le rendez-vous</h1>
        </div>
      </header>

      <main className="max-w-7xl mx-auto py-6 sm:px-6 lg:px-8">
        <div className="px-4 sm:px-0">
          <div className="bg-white shadow overflow-hidden sm:rounded-lg">
            <div className="px-4 py-5 sm:px-6 border-b border-gray-200">
              <h2 className="text-lg font-medium text-gray-900">Détails du médecin</h2>
            </div>
            <div className="px-4 py-5 sm:p-6">
              <div className="flex items-center">
                <div className="h-16 w-16 rounded-full bg-gray-200 overflow-hidden flex-shrink-0">
                  <div className="h-full w-full flex items-center justify-center text-xl font-bold text-gray-500">
                    {appointment.doctor.name.charAt(0)}
                  </div>
                </div>
                <div className="ml-4">
                  <h3 className="text-lg font-medium text-gray-900">{appointment.doctor.name}</h3>
                  <p className="text-sm text-gray-500">{appointment.doctor.specialty}</p>
                  <div className="mt-1 flex items-center text-sm text-gray-500">
                    <MapPinIcon className="flex-shrink-0 mr-1.5 h-4 w-4 text-gray-400" />
                    <span>{appointment.location}</span>
                  </div>
                </div>
              </div>

              <form onSubmit={handleSubmit} className="mt-8 space-y-8">
                {/* Appointment Type */}
                <div>
                  <h3 className="text-lg font-medium text-gray-900 mb-4">Type de rendez-vous</h3>
                  <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
                    <button
                      type="button"
                      onClick={() => setAppointmentType('in-person')}
                      className={`relative rounded-lg border p-4 flex flex-col items-center ${
                        appointmentType === 'in-person'
                          ? 'border-primary-500 bg-primary-50'
                          : 'border-gray-300 bg-white hover:bg-gray-50'
                      }`}
                    >
                      <div className="h-10 w-10 rounded-full bg-primary-100 flex items-center justify-center mb-2">
                        <UserIcon
                          className={`h-5 w-5 ${
                            appointmentType === 'in-person' ? 'text-primary-600' : 'text-gray-600'
                          }`}
                        />
                      </div>
                      <span className="text-sm font-medium text-gray-900">En personne</span>
                      <span className="text-xs text-gray-500 mt-1">Consultation au cabinet</span>
                      {appointmentType === 'in-person' && (
                        <div className="absolute -top-2 -right-2 h-5 w-5 rounded-full bg-primary-600 flex items-center justify-center">
                          <svg
                            className="h-3.5 w-3.5 text-white"
                            fill="currentColor"
                            viewBox="0 0 20 20"
                            xmlns="http://www.w3.org/2000/svg"
                          >
                            <path
                              fillRule="evenodd"
                              d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z"
                              clipRule="evenodd"
                            />
                          </svg>
                        </div>
                      )}
                    </button>
                    <button
                      type="button"
                      onClick={() => setAppointmentType('video')}
                      className={`relative rounded-lg border p-4 flex flex-col items-center ${
                        appointmentType === 'video'
                          ? 'border-primary-500 bg-primary-50'
                          : 'border-gray-300 bg-white hover:bg-gray-50'
                      }`}
                    >
                      <div className="h-10 w-10 rounded-full bg-primary-100 flex items-center justify-center mb-2">
                        <VideoCameraIcon
                          className={`h-5 w-5 ${
                            appointmentType === 'video' ? 'text-primary-600' : 'text-gray-600'
                          }`}
                        />
                      </div>
                      <span className="text-sm font-medium text-gray-900">Vidéo</span>
                      <span className="text-xs text-gray-500 mt-1">Consultation à distance</span>
                      {appointmentType === 'video' && (
                        <div className="absolute -top-2 -right-2 h-5 w-5 rounded-full bg-primary-600 flex items-center justify-center">
                          <svg
                            className="h-3.5 w-3.5 text-white"
                            fill="currentColor"
                            viewBox="0 0 20 20"
                            xmlns="http://www.w3.org/2000/svg"
                          >
                            <path
                              fillRule="evenodd"
                              d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z"
                              clipRule="evenodd"
                            />
                          </svg>
                        </div>
                      )}
                    </button>
                  </div>
                </div>

                {/* Date Picker */}
                <div>
                  <h3 className="text-lg font-medium text-gray-900 mb-4">Date du rendez-vous</h3>
                  <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-5 gap-3">
                    {appointment.availableSlots.map((slot) => {
                      const date = new Date(slot.date);
                      const dayName = date.toLocaleDateString('fr-FR', { weekday: 'short' });
                      const dayNumber = date.getDate();
                      const month = date.toLocaleDateString('fr-FR', { month: 'short' });
                      const isSelected = selectedDate === slot.date;

                      return (
                        <button
                          key={slot.date}
                          type="button"
                          onClick={() => setSelectedDate(slot.date)}
                          className={`flex flex-col items-center justify-center py-3 px-2 rounded-lg border ${
                            isSelected
                              ? 'border-primary-500 bg-primary-50'
                              : 'border-gray-300 bg-white hover:bg-gray-50'
                          }`}
                        >
                          <span className="text-xs text-gray-500 uppercase">{dayName}</span>
                          <span className="text-xl font-semibold text-gray-900">{dayNumber}</span>
                          <span className="text-xs text-gray-500">{month}</span>
                        </button>
                      );
                    })}
                  </div>
                </div>

                {/* Time Slots */}
                <div>
                  <h3 className="text-lg font-medium text-gray-900 mb-4">Heure du rendez-vous</h3>
                  <div className="grid grid-cols-3 sm:grid-cols-4 md:grid-cols-6 gap-3">
                    {availableTimes.map((time) => (
                      <button
                        key={time}
                        type="button"
                        onClick={() => setSelectedTime(time)}
                        className={`py-2 px-3 rounded-md text-sm font-medium ${
                          selectedTime === time
                            ? 'bg-primary-600 text-white'
                            : 'bg-white text-gray-900 border border-gray-300 hover:bg-gray-50'
                        }`}
                      >
                        {time}
                      </button>
                    ))}
                  </div>
                </div>

                {/* Summary */}
                <div className="bg-gray-50 p-4 rounded-lg">
                  <h3 className="text-lg font-medium text-gray-900 mb-4">Récapitulatif</h3>
                  <div className="space-y-2">
                    <div className="flex justify-between">
                      <span className="text-gray-600">Date</span>
                      <span className="font-medium text-gray-900">
                        {new Date(selectedDate).toLocaleDateString('fr-FR', {
                          weekday: 'long',
                          day: 'numeric',
                          month: 'long',
                          year: 'numeric',
                        })}
                      </span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-gray-600">Heure</span>
                      <span className="font-medium text-gray-900">{selectedTime}</span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-gray-600">Type</span>
                      <span className="font-medium text-gray-900">
                        {appointmentType === 'in-person' ? 'En personne' : 'Vidéo'}
                      </span>
                    </div>
                    {appointmentType === 'in-person' && appointment.location && (
                      <div className="flex justify-between">
                        <span className="text-gray-600">Lieu</span>
                        <span className="font-medium text-gray-900 text-right">
                          {appointment.location}
                        </span>
                      </div>
                    )}
                  </div>
                </div>

                {/* Actions */}
                <div className="flex flex-col-reverse sm:flex-row justify-end space-y-4 sm:space-y-0 sm:space-x-4">
                  <button
                    type="button"
                    onClick={handleCancel}
                    disabled={isCancelling || isSubmitting}
                    className="inline-flex justify-center items-center px-4 py-2 border border-red-300 shadow-sm text-sm font-medium rounded-md text-red-700 bg-white hover:bg-red-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500 disabled:opacity-50 disabled:cursor-not-allowed"
                  >
                    {isCancelling ? 'Annulation...' : 'Annuler le rendez-vous'}
                  </button>
                  <button
                    type="submit"
                    disabled={isSubmitting || isCancelling}
                    className="inline-flex justify-center items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-primary-600 hover:bg-primary-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500 disabled:opacity-50 disabled:cursor-not-allowed"
                  >
                    {isSubmitting ? 'Enregistrement...' : 'Enregistrer les modifications'}
                  </button>
                </div>
              </form>
            </div>
          </div>
        </div>
      </main>
    </div>
  );
}
