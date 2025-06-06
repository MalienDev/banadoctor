import { MagnifyingGlassIcon, FunnelIcon, MapPinIcon, StarIcon } from '@heroicons/react/24/solid';
import Link from 'next/link';

type Doctor = {
  id: number;
  name: string;
  specialty: string;
  address: string;
  rating: number;
  reviews: number;
  image: string;
  price: number;
  languages: string[];
  availability: string[];
};

const doctors: Doctor[] = [
  {
    id: 1,
    name: 'Dr. Marie Dupont',
    specialty: 'Cardiologue',
    address: '123 Rue de Paris, 75001 Paris',
    rating: 4.8,
    reviews: 124,
    image: '/doctors/doctor1.jpg',
    price: 60,
    languages: ['Français', 'Anglais'],
    availability: ['Lun', 'Mar', 'Jeu'],
  },
  {
    id: 2,
    name: 'Dr. Jean Martin',
    specialty: 'Dermatologue',
    address: '456 Avenue des Champs-Élysées, 75008 Paris',
    rating: 4.6,
    reviews: 89,
    image: '/doctors/doctor2.jpg',
    price: 55,
    languages: ['Français', 'Espagnol'],
    availability: ['Mar', 'Mer', 'Ven'],
  },
  {
    id: 3,
    name: 'Dr. Sophie Dubois',
    specialty: 'Pédiatre',
    address: '789 Boulevard Saint-Germain, 75006 Paris',
    rating: 4.9,
    reviews: 156,
    image: '/doctors/doctor3.jpg',
    price: 50,
    languages: ['Français', 'Arabe'],
    availability: ['Lun', 'Mer', 'Ven'],
  },
  {
    id: 4,
    name: 'Dr. Thomas Leroy',
    specialty: 'Ophtalmologue',
    address: '321 Rue de Rivoli, 75004 Paris',
    rating: 4.5,
    reviews: 67,
    image: '/doctors/doctor4.jpg',
    price: 65,
    languages: ['Français', 'Anglais', 'Chinois'],
    availability: ['Mar', 'Jeu', 'Sam'],
  },
];

export default function DoctorsPage() {
  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white shadow">
        <div className="max-w-7xl mx-auto py-6 px-4 sm:px-6 lg:px-8">
          <h1 className="text-3xl font-bold text-gray-900">Trouver un médecin</h1>
        </div>
      </header>

      {/* Search and Filter */}
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
        <div className="bg-white p-6 rounded-lg shadow">
          <div className="flex flex-col md:flex-row md:items-center md:justify-between space-y-4 md:space-y-0 md:space-x-4">
            <div className="flex-1">
              <div className="relative rounded-md shadow-sm">
                <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                  <MagnifyingGlassIcon className="h-5 w-5 text-gray-400" aria-hidden="true" />
                </div>
                <input
                  type="text"
                  className="focus:ring-primary-500 focus:border-primary-500 block w-full pl-10 sm:text-sm border-gray-300 rounded-md h-10"
                  placeholder="Spécialité, symptôme, médecin..."
                />
              </div>
            </div>
            <div className="flex-shrink-0">
              <div className="relative">
                <select
                  id="location"
                  name="location"
                  className="block w-full pl-3 pr-10 py-2 text-base border-gray-300 focus:outline-none focus:ring-primary-500 focus:border-primary-500 sm:text-sm rounded-md h-10"
                  defaultValue=""
                >
                  <option value="">Toutes les villes</option>
                  <option>Paris</option>
                  <option>Lyon</option>
                  <option>Marseille</option>
                  <option>Toulouse</option>
                </select>
              </div>
            </div>
            <div className="flex-shrink-0">
              <button
                type="button"
                className="inline-flex items-center px-4 py-2 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500 h-10"
              >
                <FunnelIcon className="-ml-1 mr-2 h-5 w-5 text-gray-400" aria-hidden="true" />
                Filtres
              </button>
            </div>
          </div>
        </div>

        {/* Doctors List */}
        <div className="mt-6 grid gap-6 sm:grid-cols-1 lg:grid-cols-2">
          {doctors.map((doctor) => (
            <div key={doctor.id} className="bg-white overflow-hidden shadow rounded-lg">
              <div className="p-6">
                <div className="flex items-start">
                  <div className="flex-shrink-0 h-24 w-24 rounded-full bg-gray-200 overflow-hidden">
                    <div className="h-full w-full flex items-center justify-center text-gray-400">
                      {doctor.name.charAt(0)}
                    </div>
                  </div>
                  <div className="ml-6 flex-1">
                    <div className="flex items-center justify-between">
                      <h3 className="text-lg font-medium text-gray-900">{doctor.name}</h3>
                      <div className="flex items-center">
                        <StarIcon className="h-5 w-5 text-yellow-400" aria-hidden="true" />
                        <span className="ml-1 text-sm text-gray-600">
                          {doctor.rating} <span className="text-gray-400">({doctor.reviews} avis)</span>
                        </span>
                      </div>
                    </div>
                    <p className="mt-1 text-sm text-gray-600">{doctor.specialty}</p>
                    <div className="mt-2 flex items-center text-sm text-gray-500">
                      <MapPinIcon className="flex-shrink-0 mr-1.5 h-4 w-4 text-gray-400" aria-hidden="true" />
                      <p>{doctor.address}</p>
                    </div>
                    <div className="mt-2 flex flex-wrap gap-2">
                      {doctor.languages.map((lang) => (
                        <span
                          key={lang}
                          className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800"
                        >
                          {lang}
                        </span>
                      ))}
                    </div>
                    <div className="mt-3 flex items-center justify-between">
                      <div className="flex items-center space-x-1">
                        {doctor.availability.map((day) => (
                          <span
                            key={day}
                            className="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-green-100 text-green-800"
                          >
                            {day}
                          </span>
                        ))}
                      </div>
                      <div className="text-lg font-semibold text-gray-900">{doctor.price}€</div>
                    </div>
                  </div>
                </div>
                <div className="mt-6 flex justify-end">
                  <Link
                    href={`/doctors/${doctor.id}`}
                    className="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-primary-600 hover:bg-primary-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500"
                  >
                    Prendre rendez-vous
                  </Link>
                </div>
              </div>
            </div>
          ))}
        </div>

        {/* Pagination */}
        <nav
          className="bg-white px-4 py-3 flex items-center justify-between border-t border-gray-200 sm:px-6 mt-6 rounded-lg shadow"
          aria-label="Pagination"
        >
          <div className="hidden sm:block">
            <p className="text-sm text-gray-700">
              Affichage de <span className="font-medium">1</span> à <span className="font-medium">4</span> sur{' '}
              <span className="font-medium">12</span> médecins
            </p>
          </div>
          <div className="flex-1 flex justify-between sm:justify-end">
            <button
              className="relative inline-flex items-center px-4 py-2 border border-gray-300 text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50"
              disabled
            >
              Précédent
            </button>
            <button className="ml-3 relative inline-flex items-center px-4 py-2 border border-gray-300 text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50">
              Suivant
            </button>
          </div>
        </nav>
      </div>
    </div>
  );
}
