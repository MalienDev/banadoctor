'use client';

import { useRouter } from 'next/navigation';

export default function Home() {
  const router = useRouter();

  const navigateToDoctors = () => {
    router.push('/doctors');
  };

  const navigateToAppointment = () => {
    router.push('/appointments');
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-50 to-gray-100 dark:from-gray-900 dark:to-gray-800">
      <main className="container mx-auto px-4 py-16">
        <div className="max-w-3xl mx-auto text-center">
          <h1 className="text-4xl md:text-5xl font-bold text-gray-900 dark:text-white mb-6">
            Welcome to <span className="text-primary-600">Medecin Africa</span>
          </h1>
          
          <p className="text-xl text-gray-600 dark:text-gray-300 mb-8">
            Your trusted healthcare platform connecting patients with doctors across Africa
          </p>
          
          <div className="flex flex-col sm:flex-row gap-4 justify-center mt-8">
            <button 
              onClick={navigateToDoctors}
              className="btn btn-primary"
            >
              Find a Doctor
            </button>
            <button 
              onClick={navigateToAppointment}
              className="btn bg-white text-gray-800 border border-gray-300 hover:bg-gray-50"
            >
              Book Appointment
            </button>
          </div>
        </div>
      </main>
    </div>
  );
}
