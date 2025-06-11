'use client';

import { useState } from 'react';
import { User, Calendar, Bell, Lock, CreditCard, HelpCircle, LogOut, Plus } from 'lucide-react';

type SettingSection = {
  id: string;
  title: string;
  icon: React.ReactNode;
  description: string;
};

type NotificationPreference = {
  id: string;
  label: string;
  description: string;
  enabled: boolean;
};

export default function ParametresPage() {
  const [activeSection, setActiveSection] = useState('compte');
  const [notifications, setNotifications] = useState<NotificationPreference[]>([
    {
      id: 'email',
      label: 'E-mail',
      description: 'Recevoir des notifications par e-mail',
      enabled: true,
    },
    {
      id: 'push',
      label: 'Notifications push',
      description: 'Recevoir des notifications sur cet appareil',
      enabled: true,
    },
    {
      id: 'rdv',
      label: 'Rappels de rendez-vous',
      description: 'Recevoir des rappels avant les rendez-vous',
      enabled: true,
    },
  ]);

  const settingSections: SettingSection[] = [
    {
      id: 'compte',
      title: 'Compte',
      icon: <User className="h-5 w-5" />,
      description: 'Gérez vos informations personnelles et vos préférences de compte',
    },
    {
      id: 'notifications',
      title: 'Notifications',
      icon: <Bell className="h-5 w-5" />,
      description: 'Contrôlez comment et quand vous recevez les notifications',
    },
    {
      id: 'disponibilites',
      title: 'Disponibilités',
      icon: <Calendar className="h-5 w-5" />,
      description: 'Définissez vos horaires de consultation et vos disponibilités',
    },
    {
      id: 'securite',
      title: 'Sécurité',
      icon: <Lock className="h-5 w-5" />,
      description: 'Gérez la sécurité de votre compte et vos connexions',
    },
    {
      id: 'paiement',
      title: 'Paiement',
      icon: <CreditCard className="h-5 w-5" />,
      description: 'Méthodes de paiement et facturation',
    },
  ];

  const toggleNotification = (id: string) => {
    setNotifications(
      notifications.map((notif) =>
        notif.id === id ? { ...notif, enabled: !notif.enabled } : notif
      )
    );
  };

  const renderSectionContent = () => {
    switch (activeSection) {
      case 'compte':
        return (
          <div className="space-y-6">
            <div className="bg-white rounded-xl shadow p-6">
              <h3 className="text-lg font-medium mb-4">Informations personnelles</h3>
              <div className="space-y-4">
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">Prénom</label>
                    <input
                      type="text"
                      defaultValue="Jean"
                      className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-blue-500 focus:border-blue-500"
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-medium text-gray-700 mb-1">Nom</label>
                    <input
                      type="text"
                      defaultValue="Dupont"
                      className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-blue-500 focus:border-blue-500"
                    />
                  </div>
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Adresse e-mail</label>
                  <input
                    type="email"
                    defaultValue="jean.dupont@example.com"
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-blue-500 focus:border-blue-500"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Téléphone</label>
                  <input
                    type="tel"
                    defaultValue="+33 6 12 34 56 78"
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-blue-500 focus:border-blue-500"
                  />
                </div>
              </div>
              <div className="mt-6 flex justify-end">
                <button className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition-colors">
                  Enregistrer les modifications
                </button>
              </div>
            </div>

            <div className="bg-white rounded-xl shadow p-6">
              <h3 className="text-lg font-medium mb-4">Informations professionnelles</h3>
              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Spécialité</label>
                  <select className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-blue-500 focus:border-blue-500">
                    <option>Médecin généraliste</option>
                    <option>Dentiste</option>
                    <option>Kinésithérapeute</option>
                    <option>Autre</option>
                  </select>
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Numéro RPPS</label>
                  <input
                    type="text"
                    placeholder="Votre numéro RPPS"
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-blue-500 focus:border-blue-500"
                  />
                </div>
              </div>
            </div>
          </div>
        );

      case 'notifications':
        return (
          <div className="bg-white rounded-xl shadow p-6">
            <h3 className="text-lg font-medium mb-6">Préférences de notification</h3>
            <div className="space-y-4">
              {notifications.map((notif) => (
                <div key={notif.id} className="flex items-center justify-between p-4 border rounded-lg">
                  <div>
                    <h4 className="font-medium">{notif.label}</h4>
                    <p className="text-sm text-gray-500">{notif.description}</p>
                  </div>
                  <button
                    onClick={() => toggleNotification(notif.id)}
                    className={`relative inline-flex h-6 w-11 items-center rounded-full transition-colors focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 ${
                      notif.enabled ? 'bg-blue-600' : 'bg-gray-200'
                    }`}
                  >
                    <span
                      className={`inline-block h-4 w-4 transform rounded-full bg-white transition-transform ${
                        notif.enabled ? 'translate-x-6' : 'translate-x-1'
                      }`}
                    />
                  </button>
                </div>
              ))}
            </div>
          </div>
        );

      case 'disponibilites':
        return (
          <div className="bg-white rounded-xl shadow p-6">
            <h3 className="text-lg font-medium mb-6">Gestion des disponibilités</h3>
            <div className="space-y-4">
              <p className="text-gray-500">
                Configurez vos horaires de consultation et vos périodes de disponibilité.
              </p>
              <div className="p-4 border border-dashed border-gray-300 rounded-lg text-center">
                <Calendar className="h-12 w-12 text-gray-300 mx-auto mb-2" />
                <p className="text-gray-500">Interface de gestion des disponibilités à venir</p>
              </div>
            </div>
          </div>
        );

      case 'securite':
        return (
          <div className="space-y-6">
            <div className="bg-white rounded-xl shadow p-6">
              <h3 className="text-lg font-medium mb-4">Changer de mot de passe</h3>
              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Mot de passe actuel</label>
                  <input
                    type="password"
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-blue-500 focus:border-blue-500"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Nouveau mot de passe</label>
                  <input
                    type="password"
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-blue-500 focus:border-blue-500"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Confirmer le nouveau mot de passe</label>
                  <input
                    type="password"
                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-blue-500 focus:border-blue-500"
                  />
                </div>
                <div className="pt-2">
                  <button className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition-colors">
                    Mettre à jour le mot de passe
                  </button>
                </div>
              </div>
            </div>

            <div className="bg-white rounded-xl shadow p-6">
              <h3 className="text-lg font-medium mb-4">Sécurité du compte</h3>
              <div className="space-y-4">
                <div className="flex items-center justify-between p-4 border rounded-lg">
                  <div>
                    <h4 className="font-medium">Authentification à deux facteurs</h4>
                    <p className="text-sm text-gray-500">Ajoutez une couche de sécurité supplémentaire à votre compte</p>
                  </div>
                  <button className="text-blue-600 hover:text-blue-800 font-medium">
                    Activer
                  </button>
                </div>
                <div className="flex items-center justify-between p-4 border rounded-lg">
                  <div>
                    <h4 className="font-medium">Sessions actives</h4>
                    <p className="text-sm text-gray-500">Gérez les appareils connectés à votre compte</p>
                  </div>
                  <button className="text-blue-600 hover:text-blue-800 font-medium">
                    Voir
                  </button>
                </div>
              </div>
            </div>
          </div>
        );

      case 'paiement':
        return (
          <div className="bg-white rounded-xl shadow p-6">
            <h3 className="text-lg font-medium mb-6">Méthodes de paiement</h3>
            <div className="space-y-4">
              <div className="p-4 border rounded-lg">
                <div className="flex items-center justify-between">
                  <div className="flex items-center">
                    <div className="h-10 w-16 bg-blue-50 rounded-lg flex items-center justify-center mr-4">
                      <CreditCard className="h-6 w-6 text-blue-600" />
                    </div>
                    <div>
                      <h4 className="font-medium">Carte Visa •••• 4242</h4>
                      <p className="text-sm text-gray-500">Expire le 04/25</p>
                    </div>
                  </div>
                  <button className="text-red-600 hover:text-red-800 text-sm font-medium">
                    Supprimer
                  </button>
                </div>
              </div>
              <button className="mt-4 text-blue-600 hover:text-blue-800 font-medium flex items-center">
                <Plus className="h-4 w-4 mr-1" />
                Ajouter une méthode de paiement
              </button>
            </div>

            <div className="mt-8 pt-6 border-t border-gray-200">
              <h3 className="text-lg font-medium mb-4">Historique des paiements</h3>
              <div className="bg-gray-50 rounded-lg p-4 text-center">
                <p className="text-gray-500">Aucun historique de paiement pour le moment</p>
              </div>
            </div>
          </div>
        );

      default:
        return null;
    }
  };

  return (
    <div className="p-6">
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-2xl font-bold">Paramètres</h1>
      </div>

      <div className="flex flex-col md:flex-row gap-6">
        {/* Sidebar */}
        <div className="w-full md:w-64 flex-shrink-0">
          <div className="bg-white rounded-xl shadow overflow-hidden">
            <div className="p-4 border-b">
              <div className="flex items-center">
                <div className="h-10 w-10 rounded-full bg-blue-100 text-blue-600 flex items-center justify-center font-medium mr-3">
                  JD
                </div>
                <div>
                  <h3 className="font-medium">Dr. Jean Dupont</h3>
                  <p className="text-xs text-gray-500">Médecin généraliste</p>
                </div>
              </div>
            </div>
            <nav className="p-2">
              <ul className="space-y-1">
                {settingSections.map((section) => (
                  <li key={section.id}>
                    <button
                      onClick={() => setActiveSection(section.id)}
                      className={`w-full text-left px-4 py-3 rounded-lg flex items-center ${
                        activeSection === section.id
                          ? 'bg-blue-50 text-blue-700 font-medium'
                          : 'text-gray-700 hover:bg-gray-50'
                      }`}
                    >
                      <span className="mr-3">{section.icon}</span>
                      {section.title}
                    </button>
                  </li>
                ))}
                <li className="border-t border-gray-100 mt-2 pt-2">
                  <button className="w-full text-left px-4 py-3 rounded-lg flex items-center text-red-600 hover:bg-red-50">
                    <LogOut className="h-5 w-5 mr-3" />
                    Déconnexion
                  </button>
                </li>
              </ul>
            </nav>
          </div>

          <div className="mt-6 bg-white rounded-xl shadow p-4">
            <div className="flex items-center">
              <HelpCircle className="h-5 w-5 text-gray-400 mr-2" />
              <div>
                <h3 className="font-medium">Aide et support</h3>
                <p className="text-sm text-gray-500">Nous sommes là pour vous aider</p>
              </div>
            </div>
            <button className="mt-3 w-full text-center text-blue-600 hover:text-blue-800 text-sm font-medium">
              Contacter le support
            </button>
          </div>
        </div>

        {/* Main content */}
        <div className="flex-1">
          <div className="mb-6">
            <h2 className="text-xl font-semibold">
              {settingSections.find((s) => s.id === activeSection)?.title}
            </h2>
            <p className="text-gray-500">
              {settingSections.find((s) => s.id === activeSection)?.description}
            </p>
          </div>
          {renderSectionContent()}
        </div>
      </div>
    </div>
  );
}
