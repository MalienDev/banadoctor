'use client';

import Link from 'next/link';
import { useEffect, useState } from 'react';
import { useAuth } from '@/contexts/AuthContext';
import { api, DashboardStats, Appointment } from '@/lib/api';
import { format } from 'date-fns';
import { fr } from 'date-fns/locale';

// Helper function to format currency
const formatCurrency = (amount: number) => {
  return new Intl.NumberFormat('fr-FR', { style: 'currency', currency: 'EUR' }).format(amount);
};

export default function DoctorDashboard() {
  const { user, logout } = useAuth();
  const [data, setData] = useState<DashboardStats | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchDashboardData = async () => {
      if (!user || user.user_type !== 'doctor') {
        setLoading(false);
        return;
      }
      try {
        setLoading(true);
        const response = await api.get<DashboardStats>('/users/dashboard-stats/');
        setData(response.data);
      } catch (err) {
        console.error('Failed to fetch dashboard data:', err);
        setError('Impossible de charger les données du tableau de bord.');
      } finally {
        setLoading(false);
      }
    };

    fetchDashboardData();
  }, [user]);

  if (loading) {
    return <div className="flex justify-center items-center min-h-screen">Chargement...</div>;
  }

  if (error) {
    return <div className="flex justify-center items-center min-h-screen text-red-500">{error}</div>;
  }

  if (!data) {
    return <div className="flex justify-center items-center min-h-screen">Aucune donnée disponible.</div>;
  }

  const { stats, upcoming_appointments, recent_activity } = data;

  // Create a unique list of recent patients from recent_activity
  const recent_patients = recent_activity.reduce((acc: Appointment[], current: Appointment) => {
    if (!acc.find(item => item.patient_name === current.patient_name)) {
      acc.push(current);
    }
    return acc;
  }, []);

  return (
    <div className="min-h-screen bg-gray-100">
      <header className="bg-white shadow">
        <div className="max-w-7xl mx-auto py-6 px-4 sm:px-6 lg:px-8 flex justify-between items-center">
          <h1 className="text-3xl font-bold text-gray-900">Tableau de bord Médecin</h1>
          <div className="flex space-x-4">
            <Link href="/pro/appointments" className="text-gray-600 hover:text-gray-900">
              Mes consultations
            </Link>
            <Link href="/pro/patients" className="text-gray-600 hover:text-gray-900">
              Mes patients
            </Link>
            <button onClick={logout} className="text-gray-600 hover:text-gray-900">
              Déconnexion
            </button>
          </div>
        </div>
      </header>

      <main className="max-w-7xl mx-auto py-6 sm:px-6 lg:px-8">
        <div className="px-4 py-6 sm:px-0">
          <div className="grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-4">
            <div className="bg-white overflow-hidden shadow rounded-lg p-5">
                <dt className="text-sm font-medium text-gray-500 truncate">Rendez-vous aujourd'hui</dt>
                <dd className="mt-1 text-3xl font-semibold text-gray-900">{stats.appointments_today}</dd>
            </div>
            <div className="bg-white overflow-hidden shadow rounded-lg p-5">
                <dt className="text-sm font-medium text-gray-500 truncate">Total des patients</dt>
                <dd className="mt-1 text-3xl font-semibold text-gray-900">{stats.total_patients}</dd>
            </div>
            <div className="bg-white overflow-hidden shadow rounded-lg p-5">
                <dt className="text-sm font-medium text-gray-500 truncate">Rendez-vous en attente</dt>
                <dd className="mt-1 text-3xl font-semibold text-gray-900">{stats.pending_appointments}</dd>
            </div>
            <div className="bg-white overflow-hidden shadow rounded-lg p-5">
                <dt className="text-sm font-medium text-gray-500 truncate">Revenus totaux</dt>
                <dd className="mt-1 text-3xl font-semibold text-gray-900">{formatCurrency(stats.total_revenue)}</dd>
            </div>
          </div>

          <div className="mt-8">
            <h2 className="text-lg leading-6 font-medium text-gray-900">Prochains rendez-vous</h2>
            <div className="mt-4 overflow-hidden shadow ring-1 ring-black ring-opacity-5 md:rounded-lg">
              <table className="min-w-full divide-y divide-gray-300">
                <thead className="bg-gray-50">
                  <tr>
                    <th scope="col" className="py-3.5 pl-4 pr-3 text-left text-sm font-semibold text-gray-900 sm:pl-6">Patient</th>
                    <th scope="col" className="px-3 py-3.5 text-left text-sm font-semibold text-gray-900">Date</th>
                    <th scope="col" className="px-3 py-3.5 text-left text-sm font-semibold text-gray-900">Heure</th>
                    <th scope="col" className="px-3 py-3.5 text-left text-sm font-semibold text-gray-900">Statut</th>
                    <th scope="col" className="relative py-3.5 pl-3 pr-4 sm:pr-6"><span className="sr-only">Actions</span></th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-gray-200 bg-white">
                  {upcoming_appointments.length > 0 ? (
                    upcoming_appointments.map((appt: Appointment) => (
                      <tr key={appt.id}>
                        <td className="whitespace-nowrap py-4 pl-4 pr-3 text-sm font-medium text-gray-900 sm:pl-6">{appt.patient_name}</td>
                        <td className="whitespace-nowrap px-3 py-4 text-sm text-gray-500">{format(new Date(appt.scheduled_date), 'd MMMM yyyy', { locale: fr })}</td>
                        <td className="whitespace-nowrap px-3 py-4 text-sm text-gray-500">{appt.start_time.slice(0, 5)}</td>
                        <td className="whitespace-nowrap px-3 py-4 text-sm text-gray-500">
                          <span className={`px-2 inline-flex text-xs leading-5 font-semibold rounded-full ${appt.status === 'confirmed' ? 'bg-green-100 text-green-800' : 'bg-yellow-100 text-yellow-800'}`}>
                            {appt.status_display}
                          </span>
                        </td>
                        <td className="relative whitespace-nowrap py-4 pl-3 pr-4 text-right text-sm font-medium sm:pr-6">
                          <Link href={`/pro/appointments/${appt.id}`} className="text-primary-600 hover:text-primary-900">Voir</Link>
                        </td>
                      </tr>
                    ))
                  ) : (
                    <tr>
                      <td colSpan={5} className="text-center py-4">Aucun rendez-vous à venir.</td>
                    </tr>
                  )}
                </tbody>
              </table>
            </div>
          </div>

          <div className="mt-8">
            <h2 className="text-lg leading-6 font-medium text-gray-900">Derniers patients</h2>
            <div className="mt-4 overflow-hidden shadow ring-1 ring-black ring-opacity-5 md:rounded-lg">
              <table className="min-w-full divide-y divide-gray-300">
                <thead className="bg-gray-50">
                  <tr>
                    <th scope="col" className="py-3.5 pl-4 pr-3 text-left text-sm font-semibold text-gray-900 sm:pl-6">Patient</th>
                    <th scope="col" className="px-3 py-3.5 text-left text-sm font-semibold text-gray-900">Dernière visite</th>
                    <th scope="col" className="relative py-3.5 pl-3 pr-4 sm:pr-6"><span className="sr-only">Actions</span></th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-gray-200 bg-white">
                  {recent_patients.length > 0 ? (
                    recent_patients.map((appt: Appointment) => (
                      <tr key={`recent-${appt.id}`}>
                        <td className="whitespace-nowrap py-4 pl-4 pr-3 text-sm font-medium text-gray-900 sm:pl-6">
                          <div className="flex items-center">
                            <div className="h-10 w-10 flex-shrink-0">
                              <div className="h-10 w-10 rounded-full bg-gray-200 flex items-center justify-center text-gray-500">
                                {appt.patient_name.substring(0, 2).toUpperCase()}
                              </div>
                            </div>
                            <div className="ml-4">
                              <div className="font-medium text-gray-900">{appt.patient_name}</div>
                            </div>
                          </div>
                        </td>
                        <td className="whitespace-nowrap px-3 py-4 text-sm text-gray-500">{format(new Date(appt.scheduled_date), 'd MMMM yyyy', { locale: fr })}</td>
                        <td className="relative whitespace-nowrap py-4 pl-3 pr-4 text-right text-sm font-medium sm:pr-6">
                          <Link href={`/pro/appointments/${appt.id}`} className="text-primary-600 hover:text-primary-900">Voir</Link>
                        </td>
                      </tr>
                    ))
                  ) : (
                    <tr>
                      <td colSpan={3} className="text-center py-4">Aucun patient récent.</td>
                    </tr>
                  )}
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </main>
    </div>
  );
}
