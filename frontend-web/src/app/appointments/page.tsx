'use client';

import { useEffect, useState } from 'react';
import { CalendarIcon, ClockIcon, MapPinIcon, PencilIcon, PlusIcon, TrashIcon } from '@heroicons/react/24/solid';
import Link from 'next/link';
import { useAuth } from '@/contexts/AuthContext';

import { Appointment } from '@/types/appointment';

const statusStyles = {
  scheduled: 'bg-green-100 text-green-800',
  completed: 'bg-blue-100 text-blue-800',
  cancelled: 'bg-red-100 text-red-800',
  no_show: 'bg-yellow-100 text-yellow-800',
};

const statusLabels = {
  scheduled: 'Confirmé',
  completed: 'Terminé',
  cancelled: 'Annulé',
  no_show: 'Non présent',
};

const AppointmentCard = ({ appointment }: { appointment: Appointment }) => {
  return (
    <li className="bg-white shadow-lg rounded-xl overflow-hidden transform hover:scale-105 transition-transform duration-300 ease-in-out p-6">
      <div className="flex items-center justify-between">
        <div className="flex items-center">
          <div className="ml-4">
            <h3 className="text-lg font-semibold text-gray-800">{appointment.doctor_name}</h3>
            <p className="text-sm text-gray-500">{appointment.type_display}</p>
          </div>
        </div>
        <div className={`flex items-center px-3 py-1 rounded-full ${statusStyles[appointment.status]}`}>
          <span className={`ml-2 text-sm font-medium`}>{appointment.status_display}</span>
        </div>
      </div>

      <div className="mt-6 border-t border-gray-200 pt-4">
        <div className="grid grid-cols-2 gap-4 text-sm text-gray-600">
          <div className="flex items-center">
            <CalendarIcon className="h-5 w-5 text-gray-400 mr-2" />
            <span>{new Date(appointment.scheduled_date).toLocaleDateString('fr-FR', { day: 'numeric', month: 'long', year: 'numeric' })}</span>
          </div>
          <div className="flex items-center">
            <ClockIcon className="h-5 w-5 text-gray-400 mr-2" />
            <span>{appointment.start_time.slice(0, 5)}</span>
          </div>
          {appointment.location && (
            <div className="flex items-center">
              <MapPinIcon className="h-5 w-5 text-gray-400 mr-2" />
              <span>{appointment.location}</span>
            </div>
          )}
        </div>
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
    </li>
  );
};

