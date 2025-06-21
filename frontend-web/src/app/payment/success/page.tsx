'use client';

import { useEffect } from 'react';
import Link from 'next/link';
import { CheckCircleIcon } from '@heroicons/react/24/solid';
import { useSearchParams } from 'next/navigation';

export default function PaymentSuccessPage() {
  const searchParams = useSearchParams();
  const sessionId = searchParams.get('session_id');

  useEffect(() => {
    // The backend webhook is the primary source of truth for payment confirmation.
    // This page just provides immediate user feedback.
    // A call to a verification endpoint could be added here for extra assurance.
    if (sessionId) {
      console.log('Payment completed with session ID:', sessionId);
    }
  }, [sessionId]);

  return (
    <div className="min-h-screen bg-gray-50 flex flex-col justify-center items-center">
      <div className="bg-white p-10 rounded-lg shadow-lg text-center max-w-md">
        <CheckCircleIcon className="h-20 w-20 text-green-500 mx-auto" />
        <h1 className="text-3xl font-bold text-gray-800 mt-4">Paiement réussi !</h1>
        <p className="text-gray-600 mt-2">
          Merci pour votre paiement. Votre rendez-vous est confirmé. Vous recevrez bientôt une notification de confirmation.
        </p>
        <div className="mt-8">
          <Link
            href="/appointments"
            className="inline-block w-full px-6 py-3 bg-primary-600 text-white font-semibold rounded-lg shadow-md hover:bg-primary-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500"
          >
            Voir mes rendez-vous
          </Link>
        </div>
      </div>
    </div>
  );
}
