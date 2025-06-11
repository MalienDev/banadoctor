'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import { Calendar, Clock, MessageSquare, User, Video, Bell, Search } from 'lucide-react';

type Appointment = {
  id: number;
  patient: string;
  time: string;
  type: string;
  status: 'confirmé' | 'en attente' | 'annulé';
};

type StatCard = {
  title: string;
  value: string;
  icon: React.ReactNode;
  trend?: 'up' | 'down';
  change?: string;
};

export default function ProDashboard() {
  const router = useRouter();
  const [isLoading, setIsLoading] = useState(true);
  
  // Données factices pour la démonstration
  const [stats, setStats] = useState<StatCard[]>([
    { 
      title: 'Rendez-vous du jour', 
      value: '12', 
      icon: <Calendar className="w-6 h-6" />,
      trend: 'up',
      change: '12%'
    },
    { 
      title: 'En attente', 
      value: '3', 
      icon: <Clock className="w-6 h-6" />,
      trend: 'down',
      change: '5%'
    },
    { 
      title: 'Messages non lus', 
      value: '5', 
      icon: <MessageSquare className="w-6 h-6" />,
      trend: 'up',
      change: '2%'
    },
    { 
      title: 'Nouveaux patients', 
      value: '2', 
      icon: <User className="w-6 h-6" />,
      trend: 'up',
      change: '8%'
    },
  ]);

  const [upcomingAppointments, setUpcomingAppointments] = useState<Appointment[]>([
    { id: 1, patient: 'Jean Dupont', time: '09:30', type: 'Consultation', status: 'confirmé' },
    { id: 2, patient: 'Marie Martin', time: '10:15', type: 'Téléconsultation', status: 'confirmé' },
    { id: 3, patient: 'Pierre Durand', time: '11:00', type: 'Suivi', status: 'en attente' },
  ]);

  // Simuler le chargement des données
  useEffect(() => {
    const timer = setTimeout(() => {
      setIsLoading(false);
    }, 1000);
    
    return () => clearTimeout(timer);
  }, []);

  // Fonction pour démarrer une téléconsultation
  const startTeleconsultation = (appointmentId: number) => {
    // Ici, vous intégrerez la logique pour démarrer une téléconsultation
    alert(`Démarrage de la téléconsultation pour le rendez-vous #${appointmentId}`);
  };

  if (isLoading) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <div className="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-blue-500"></div>
      </div>
    );
  }

  return (
    <div className="main-container">
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-2xl font-bold">Tableau de bord</h1>
        <div className="flex items-center space-x-4">
          <div className="relative">
            <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
              <Search className="h-5 w-5 text-gray-400" />
            </div>
            <input
              type="text"
              placeholder="Rechercher..."
              className="pl-10 pr-4 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
            />
          </div>
          <button className="p-2 rounded-full bg-gray-100 text-gray-600 hover:bg-gray-200">
            <Bell className="h-5 w-5" />
            <span className="sr-only">Notifications</span>
            <span className="absolute top-0 right-0 h-2 w-2 rounded-full bg-red-500"></span>
          </button>
        </div>
      </div>
      
      {/* Cartes de statistiques */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
        {stats.map((stat, index) => (
          <div key={index} className="bg-white rounded-lg shadow p-6">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-gray-600 text-sm">{stat.title}</p>
                <p className="text-2xl font-bold mt-1">{stat.value}</p>
              </div>
              <div className={`p-3 rounded-full ${
                stat.trend === 'up' ? 'bg-green-100 text-green-600' : 'bg-red-100 text-red-600'
              }`}>
                {stat.icon}
              </div>
            </div>
            {stat.trend && (
              <div className={`mt-2 text-sm ${
                stat.trend === 'up' ? 'text-green-600' : 'text-red-600'
              }`}>
                <span>{stat.trend === 'up' ? '↑' : '↓'} {stat.change} par rapport à hier</span>
              </div>
            )}
          </div>
        ))}
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        {/* Prochains rendez-vous */}
        <div className="lg:col-span-2">
          <div className="bg-white rounded-lg shadow overflow-hidden">
            <div className="p-6 border-b flex justify-between items-center">
              <h2 className="text-lg font-semibold">Prochains rendez-vous</h2>
              <Link href="/pro/agenda" className="text-sm text-blue-600 hover:text-blue-500">
                Voir tout l'agenda →
              </Link>
            </div>
            <div className="overflow-x-auto">
              <table className="min-w-full divide-y divide-gray-200">
                <thead className="bg-gray-50">
                  <tr>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Heure</th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Patient</th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Type</th>
                    <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
                  </tr>
                </thead>
                <tbody className="bg-white divide-y divide-gray-200">
                  {upcomingAppointments.map((appointment) => (
                    <tr key={appointment.id} className="hover:bg-gray-50">
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="text-sm font-medium text-gray-900">{appointment.time}</div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="text-sm text-gray-900">{appointment.patient}</div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <span className={`px-2 inline-flex text-xs leading-5 font-semibold rounded-full ${
                          appointment.type === 'Téléconsultation' 
                            ? 'bg-purple-100 text-purple-800' 
                            : 'bg-blue-100 text-blue-800'
                        }`}>
                          {appointment.type}
                        </span>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                        {appointment.type === 'Téléconsultation' ? (
                          <button 
                            onClick={() => startTeleconsultation(appointment.id)}
                            className="text-indigo-600 hover:text-indigo-900 flex items-center"
                          >
                            <Video className="w-4 h-4 mr-1" /> Démarrer
                          </button>
                        ) : (
                          <Link 
                            href={`/pro/rendez-vous/${appointment.id}`} 
                            className="text-blue-600 hover:text-blue-900"
                          >
                            Voir détails
                          </Link>
                        )}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        </div>

        {/* Activité récente */}
        <div>
          <div className="bg-white rounded-lg shadow overflow-hidden">
            <div className="p-6 border-b">
              <h2 className="text-lg font-semibold">Activité récente</h2>
            </div>
            <div className="divide-y divide-gray-200">
              {[
                { id: 1, type: 'consultation', patient: 'Jean Dupont', time: 'il y a 2h', status: 'terminée' },
                { id: 2, type: 'téléconsultation', patient: 'Marie Martin', time: 'hier', status: 'annulée' },
                { id: 3, type: 'consultation', patient: 'Pierre Durand', time: 'hier', status: 'terminée' },
                { id: 4, type: 'message', patient: 'Sophie Bernard', time: 'il y a 2 jours', status: 'non lu' },
              ].map((activity) => (
                <div key={activity.id} className="p-4 hover:bg-gray-50">
                  <div className="flex items-start">
                    <div className={`flex-shrink-0 h-10 w-10 rounded-full flex items-center justify-center ${
                      activity.type === 'consultation' ? 'bg-blue-100 text-blue-600' :
                      activity.type === 'téléconsultation' ? 'bg-purple-100 text-purple-600' :
                      'bg-gray-100 text-gray-600'
                    }`}>
                      {activity.type === 'consultation' ? (
                        <User className="h-5 w-5" />
                      ) : activity.type === 'téléconsultation' ? (
                        <Video className="h-5 w-5" />
                      ) : (
                        <MessageSquare className="h-5 w-5" />
                      )}
                    </div>
                    <div className="ml-4 flex-1">
                      <div className="flex items-center justify-between">
                        <h3 className="text-sm font-medium text-gray-900">
                          {activity.patient}
                        </h3>
                        <span className="text-xs text-gray-500">{activity.time}</span>
                      </div>
                      <p className="text-sm text-gray-600">
                        {activity.type === 'message' 
                          ? 'Nouveau message reçu' 
                          : `${activity.type.charAt(0).toUpperCase() + activity.type.slice(1)} ${activity.status}`}
                      </p>
                      {activity.status === 'non lu' && (
                        <span className="inline-block mt-1 px-2 py-0.5 text-xs font-medium bg-blue-100 text-blue-800 rounded-full">
                          Nouveau
                        </span>
                      )}
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* Prochaine disponibilité */}
          <div className="mt-6 bg-white rounded-lg shadow overflow-hidden">
            <div className="p-6 border-b">
              <h2 className="text-lg font-semibold">Prochaine disponibilité</h2>
            </div>
            <div className="p-6">
              <div className="text-center">
                <p className="text-2xl font-bold text-gray-900">Demain à 08:00</p>
                <p className="mt-2 text-sm text-gray-600">Prochain créneau disponible</p>
                <button className="mt-4 w-full bg-blue-600 text-white py-2 px-4 rounded-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500">
                  Planifier un rendez-vous
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
