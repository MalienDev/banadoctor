'use client';

import { Calendar, Clock, User, Video, MessageSquare, Settings, Bell, Search } from 'lucide-react';
import Link from 'next/link';

export default function AgendaPage() {
  return (
    <div className="p-6">
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-2xl font-bold">Agenda</h1>
        <div className="flex items-center space-x-4">
          <div className="relative">
            <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-gray-400" />
            <input
              type="text"
              placeholder="Rechercher..."
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
          <h2 className="text-xl font-semibold">Votre calendrier</h2>
          <button className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition-colors">
            + Nouvel événement
          </button>
        </div>
        
        {/* Calendar component will go here */}
        <div className="h-96 bg-gray-50 rounded-lg flex items-center justify-center text-gray-400">
          Calendrier à intégrer
        </div>
      </div>
    </div>
  );
}
