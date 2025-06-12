import { CalendarIcon, ClockIcon, MapPinIcon, PencilIcon, TrashIcon } from '@heroicons/react/24/solid';
import React from 'react';

// This should match the type in your appointments page
type Appointment = {
  id: number;
  scheduled_date: string;
  start_time: string;
  end_time: string;
  status: 'pending' | 'confirmed' | 'completed' | 'cancelled' | 'no_show';
  status_display: string;
  appointment_type: 'in_person' | 'video';
  type_display: string;
  patient_name: string;
  doctor_name: string;
  is_paid: boolean;
  amount: number;
  doctor_specialty?: string;
  doctor_avatar?: string;
  location?: string;
  meetingLink?: string;
};

const statusStyles: { [key: string]: string } = {
  confirmed: 'bg-green-100 text-green-800',
  pending: 'bg-yellow-100 text-yellow-800',
  cancelled: 'bg-red-100 text-red-800',
  completed: 'bg-blue-100 text-blue-800',
  no_show: 'bg-gray-100 text-gray-800',
};

interface AppointmentCardProps {
  appointment: Appointment;
  isPast?: boolean;
}

const formatDate = (dateString: string) => {
  const options: Intl.DateTimeFormatOptions = { year: 'numeric', month: 'long', day: 'numeric' };
  return new Date(dateString).toLocaleDateString('fr-FR', options);
};

const formatTime = (timeString: string) => {
  return timeString.substring(0, 5);
};

export default function AppointmentCard({ appointment, isPast = false }: AppointmentCardProps) {
  return (
    <li>
      <div className="px-4 py-4 sm:px-6">
        <div className="flex items-center justify-between">
          <div className="flex items-center">
            <div className="h-12 w-12 rounded-full bg-gray-200 overflow-hidden flex-shrink-0">
              {appointment.doctor_avatar ? (
                <img src={appointment.doctor_avatar} alt={`Dr. ${appointment.doctor_name}`} className="h-full w-full object-cover" />
              ) : (
                <div className="h-full w-full flex items-center justify-center text-lg font-bold text-gray-500">
                  {appointment.doctor_name.charAt(0)}
                </div>
              )}
            </div>
            <div className="ml-4">
              <h3 className="text-lg font-medium text-gray-900">{appointment.doctor_name}</h3>
              <p className="text-sm text-gray-500">{appointment.doctor_specialty}</p>
            </div>
          </div>
          <div className="flex flex-col items-end">
            <span className="px-2.5 py-0.5 rounded-full text-xs font-medium capitalize">
              {appointment.type_display}
            </span>
            <span className={`mt-1 inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${statusStyles[appointment.status]}`}>
              {appointment.status_display}
            </span>
          </div>
        </div>
        <div className="mt-4 sm:flex sm:justify-between">
          <div className="flex items-center text-sm text-gray-500">
            <CalendarIcon className="flex-shrink-0 mr-1.5 h-5 w-5 text-gray-400" />
            <p>{formatDate(appointment.scheduled_date)}</p>
          </div>
          <div className="flex items-center mt-2 sm:mt-0 text-sm text-gray-500">
            <ClockIcon className="flex-shrink-0 mr-1.5 h-5 w-5 text-gray-400" />
            <p>{formatTime(appointment.start_time)} - {formatTime(appointment.end_time)}</p>
          </div>
          {appointment.location && (
            <div className="flex items-center mt-2 sm:mt-0 text-sm text-gray-500">
              <MapPinIcon className="flex-shrink-0 mr-1.5 h-5 w-5 text-gray-400" />
              <p>{appointment.location}</p>
            </div>
          )}
        </div>
        {!isPast && (appointment.status === 'confirmed' || appointment.status === 'pending') && (
          <div className="mt-4 flex justify-end space-x-3">
            <button type="button" className="inline-flex items-center px-3 py-1.5 border border-gray-300 text-xs font-medium rounded text-gray-700 bg-white hover:bg-gray-50">
              <PencilIcon className="-ml-0.5 mr-1.5 h-4 w-4 text-gray-400" />
              Modifier
            </button>
            <button type="button" className="inline-flex items-center px-3 py-1.5 border border-transparent text-xs font-medium rounded text-white bg-red-600 hover:bg-red-700">
              <TrashIcon className="-ml-0.5 mr-1.5 h-4 w-4" />
              Annuler
            </button>
          </div>
        )}
        {isPast && appointment.status === 'completed' && (
          <div className="mt-4 flex justify-end">
            <button type="button" className="inline-flex items-center px-3 py-1.5 border border-transparent text-xs font-medium rounded text-white bg-primary-600 hover:bg-primary-700">
              Laisser un avis
            </button>
          </div>
        )}
      </div>
    </li>
  );
}
