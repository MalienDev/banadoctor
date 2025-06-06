import { CalendarIcon, ClockIcon, MapPinIcon, PencilIcon, PlusIcon, TrashIcon } from '@heroicons/react/24/solid'; // 
import Link from 'next/link';

type Appointment = {
  id: number;
  doctor: {
    name: string;
    specialty: string;
    avatar: string;
  };
  date: string;
  time: string;
  status: 'confirmed' | 'pending' | 'cancelled' | 'completed';
  type: 'in-person' | 'video';
  location?: string;
  meetingLink?: string;
};

const appointments: Appointment[] = [
  {
    id: 1,
    doctor: {
      name: 'Dr. Marie Dupont',
      specialty: 'Cardiologue',
      avatar: '/doctors/doctor1.jpg',
    },
    date: '15 Juin 2025',
    time: '10:00 - 10:30',
    status: 'confirmed',
    type: 'in-person',
    location: '123 Rue de Paris, 75001 Paris',
  },
  {
    id: 2,
    doctor: {
      name: 'Dr. Jean Martin',
      specialty: 'Dermatologue',
      avatar: '/doctors/doctor2.jpg',
    },
    date: '20 Juin 2025',
    time: '14:30 - 15:00',
    status: 'pending',
    type: 'video',
    meetingLink: 'https://meet.example.com/abc123',
  },
  {
    id: 3,
    doctor: {
      name: 'Dr. Sophie Dubois',
      specialty: 'Pédiatre',
      avatar: '/doctors/doctor3.jpg',
    },
    date: '25 Mai 2025',
    time: '11:00 - 11:30',
    status: 'completed',
    type: 'in-person',
    location: '789 Boulevard Saint-Germain, 75006 Paris',
  },
  {
    id: 4,
    doctor: {
      name: 'Dr. Thomas Leroy',
      specialty: 'Ophtalmologue',
      avatar: '/doctors/doctor4.jpg',
    },
    date: '10 Mai 2025',
    time: '16:00 - 16:30',
    status: 'cancelled',
    type: 'video',
    meetingLink: 'https://meet.example.com/def456',
  },
];

const statusStyles = {
  confirmed: 'bg-green-100 text-green-800',
  pending: 'bg-yellow-100 text-yellow-800',
  cancelled: 'bg-red-100 text-red-800',
  completed: 'bg-blue-100 text-blue-800',
};

const statusLabels = {
  confirmed: 'Confirmé',
  pending: 'En attente',
  cancelled: 'Annulé',
  completed: 'Terminé',
};

