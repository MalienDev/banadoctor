import Link from 'next/link';
import { Calendar, Clock, MessageSquare, User, Video } from 'lucide-react';

export default function ProDashboard() {
  // Données factices pour la démonstration
  const stats = [
    { title: 'Rendez-vous du jour', value: '12', icon: <Calendar className="w-6 h-6" /> },
    { title: 'En attente', value: '3', icon: <Clock className="w-6 h-6" /> },
    { title: 'Messages non lus', value: '5', icon: <MessageSquare className="w-6 h-6" /> },
    { title: 'Nouveaux patients', value: '2', icon: <User className="w-6 h-6" /> },
  ];

  const upcomingAppointments = [
    { id: 1, patient: 'Jean Dupont', time: '09:30', type: 'Consultation', status: 'confirmé' },
    { id: 2, patient: 'Marie Martin', time: '10:15', type: 'Téléconsultation', status: 'confirmé' },
    { id: 3, patient: 'Pierre Durand', time: '11:00', type: 'Suivi', status: 'en attente' },
  ];

  return (
    <div className="main-container">
      <h1 className="text-2xl font-bold mb-6">Tableau de bord</h1>
      
      {/* Cartes de statistiques */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
        {stats.map((stat, index) => (
          <div key={index} className="bg-white rounded-lg shadow p-6 flex items-center">
            <div className="p-3 rounded-full bg-blue-100 text-blue-600 mr-4">
              {stat.icon}
            </div>
            <div>
              <p className="text-gray-600 text-sm">{stat.title}</p>
              <p className="text-2xl font-bold">{stat.value}</p>
            </div>
          </div>
        ))}
      </div>

      {/* Prochains rendez-vous */}
      <div className="bg-white rounded-lg shadow overflow-hidden mb-8">
        <div className="p-6 border-b">
          <h2 className="text-lg font-semibold">Prochains rendez-vous</h2>
        </div>
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Heure</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Patient</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Type</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Statut</th>
                <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {upcomingAppointments.map((appointment) => (
                <tr key={appointment.id}>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm font-medium text-gray-900">{appointment.time}</div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm text-gray-900">{appointment.patient}</div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-blue-100 text-blue-800">
                      {appointment.type}
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className={`px-2 inline-flex text-xs leading-5 font-semibold rounded-full ${
                      appointment.status === 'confirmé' ? 'bg-green-100 text-green-800' : 'bg-yellow-100 text-yellow-800'
                    }`}>
                      {appointment.status}
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                    <Link href={`/pro/rendez-vous/${appointment.id}`} className="text-blue-600 hover:text-blue-900 mr-4">
                      Voir
                    </Link>
                    {appointment.type === 'Téléconsultation' && (
                      <button className="text-indigo-600 hover:text-indigo-900">
                        <Video className="w-5 h-5 inline mr-1" />
                        Démarrer
                      </button>
                    )}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
        <div className="px-6 py-4 bg-gray-50 text-right">
          <Link href="/pro/agenda" className="text-sm font-medium text-blue-600 hover:text-blue-500">
            Voir tout l'agenda →
          </Link>
        </div>
      </div>

      {/* Messages récents */}
      <div className="bg-white rounded-lg shadow overflow-hidden">
        <div className="p-6 border-b flex justify-between items-center">
          <h2 className="text-lg font-semibold">Messages récents</h2>
          <Link href="/pro/messagerie" className="text-sm text-blue-600 hover:text-blue-500">
            Voir tout
          </Link>
        </div>
        <div className="divide-y divide-gray-200">
          {[1, 2].map((msg) => (
            <div key={msg} className="p-4 hover:bg-gray-50">
              <div className="flex items-center">
                <div className="flex-shrink-0 h-10 w-10 rounded-full bg-gray-200 flex items-center justify-center">
                  <User className="h-5 w-5 text-gray-500" />
                </div>
                <div className="ml-4 flex-1">
                  <div className="flex items-center justify-between">
                    <h3 className="text-sm font-medium text-gray-900">
                      {msg === 1 ? 'Service client' : 'Nouveau patient'}
                    </h3>
                    <span className="text-xs text-gray-500">{msg === 1 ? 'Il y a 2h' : 'Hier'}</span>
                  </div>
                  <p className="text-sm text-gray-500 truncate">
                    {msg === 1 
                      ? 'Votre demande a été traitée avec succès.'
                      : 'Nouveau message concernant votre rendez-vous de demain.'}
                  </p>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
