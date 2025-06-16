'use client';

import { useState } from 'react';
import { Calendar, User, Video, Search, Bell, Plus, CheckCircle, XCircle, Edit } from 'lucide-react';
import AppointmentModal from './AppointmentModal';
import { Appointment } from './types';

const initialAppointments: Appointment[] = [
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
  {
    id: 3,
    patient: 'Pierre Durand',
    date: '2023-06-16',
    time: '14:00',
    type: 'in-person',
    status: 'annulé',
  },
];

export default function RendezVousPage() {
  const [appointments, setAppointments] = useState<Appointment[]>(initialAppointments);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [searchTerm, setSearchTerm] = useState('');

  const handleAddAppointment = (newAppointment: Omit<Appointment, 'id' | 'status'>) => {
    setAppointments(prev => [
      ...prev,
      {
        ...newAppointment,
        id: prev.length > 0 ? Math.max(...prev.map(a => a.id)) + 1 : 1,
        status: 'en attente',
      },
    ]);
  };

  const updateAppointmentStatus = (id: number, status: 'confirmé' | 'annulé') => {
    setAppointments(prev =>
      prev.map(app => (app.id === id ? { ...app, status } : app))
    );
  };
  
  const filteredAppointments = appointments.filter(appointment => 
    appointment.patient.toLowerCase().includes(searchTerm.toLowerCase())
  );

  return (
    <>
      <AppointmentModal
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        onAddAppointment={handleAddAppointment}
      />
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
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
              />
            </div>
            <button className="p-2 rounded-full hover:bg-gray-100">
              <Bell className="h-6 w-6 text-gray-600" />
            </button>
          </div>
        </div>

        <div className="bg-white rounded-xl shadow p-6">
          <div className="flex justify-between items-center mb-6">
            <h2 className="text-xl font-semibold">Liste des rendez-vous</h2>
            <button 
              onClick={() => setIsModalOpen(true)}
              className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition-colors flex items-center"
            >
              <Plus className="h-4 w-4 mr-2" />
              Nouveau rendez-vous
            </button>
          </div>
          
          <div className="space-y-4">
            {filteredAppointments.length > 0 ? filteredAppointments.map((appointment) => (
              <div key={appointment.id} className="border rounded-lg p-4 hover:shadow-md transition-shadow bg-white">
                <div className="flex justify-between items-start">
                  <div>
                    <div className="flex items-center space-x-3">
                      <h3 className="font-semibold text-lg text-gray-800">{appointment.patient}</h3>
                      <span className={`px-2 py-1 text-xs font-medium rounded-full ${
                        appointment.status === 'confirmé' ? 'bg-green-100 text-green-800' :
                        appointment.status === 'en attente' ? 'bg-yellow-100 text-yellow-800' :
                        'bg-red-100 text-red-800'
                      }`}>
                        {appointment.status}
                      </span>
                    </div>
                    <div className="flex items-center text-gray-600 text-sm mt-2">
                      <Calendar className="h-4 w-4 mr-2" />
                      {appointment.date} • {appointment.time}
                    </div>
                    <div className="flex items-center text-gray-600 text-sm mt-1">
                      {appointment.type === 'teleconsultation' ? (
                        <>
                          <Video className="h-4 w-4 mr-2" />
                          Téléconsultation
                        </>
                      ) : (
                        <>
                          <User className="h-4 w-4 mr-2" />
                          En cabinet
                        </>
                      )}
                    </div>
                  </div>
                  <div className="flex items-center space-x-2">
                    {appointment.status === 'en attente' && (
                      <button 
                        onClick={() => updateAppointmentStatus(appointment.id, 'confirmé')}
                        className="p-2 text-gray-500 hover:text-green-600 hover:bg-green-50 rounded-full"
                        title="Confirmer"
                      >
                        <CheckCircle className="h-5 w-5" />
                      </button>
                    )}
                     {appointment.status !== 'annulé' && (
                        <button 
                          onClick={() => updateAppointmentStatus(appointment.id, 'annulé')}
                          className="p-2 text-gray-500 hover:text-red-600 hover:bg-red-50 rounded-full"
                          title="Annuler"
                        >
                          <XCircle className="h-5 w-5" />
                        </button>
                     )}
                    <button className="p-2 text-gray-500 hover:text-blue-600 hover:bg-blue-50 rounded-full" title="Reporter">
                      <Edit className="h-5 w-5" />
                    </button>
                  </div>
                </div>
              </div>
            )) : (
              <div className="text-center py-10 text-gray-500">
                <p>Aucun rendez-vous trouvé.</p>
              </div>
            )}
          </div>
        </div>
      </div>
    </>
  );
}
