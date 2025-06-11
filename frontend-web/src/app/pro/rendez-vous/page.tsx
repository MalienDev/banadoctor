'use client';

import { Calendar, Clock, User, Video, Search, Bell, Plus } from 'lucide-react';

type Appointment = {
  id: number;
  patient: string;
  date: string;
  time: string;
  type: 'in-person' | 'teleconsultation';
  status: 'confirmé' | 'en attente' | 'annulé';
};

export default function RendezVousPage() {
  // Sample data - replace with actual data fetching
  const appointments: Appointment[] = [
    {
      id: 1,
      patient: 'Jean Dupont',
      date: '2023-06-15',
      time: '09:30',
      type: 'in-person',
      status: 'confirmé',
    },
    {
      id: 2,
      patient: 'Marie Martin',
      date: '2023-06-15',
      time: '11:00',
      type: 'teleconsultation',
      status: 'en attente',
    },
  ];

  return (
    <div className="p-6">
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-2xl font-bold">Rendez-vous</h1>
        <div className="flex items-center space-x-4">
          <div className="relative">
            <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-gray-400" />
            <input
              type="text"
              placeholder="Rechercher un patient..."
              className="pl-10 pr-4 py-2 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
          </div>
          <button className="p-2 rounded-full hover:bg-gray-100">
            <Bell className="h-6 w-6 text-gray-600" />
          </button>
        </div>
      </div>

      <div className="bg-white rounded-xl shadow p-6">
        <div className="flex justify-between items-center mb-6">
          <h2 className="text-xl font-semibold">Prochains rendez-vous</h2>
          <button className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition-colors flex items-center">
            <Plus className="h-4 w-4 mr-2" />
            Nouveau rendez-vous
          </button>
        </div>
        
        <div className="space-y-4">
          {appointments.map((appointment) => (
            <div key={appointment.id} className="border rounded-lg p-4 hover:shadow-md transition-shadow">
              <div className="flex justify-between items-start">
                <div>
                  <div className="flex items-center space-x-2">
                    <h3 className="font-medium">{appointment.patient}</h3>
                    <span className={`px-2 py-1 text-xs rounded-full ${
                      appointment.status === 'confirmé' ? 'bg-green-100 text-green-800' :
                      appointment.status === 'en attente' ? 'bg-yellow-100 text-yellow-800' :
                      'bg-red-100 text-red-800'
                    }`}>
                      {appointment.status}
                    </span>
                  </div>
                  <div className="flex items-center text-gray-500 text-sm mt-1">
                    <Calendar className="h-4 w-4 mr-1" />
                    {appointment.date} • {appointment.time}
                  </div>
                  <div className="flex items-center text-gray-500 text-sm mt-1">
                    {appointment.type === 'teleconsultation' ? (
                      <>
                        <Video className="h-4 w-4 mr-1" />
                        Téléconsultation
                      </>
                    ) : (
                      <>
                        <User className="h-4 w-4 mr-1" />
                        En cabinet
                      </>
                    )}
                  </div>
                </div>
                <div className="flex space-x-2">
                  <button className="p-2 text-gray-500 hover:text-blue-600 hover:bg-blue-50 rounded-full">
                    <Clock className="h-5 w-5" />
                  </button>
                  <button className="p-2 text-gray-500 hover:text-green-600 hover:bg-green-50 rounded-full">
                    <Calendar className="h-5 w-5" />
                  </button>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