export default function AppointmentsPage() {
  const [appointments, setAppointments] = useState<Appointment[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [activeTab, setActiveTab] = useState<'upcoming' | 'past'>('upcoming');
  const { user } = useAuth();

  // Charger les données de test
  useEffect(() => {
    const loadTestData = async () => {
      try {
        // En mode développement, utilisez les données de test
        if (process.env.NODE_ENV === 'development') {
          const { testAppointments } = await import('@/lib/testData');
          setAppointments(testAppointments);
          setLoading(false);
          return;
        }

        // En production, chargez les données depuis l'API
        // const response = await api.get<Appointment[]>('/api/v1/appointments/');
        // setAppointments(response.data || []);
        // setLoading(false);
      } catch (err) {
        setError('Erreur lors du chargement des rendez-vous');
        console.error('Error loading appointments:', err);
      } finally {
        setLoading(false);
      }
    };

    loadTestData();
  }, []);
  
  // Filtrer les rendez-vous à venir et passés
  const now = new Date();
  const upcomingAppointments = appointments.filter(a => {
    const appointmentDate = new Date(`${a.scheduled_date}T${a.start_time}`);
    return appointmentDate >= now && a.status === 'scheduled';
  });
  
  const pastAppointments = appointments.filter(a => {
    const appointmentDate = new Date(`${a.scheduled_date}T${a.start_time}`);
    return appointmentDate < now || a.status !== 'scheduled';
  });
  
  const displayedAppointments = activeTab === 'upcoming' ? upcomingAppointments : pastAppointments;

  if (loading) {
    return (
      <div className="flex justify-center items-center h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-blue-500"></div>
        <span className="ml-4">Chargement des rendez-vous...</span>
      </div>
    );
  }

  if (error) {
    return (
      <div className="bg-red-50 border-l-4 border-red-500 p-4">
        <div className="flex">
          <div className="flex-shrink-0">
            <svg className="h-5 w-5 text-red-500" viewBox="0 0 20 20" fill="currentColor">
              <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clipRule="evenodd" />
            </svg>
          </div>
          <div className="ml-3">
            <p className="text-sm text-red-700">{error}</p>
          </div>
        </div>
      </div>
    );
  }

  if (appointments.length === 0) {
    return (
      <div className="text-center py-12">
        <svg className="mx-auto h-12 w-12 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1} d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
        </svg>
        <h3 className="mt-2 text-sm font-medium text-gray-900">Aucun rendez-vous</h3>
        <p className="mt-1 text-sm text-gray-500">Vous n'avez pas encore de rendez-vous de prévu.</p>
        <div className="mt-6">
          <Link href="/appointments/new" className="inline-flex items-center px-4 py-2 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500">
            <PlusIcon className="-ml-1 mr-2 h-5 w-5" aria-hidden="true" />
            Nouveau rendez-vous
          </Link>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <header className="bg-white shadow-sm">
        <div className="max-w-7xl mx-auto py-6 px-4 sm:px-6 lg:px-8">
          <h1 className="text-3xl font-bold leading-tight text-gray-900">Mes Rendez-vous</h1>
        </div>
      </header>

      <main className="max-w-7xl mx-auto py-6 sm:px-6 lg:px-8">
        <div className="px-4 sm:px-0">
          <div className="sm:hidden">
            <label htmlFor="tabs" className="sr-only">
              Select a tab
            </label>
            <select
              id="tabs"
              name="tabs"
              className="block w-full focus:ring-primary-500 focus:border-primary-500 border-gray-300 rounded-md"
              value={activeTab}
              onChange={(e) => setActiveTab(e.target.value as 'upcoming' | 'past')}
            >
              <option value="upcoming">À venir</option>
              <option value="past">Passés</option>
            </select>
          </div>
          <div className="hidden sm:block">
            <div className="border-b border-gray-200">
              <nav className="-mb-px flex space-x-8" aria-label="Tabs">
                <button
                  onClick={() => setActiveTab('upcoming')}
                  className={`${activeTab === 'upcoming' ? 'border-primary-500 text-primary-600' : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'} whitespace-nowrap py-4 px-1 border-b-2 font-medium text-sm`}
                >
                  À venir
                </button>
                <button
                  onClick={() => setActiveTab('past')}
                  className={`${activeTab === 'past' ? 'border-primary-500 text-primary-600' : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'} whitespace-nowrap py-4 px-1 border-b-2 font-medium text-sm`}
                >
                  Passés
                </button>
              </nav>
            </div>
          </div>
        </div>

        <div className="mt-8">
          {displayedAppointments.length > 0 ? (
            <ul className="space-y-4">
              {displayedAppointments.map((appointment) => (
                <AppointmentCard key={appointment.id} appointment={appointment} />
              ))}
            </ul>
          ) : (
            <div className="text-center bg-white py-12 rounded-lg shadow">
              <svg className="mx-auto h-12 w-12 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1} d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
              </svg>
              <h3 className="mt-2 text-sm font-medium text-gray-900">
                {activeTab === 'upcoming' ? 'Aucun rendez-vous à venir' : 'Aucun rendez-vous passé'}
              </h3>
              <p className="mt-1 text-sm text-gray-500">
                {activeTab === 'upcoming' 
                  ? 'Prenez votre premier rendez-vous avec un de nos médecins.'
                  : 'Votre historique de rendez-vous est vide.'}
              </p>
              {activeTab === 'upcoming' && (
                <div className="mt-6">
                  <Link 
                    href="/doctors" 
                    className="inline-flex items-center px-4 py-2 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
                  >
                    <PlusIcon className="-ml-1 mr-2 h-5 w-5" />
                    Prendre rendez-vous
                  </Link>
                </div>
              )}
            </div>
          )}
        </div>
      </main>
    </div>
  );
}
