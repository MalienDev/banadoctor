'use client';

import { useEffect, useState } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import { useAuth } from '@/contexts/AuthContext';
import { toast } from 'react-hot-toast';
import { Button } from '@/components/ui/button';
import { CheckCircleIcon, EnvelopeIcon, ArrowPathIcon } from '@/components/icons';

export default function ActivateAccountPage() {
  const [isLoading, setIsLoading] = useState(false);
  const [email, setEmail] = useState('');
  const { user, logout } = useAuth();
  const router = useRouter();
  const searchParams = useSearchParams();

  useEffect(() => {
    // Get email from URL params or from the auth context
    const emailParam = searchParams.get('email');
    if (emailParam) {
      setEmail(emailParam);
    } else if (user?.email) {
      setEmail(user.email);
    } else {
      // If no email is available, redirect to login
      router.push('/login');
    }
  }, [searchParams, user, router]);

  const handleResendEmail = async () => {
    if (!email) return;
    
    try {
      setIsLoading(true);
      const response = await fetch('/api/auth/resend-verification', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ email }),
      });

      const data = await response.json();

      if (!response.ok) {
        throw new Error(data.error || 'Failed to resend verification email');
      }

      toast.success(data.message || 'Verification email sent successfully!');
    } catch (error) {
      console.error('Error resending verification email:', error);
      toast.error(error instanceof Error ? error.message : 'Failed to resend verification email');
    } finally {
      setIsLoading(false);
    }
  };

  const handleSignOut = () => {
    logout();
    router.push('/login');
  };

  if (!email) {
    return (
      <div className="min-h-screen flex items-center justify-center p-6 bg-gray-50">
        <div className="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-blue-500"></div>
      </div>
    );
  }

  return (
    <div className="min-h-screen flex items-center justify-center p-6 bg-gray-50">
      <div className="max-w-md w-full bg-white p-8 rounded-lg shadow-sm space-y-6">
        <div className="text-center space-y-4">
          <div className="mx-auto flex items-center justify-center h-16 w-16 rounded-full bg-blue-50">
            <EnvelopeIcon className="h-8 w-8 text-blue-600" />
          </div>
          <h1 className="text-2xl font-bold text-gray-900">Vérifiez votre adresse e-mail</h1>
          <p className="text-gray-600">
            Nous avons envoyé un lien d'activation à <span className="font-medium text-gray-900">{email}</span>.
            Cliquez sur le lien pour activer votre compte.
          </p>
        </div>

        <div className="bg-blue-50 p-4 rounded-md text-sm text-blue-800">
          <p className="font-medium">Vous n'avez pas reçu l'e-mail ?</p>
          <ul className="list-disc pl-5 mt-2 space-y-1">
            <li>Vérifiez votre dossier de courrier indésirable ou spam</li>
            <li>Vérifiez que l'adresse e-mail est correcte</li>
          </ul>
        </div>

        <div className="space-y-3">
          <Button
            onClick={handleResendEmail}
            disabled={isLoading}
            className="w-full"
          >
            {isLoading ? (
              <>
                <ArrowPathIcon className="mr-2 h-4 w-4 animate-spin" />
                Envoi en cours...
              </>
            ) : (
              "Renvoyer l'e-mail de vérification"
            )}
          </Button>

          <div className="relative my-4">
            <div className="absolute inset-0 flex items-center">
              <span className="w-full border-t border-gray-300"></span>
            </div>
            <div className="relative flex justify-center text-sm">
              <span className="px-2 bg-white text-gray-500">
                Ou
              </span>
            </div>
          </div>

          <Button
            variant="outline"
            onClick={handleSignOut}
            className="w-full"
          >
            Se déconnecter
          </Button>
        </div>
      </div>
    </div>
  );
}
