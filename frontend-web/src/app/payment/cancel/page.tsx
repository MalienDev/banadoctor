'use client';

import Link from 'next/link';
import { XCircleIcon } from '@heroicons/react/24/solid';

export default function PaymentCancelPage() {
  return (
    <div className="min-h-screen bg-gray-50 flex flex-col justify-center items-center">
      <div className="bg-white p-10 rounded-lg shadow-lg text-center max-w-md">
        <XCircleIcon className="h-20 w-20 text-red-500 mx-auto" />
        <h1 className="text-3xl font-bold text-gray-800 mt-4">Paiement annulé</h1>
        <p className="text-gray-600 mt-2">
          Le processus de paiement a été annulé. Vous n'avez pas été facturé. Vous pouvez essayer de réserver à nouveau.
        </p>
        <div className="mt-8">
          <Link
            href="/doctors"
            className="inline-block w-full px-6 py-3 bg-primary-600 text-white font-semibold rounded-lg shadow-md hover:bg-primary-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500"
          >
            Retourner à la recherche de médecins
          </Link>
        </div>
      </div>
    </div>
  );
}
