'use client';

import React, { useState } from 'react';
import { Appointment } from './types';
import { X } from 'lucide-react';

interface AppointmentModalProps {
  isOpen: boolean;
  onClose: () => void;
  onAddAppointment: (appointment: Omit<Appointment, 'id' | 'status'>) => void;
}

export default function AppointmentModal({ isOpen, onClose, onAddAppointment }: AppointmentModalProps) {
  const [patient, setPatient] = useState('');
  const [date, setDate] = useState('');
  const [time, setTime] = useState('');
  const [type, setType] = useState<'in-person' | 'teleconsultation'>('in-person');

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!patient || !date || !time) {
      return;
    }
    onAddAppointment({ patient, date, time, type });
    onClose();
    setPatient('');
    setDate('');
    setTime('');
    setType('in-person');
  };

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 z-50 flex justify-center items-center">
      <div className="bg-white rounded-lg p-8 shadow-2xl w-full max-w-md">
        <div className="flex justify-between items-center mb-6">
          <h2 className="text-xl font-bold">Nouveau rendez-vous</h2>
          <button onClick={onClose} className="p-2 rounded-full hover:bg-gray-200">
            <X className="h-6 w-6" />
          </button>
        </div>
        <form onSubmit={handleSubmit}>
          <div className="space-y-4">
            <div>
              <label htmlFor="patient" className="block text-sm font-medium text-gray-700">Nom du patient</label>
              <input
                type="text"
                id="patient"
                value={patient}
                onChange={(e) => setPatient(e.target.value)}
                className="mt-1 block w-full border border-gray-300 rounded-md shadow-sm py-2 px-3 focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                required
              />
            </div>
            <div className="grid grid-cols-2 gap-4">
                <div>
                    <label htmlFor="date" className="block text-sm font-medium text-gray-700">Date</label>
                    <input
                        type="date"
                        id="date"
                        value={date}
                        onChange={(e) => setDate(e.target.value)}
                        className="mt-1 block w-full border border-gray-300 rounded-md shadow-sm py-2 px-3 focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                        required
                    />
                </div>
                <div>
                    <label htmlFor="time" className="block text-sm font-medium text-gray-700">Heure</label>
                    <input
                        type="time"
                        id="time"
                        value={time}
                        onChange={(e) => setTime(e.target.value)}
                        className="mt-1 block w-full border border-gray-300 rounded-md shadow-sm py-2 px-3 focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                        required
                    />
                </div>
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700">Type de consultation</label>
              <div className="mt-2 space-y-2">
                <label className="inline-flex items-center">
                  <input type="radio" className="form-radio" name="type" value="in-person" checked={type === 'in-person'} onChange={() => setType('in-person')} />
                  <span className="ml-2">En cabinet</span>
                </label>
                <label className="inline-flex items-center ml-6">
                  <input type="radio" className="form-radio" name="type" value="teleconsultation" checked={type === 'teleconsultation'} onChange={() => setType('teleconsultation')} />
                  <span className="ml-2">Téléconsultation</span>
                </label>
              </div>
            </div>
          </div>
          <div className="mt-8 flex justify-end space-x-3">
            <button type="button" onClick={onClose} className="bg-gray-200 text-gray-800 px-4 py-2 rounded-lg hover:bg-gray-300">
              Annuler
            </button>
            <button type="submit" className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700">
              Ajouter le rendez-vous
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