export default function AppointmentsPage() {
  const upcomingAppointments = appointments.filter(
    (appt) => appt.status === 'confirmed' || appt.status === 'pending'
  );
  
  const pastAppointments = appointments.filter(
    (appt) => appt.status === 'completed' || appt.status === 'cancelled'
  );

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white shadow">
        <div className="max-w-7xl mx-auto py-6 px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center">
            <h1 className="text-3xl font-bold text-gray-900">Mes rendez-vous</h1>
            <Link
              href="/doctors"
              className="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-primary-600 hover:bg-primary-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500"
            >
              Prendre rendez-vous
            </Link>
          </div>
        </div>
      </header>

      <main className="max-w-7xl mx-auto py-6 sm:px-6 lg:px-8">
        <div className="px-4 sm:px-0">
          {/* Upcoming Appointments */}
          <div className="mb-12">
            <h2 className="text-xl font-medium text-gray-900 mb-6">Rendez-vous à venir</h2>
            {upcomingAppointments.length > 0 ? (
              <div className="bg-white shadow overflow-hidden sm:rounded-lg">
                <ul className="divide-y divide-gray-200">
                  {upcomingAppointments.map((appointment) => (
                    <li key={appointment.id}>
                      <div className="px-4 py-4 sm:px-6">
                        <div className="flex items-center justify-between">
                          <div className="flex items-center">
                            <div className="h-12 w-12 rounded-full bg-gray-200 overflow-hidden flex-shrink-0">
                              <div className="h-full w-full flex items-center justify-center text-lg font-bold text-gray-500">
                                {appointment.doctor.name.charAt(0)}
                              </div>
                            </div>
                            <div className="ml-4">
                              <h3 className="text-lg font-medium text-gray-900">
                                {appointment.doctor.name}
                              </h3>
                              <p className="text-sm text-gray-500">{appointment.doctor.specialty}</p>
                            </div>
                          </div>
                          <div className="flex flex-col items-end">
                            <span className="px-2.5 py-0.5 rounded-full text-xs font-medium capitalize">
                              {appointment.type === 'in-person' ? 'En personne' : 'Téléconsultation'}
                            </span>
                            <span className={`mt-1 inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${statusStyles[appointment.status]}`}>
                              {statusLabels[appointment.status]}
                            </span>
                          </div>
                        </div>
                        <div className="mt-4 sm:flex sm:justify-between">
                          <div className="flex items-center text-sm text-gray-500">
                            <CalendarIcon className="flex-shrink-0 mr-1.5 h-5 w-5 text-gray-400" />
                            <p>{appointment.date}</p>
                          </div>
                          <div className="flex items-center mt-2 sm:mt-0 text-sm text-gray-500">
                            <ClockIcon className="flex-shrink-0 mr-1.5 h-5 w-5 text-gray-400" />
                            <p>{appointment.time}</p>
                          </div>
                          {appointment.location && (
                            <div className="flex items-center mt-2 sm:mt-0 text-sm text-gray-500">
                              <MapPinIcon className="flex-shrink-0 mr-1.5 h-5 w-5 text-gray-400" />
                              <p>{appointment.location}</p>
                            </div>
                          )}
                        </div>
                        <div className="mt-4 flex justify-end space-x-3">
                          {appointment.meetingLink && (
                            <a
                              href={appointment.meetingLink}
                              target="_blank"
                              rel="noopener noreferrer"
                              className="inline-flex items-center px-3 py-1.5 border border-transparent text-xs font-medium rounded text-primary-700 bg-primary-100 hover:bg-primary-200 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500"
                            >
                              Rejoindre la consultation
                            </a>
                          )}
                          <Link
                            href={`/appointments/${appointment.id}/edit`}
                            className="inline-flex items-center px-3 py-1.5 border border-gray-300 shadow-sm text-xs font-medium rounded text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500"
                          >
                            <PencilIcon className="-ml-0.5 mr-1.5 h-4 w-4" />
                            Modifier
                          </Link>
                          <button
                            type="button"
                            className="inline-flex items-center px-3 py-1.5 border border-transparent text-xs font-medium rounded text-red-700 bg-red-100 hover:bg-red-200 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500"
                          >
                            <TrashIcon className="-ml-0.5 mr-1.5 h-4 w-4" />
                            Annuler
                          </button>
                        </div>
                      </div>
                    </li>
                  ))}
                </ul>
              </div>
            ) : (
              <div className="text-center bg-white py-12 rounded-lg shadow">
                <svg
                  className="mx-auto h-12 w-12 text-gray-400"
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke="currentColor"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth={1}
                    d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"
                  />
                </svg>
                <h3 className="mt-2 text-sm font-medium text-gray-900">Aucun rendez-vous à venir</h3>
                <p className="mt-1 text-sm text-gray-500">
                  Prenez votre premier rendez-vous avec un de nos médecins.
                </p>
                <div className="mt-6">
                  <Link
                    href="/doctors"
                    className="inline-flex items-center px-4 py-2 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-primary-600 hover:bg-primary-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500"
                  >
                    <PlusIcon className="-ml-1 mr-2 h-5 w-5" />
                    Prendre rendez-vous
                  </Link>
                </div>
              </div>
            )}
          </div>

          {/* Past Appointments */}
          {pastAppointments.length > 0 && (
            <div>
              <h2 className="text-xl font-medium text-gray-900 mb-6">Historique des rendez-vous</h2>
              <div className="bg-white shadow overflow-hidden sm:rounded-lg">
                <ul className="divide-y divide-gray-200">
                  {pastAppointments.map((appointment) => (
                    <li key={appointment.id}>
                      <div className="px-4 py-4 sm:px-6">
                        <div className="flex items-center justify-between">
                          <div className="flex items-center">
                            <div className="h-12 w-12 rounded-full bg-gray-200 overflow-hidden flex-shrink-0">
                              <div className="h-full w-full flex items-center justify-center text-lg font-bold text-gray-500">
                                {appointment.doctor.name.charAt(0)}
                              </div>
                            </div>
                            <div className="ml-4">
                              <h3 className="text-lg font-medium text-gray-900">
                                {appointment.doctor.name}
                              </h3>
                              <p className="text-sm text-gray-500">{appointment.doctor.specialty}</p>
                            </div>
                          </div>
                          <div className="flex flex-col items-end">
                            <span className="px-2.5 py-0.5 rounded-full text-xs font-medium capitalize">
                              {appointment.type === 'in-person' ? 'En personne' : 'Téléconsultation'}
                            </span>
                            <span className={`mt-1 inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${statusStyles[appointment.status]}`}>
                              {statusLabels[appointment.status]}
                            </span>
                          </div>
                        </div>
                        <div className="mt-4 sm:flex sm:justify-between">
                          <div className="flex items-center text-sm text-gray-500">
                            <CalendarIcon className="flex-shrink-0 mr-1.5 h-5 w-5 text-gray-400" />
                            <p>{appointment.date}</p>
                          </div>
                          <div className="flex items-center mt-2 sm:mt-0 text-sm text-gray-500">
                            <ClockIcon className="flex-shrink-0 mr-1.5 h-5 w-5 text-gray-400" />
                            <p>{appointment.time}</p>
                          </div>
                          {appointment.location && (
                            <div className="flex items-center mt-2 sm:mt-0 text-sm text-gray-500">
                              <MapPinIcon className="flex-shrink-0 mr-1.5 h-5 w-5 text-gray-400" />
                              <p>{appointment.location}</p>
                            </div>
                          )}
                        </div>
                        {appointment.status === 'completed' && (
                          <div className="mt-4 flex justify-end">
                            <button
                              type="button"
                              className="inline-flex items-center px-3 py-1.5 border border-transparent text-xs font-medium rounded text-white bg-primary-600 hover:bg-primary-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500"
                            >
                              Laisser un avis
                            </button>
                          </div>
                        )}
                      </div>
                    </li>
                  ))}
                </ul>
              </div>
            </div>
          )}
        </div>
      </main>
    </div>
  );
}


