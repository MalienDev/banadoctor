'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import { Calendar, Clock, MessageSquare, User, Video, AlertCircle } from 'lucide-react';
import { useAuth } from '@/contexts/AuthContext';
import { getDashboardStats, DashboardStats, Appointment } from "@/lib/api";

// Helper to format time since a date
function timeAgo(dateString: string): string {
    const date = new Date(dateString);
    const now = new Date();
    const seconds = Math.floor((now.getTime() - date.getTime()) / 1000);
    
    let interval = seconds / 31536000; // 60 * 60 * 24 * 365
    if (interval > 1) return `il y a ${Math.floor(interval)} ans`;
    
    interval = seconds / 2592000; // 60 * 60 * 24 * 30
    if (interval > 1) return `il y a ${Math.floor(interval)} mois`;

    interval = seconds / 86400; // 60 * 60 * 24
    if (interval > 1) return `il y a ${Math.floor(interval)} jours`;

    interval = seconds / 3600; // 60 * 60
    if (interval > 1) return `il y a ${Math.floor(interval)} heures`;

    interval = seconds / 60;
    if (interval > 1) return `il y a ${Math.floor(interval)} minutes`;

    return `à l'instant`;
}

export default function ProDashboard() {
  const router = useRouter();
  const { user, loading: authLoading } = useAuth();
  
  const [dashboardData, setDashboardData] = useState<DashboardStats | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (!authLoading && (!user || user.user_type !== 'doctor')) {
      router.push('/login');
    }
  }, [user, authLoading, router]);

  useEffect(() => {
    if (user && user.user_type === 'doctor') {
      const fetchDashboardData = async () => {
        setIsLoading(true);
        setError(null);
        try {
          const data = await getDashboardStats();
          setDashboardData(data);
        } catch (error) {
          console.error('Failed to fetch dashboard data:', error);
          setError('Impossible de charger les données du tableau de bord. Veuillez réessayer plus tard.');
        } finally {
          setIsLoading(false);
        }
      };

      fetchDashboardData();
    }
  }, [user]);

  const startTeleconsultation = (appointmentId: number) => {
    alert(`Démarrage de la téléconsultation pour le rendez-vous #${appointmentId}`);
  };

  if (authLoading || isLoading) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <div className="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-blue-500"></div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="flex flex-col items-center justify-center min-h-screen text-center">
        <AlertCircle className="w-12 h-12 text-red-500 mb-4" />
        <h2 className="text-xl font-semibold text-red-600 mb-2">Erreur de chargement</h2>
        <p className="text-gray-600">{error}</p>
      </div>
    );
  }

  if (!user || !dashboardData) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <p>Aucune donnée à afficher.</p>
      </div>
    );
  }

  const { stats, upcoming_appointments, recent_activity } = dashboardData;

  if (!stats) {
    return (
        <div className="flex flex-col items-center justify-center min-h-screen text-center">
            <AlertCircle className="w-12 h-12 text-yellow-500 mb-4" />
            <h2 className="text-xl font-semibold text-yellow-600 mb-2">Données incomplètes</h2>
            <p className="text-gray-600">Certaines statistiques n'ont pas pu être chargées.</p>
        </div>
    );
  }

  const statCards = [
      { title: 'Rendez-vous du jour', value: stats.appointments_today ?? 0, icon: <Calendar className="w-6 h-6 text-blue-600" /> },
      { title: 'En attente', value: stats.pending_appointments ?? 0, icon: <Clock className="w-6 h-6 text-yellow-600" /> },
      { title: 'Messages non lus', value: stats.unread_messages ?? 0, icon: <MessageSquare className="w-6 h-6 text-green-600" /> },
      { title: 'Total patients', value: stats.total_patients ?? 0, icon: <User className="w-6 h-6 text-purple-600" /> },
  ];

  return (
    <div className="main-container">
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-2xl font-bold">Tableau de bord de Dr. {user.last_name}</h1>
        {/* Search and Bell icons can be made functional later */}
      </div>
      
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
        {statCards.map((stat, index) => (
          <div key={index} className="bg-white rounded-lg shadow p-6">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-gray-600 text-sm">{stat.title}</p>
                <p className="text-2xl font-bold mt-1">{stat.value}</p>
              </div>
              <div className="p-3 rounded-full bg-gray-100">{stat.icon}</div>
            </div>
          </div>
        ))}
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        <div className="lg:col-span-2">
          <div className="bg-white rounded-lg shadow overflow-hidden">
            <div className="p-6 border-b">
              <h2 className="text-lg font-semibold">Prochains rendez-vous</h2>
            </div>
            <div className="overflow-x-auto">
              <table className="min-w-full divide-y divide-gray-200">
                <thead className="bg-gray-50">
                  <tr>
                    <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Patient</th>
                    <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Heure</th>
                    <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Type</th>
                    <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Statut</th>
                    <th scope="col" className="relative px-6 py-3"><span className="sr-only">Actions</span></th>
                  </tr>
                </thead>
                <tbody className="bg-white divide-y divide-gray-200">
                  {upcoming_appointments.length > 0 ? upcoming_appointments.map((appointment: Appointment) => (
                    <tr key={appointment.id}>
                      <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">{appointment.patient_name}</td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{appointment.start_time.slice(0, 5)}</td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">{appointment.type_display}</td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <span className={`px-2 inline-flex text-xs leading-5 font-semibold rounded-full ${appointment.status === 'confirmed' ? 'bg-green-100 text-green-800' : 'bg-yellow-100 text-yellow-800'}`}>
                          {appointment.status_display}
                        </span>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                        {appointment.appointment_type === 'teleconsultation' ? (
                          <button onClick={() => startTeleconsultation(appointment.id)} className="text-indigo-600 hover:text-indigo-900 flex items-center">
                            <Video className="w-4 h-4 mr-1" /> Démarrer
                          </button>
                        ) : (
                          <Link href={`/pro/rendez-vous/${appointment.id}`} className="text-blue-600 hover:text-blue-900">Voir détails</Link>
                        )}
                      </td>
                    </tr>
                  )) : (<tr><td colSpan={5} className="text-center py-4">Aucun rendez-vous à venir.</td></tr>)}
                </tbody>
              </table>
            </div>
          </div>
        </div>

        <div>
          <div className="bg-white rounded-lg shadow overflow-hidden">
            <div className="p-6 border-b">
              <h2 className="text-lg font-semibold">Activité récente</h2>
            </div>
            <div className="divide-y divide-gray-200">
              {recent_activity.length > 0 ? recent_activity.map((activity: Appointment) => (
                <div key={activity.id} className="p-4 hover:bg-gray-50">
                  <div className="flex items-start">
                    <div className="ml-4 flex-1">
                      <div className="flex items-center justify-between">
                        <h3 className="text-sm font-medium text-gray-900">{activity.patient_name}</h3>
                        <span className="text-xs text-gray-500">{timeAgo(activity.updated_at)}</span>
                      </div>
                      <p className="text-sm text-gray-600">Rendez-vous {activity.status_display}</p>
                    </div>
                  </div>
                </div>
              )) : (<div className="p-4 text-center">Aucune activité récente.</div>)}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
