'use client';

import { MagnifyingGlassIcon, FunnelIcon, MapPinIcon, StarIcon } from '@heroicons/react/24/solid';
import Link from 'next/link';
import { useEffect, useState } from 'react';

// New Doctor type matching the backend serializer
type DoctorProfile = {
  specialization: string;
  license_number: string;
  years_of_experience: number;
  bio: string;
  consultation_fee: number;
  address: string;
  city: string;
  country: string;
};

type Doctor = {
  id: number;
  email: string;
  first_name: string;
  last_name: string;
  phone_number: string;
  profile_picture: string | null;
  doctor_profile: DoctorProfile;
};

export default function DoctorsPage() {
  const [doctors, setDoctors] = useState<Doctor[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchDoctors = async () => {
      try {
        const response = await fetch(`${process.env.NEXT_PUBLIC_API_URL}/api/v1/doctors/`);
        if (!response.ok) {
          const errorData = await response.json();
          throw new Error(errorData.detail || 'Failed to fetch doctors');
        }
        const data = await response.json();
        setDoctors(data);
      } catch (err) {
        setError(err instanceof Error ? err.message : 'An unknown error occurred');
      } finally {
        setLoading(false);
      }
    };

    fetchDoctors();
  }, []);

  if (loading) {
    return (
      <div className="flex justify-center items-center min-h-screen">
        <div className="animate-spin rounded-full h-32 w-32 border-t-2 border-b-2 border-primary-600"></div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="flex flex-col justify-center items-center min-h-screen">
        <div className="text-red-500 text-xl bg-red-100 p-4 rounded-lg">Error: {error}</div>
        <p className='mt-4 text-gray-600'>Please ensure the backend server is running and the API URL is correct.</p>
      </div>
    );
  }

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
        <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
          <div className="space-y-6">
            {doctors.length > 0 ? doctors.map((doctor) => (
              <div key={doctor.id} className="bg-white rounded-lg shadow-lg overflow-hidden">
                <div className="p-6">
                  <div className="flex items-start">
                    <div className="h-24 w-24 rounded-full bg-gray-200 overflow-hidden flex-shrink-0">
                      {doctor.profile_picture ? (
                        <img className="h-full w-full object-cover" src={`${process.env.NEXT_PUBLIC_API_BASE_URL}${doctor.profile_picture}`} alt={`${doctor.first_name} ${doctor.last_name}`} />
                      ) : (
                        <div className="h-full w-full flex items-center justify-center text-gray-400 text-3xl font-bold">
                          {doctor.first_name.charAt(0)}{doctor.last_name.charAt(0)}
                        </div>
                      )}
                    </div>
                    <div className="ml-6 flex-1">
                      <div className="flex items-center justify-between">
                        <h3 className="text-lg font-medium text-gray-900">{`Dr. ${doctor.first_name} ${doctor.last_name}`}</h3>
                      </div>
                      <p className="mt-1 text-sm text-gray-600">{doctor.doctor_profile.specialization}</p>
                      <div className="mt-2 flex items-center text-sm text-gray-500">
                        <MapPinIcon className="flex-shrink-0 mr-1.5 h-4 w-4 text-gray-400" aria-hidden="true" />
                        <p>{`${doctor.doctor_profile.address}, ${doctor.doctor_profile.city}`}</p>
                      </div>
                      <div className="mt-3 flex items-center justify-between">
                        <div className="text-lg font-semibold text-gray-900">{doctor.doctor_profile.consultation_fee}€</div>
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
            )) : (
              <div className="text-center py-12">
                <h3 className="text-lg font-medium text-gray-900">Aucun médecin trouvé</h3>
                <p className="mt-1 text-sm text-gray-500">Veuillez réessayer plus tard ou ajuster vos filtres de recherche.</p>
              </div>
            )}
          </div>

          {/* Pagination */}
          <nav
            className="bg-white px-4 py-3 flex items-center justify-between border-t border-gray-200 sm:px-6 mt-6 rounded-lg shadow"
            aria-label="Pagination"
          >
            <div className="hidden sm:block">
              <p className="text-sm text-gray-700">
                Affichage de <span className="font-medium">1</span> à <span className="font-medium">{doctors.length}</span> sur{' '}
                <span className="font-medium">{doctors.length}</span> médecins
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
        </main>

      </div>
    </div>
  );
}
