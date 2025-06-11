'use client';

import { Video, User, Clock, Calendar, Search, Bell, VideoOff } from 'lucide-react';

type Consultation = {
  id: number;
  patient: string;
  date: string;
  time: string;
  status: 'en cours' | 'planifiée' | 'terminée' | 'annulée';
  duration: string;
};

export default function TeleconsultationPage() {
  // Sample data - replace with actual data fetching
  const consultations: Consultation[] = [
    {
      id: 1,
      patient: 'Jean Dupont',
      date: '2023-06-15',
      time: '14:30',
      status: 'planifiée',
      duration: '30 min',
    },
    {
      id: 2,
      patient: 'Marie Martin',
      date: '2023-06-16',
      time: '10:00',
      status: 'planifiée',
      duration: '45 min',
    },
  ];

  return (
    <div className="p-6">
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-2xl font-bold">Téléconsultations</h1>
        <div className="flex items-center space-x-4">
          <div className="relative">
            <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-gray-400" />
            <input
              type="text"
              placeholder="Rechercher une consultation..."
              className="pl-10 pr-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
          </div>
          <button className="p-2 rounded-full hover:bg-gray-100">
            <Bell className="h-6 w-6 text-gray-600" />
          </button>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div className="md:col-span-2">
          <div className="bg-white rounded-xl shadow p-6">
            <h2 className="text-xl font-semibold mb-6">Prochaines téléconsultations</h2>
            
            <div className="space-y-4">
              {consultations.map((consultation) => (
                <div key={consultation.id} className="border rounded-lg p-4 hover:shadow-md transition-shadow">
                  <div className="flex justify-between items-start">
                    <div>
                      <h3 className="font-medium">{consultation.patient}</h3>
                      <div className="flex items-center text-gray-500 text-sm mt-1">
                        <Calendar className="h-4 w-4 mr-1" />
                        {consultation.date} • {consultation.time}
                      </div>
                      <div className="flex items-center text-gray-500 text-sm mt-1">
                        <Clock className="h-4 w-4 mr-1" />
                        {consultation.duration}
                      </div>
                    </div>
                    <div className="flex space-x-2">
                      <button className="bg-blue-100 text-blue-700 px-3 py-1 rounded-full text-sm font-medium">
                        {consultation.status}
                      </button>
                      <button className="p-2 text-gray-500 hover:text-blue-600 hover:bg-blue-50 rounded-full">
                        <Video className="h-5 w-5" />
                      </button>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
        
        <div className="space-y-6">
          <div className="bg-white rounded-xl shadow p-6">
            <h2 className="text-lg font-semibold mb-4">Démarrer une consultation</h2>
            <button className="w-full bg-blue-600 text-white py-2 px-4 rounded-lg hover:bg-blue-700 transition-colors flex items-center justify-center">
              <Video className="h-5 w-5 mr-2" />
              Nouvelle téléconsultation
            </button>
          </div>
          
          <div className="bg-white rounded-xl shadow p-6">
            <h2 className="text-lg font-semibold mb-4">Configuration requise</h2>
            <div className="space-y-3">
              <div className="flex items-center">
                <div className="p-2 bg-green-100 rounded-full mr-3">
                  <Video className="h-5 w-5 text-green-600" />
                </div>
                <span className="text-sm">Caméra et micro fonctionnels</span>
              </div>
              <div className="flex items-center">
                <div className="p-2 bg-green-100 rounded-full mr-3">
                  <VideoOff className="h-5 w-5 text-green-600" />
                </div>
                <span className="text-sm">Connexion Internet stable</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
