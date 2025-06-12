'use client';

import Link from 'next/link';
import { Formik, Form, Field } from 'formik';
import * as Yup from 'yup';
import { useAuth } from '@/contexts/AuthContext';

const LoginSchema = Yup.object().shape({
  email: Yup.string().email('Email invalide').required('Champ requis'),
  password: Yup.string().required('Champ requis'),
});

export default function ProLoginPage() {
  const { login, loading } = useAuth();

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-primary-500"></div>
      </div>
    );
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50 py-12 px-4 sm:px-6 lg:px-8">
      <div className="max-w-md w-full space-y-8">
        <div>
          <h2 className="mt-6 text-center text-3xl font-extrabold text-gray-900">
            Espace Professionnel
          </h2>
        </div>
        
        <Formik
          initialValues={{
            email: '',
            password: '',
          }}
          validationSchema={LoginSchema}
          onSubmit={async (values, { setSubmitting, setStatus }) => {
            try {
              await login(values.email, values.password);
              // Redirection is now handled by the login function in AuthContext
            } catch (error) {
              setStatus('Identifiants invalides. Veuillez réessayer.');
            }
            finally {
              setSubmitting(false);
            }
          }}
        >
          {({ errors, touched, isSubmitting, status }) => (
            <Form className="mt-8 space-y-6">
              {status && (
                <div className="rounded-md bg-red-50 p-4">
                  <div className="text-sm text-red-700">{status}</div>
                </div>
              )}
              
              <div className="rounded-md shadow-sm space-y-4">
                <div>
                  <label htmlFor="email" className="sr-only">
                    Adresse email
                  </label>
                  <Field
                    id="email"
                    name="email"
                    type="email"
                    autoComplete="email"
                    required
                    className={`appearance-none relative block w-full px-3 py-2 border ${
                      errors.email && touched.email ? 'border-red-300' : 'border-gray-300'
                    } placeholder-gray-500 text-gray-900 rounded-md focus:outline-none focus:ring-primary-500 focus:border-primary-500 focus:z-10 sm:text-sm`}
                    placeholder="Adresse email"
                  />
                  {errors.email && touched.email && (
                    <p className="mt-1 text-sm text-red-600">{errors.email}</p>
                  )}
                </div>
                
                <div>
                  <label htmlFor="password" className="sr-only">
                    Mot de passe
                  </label>
                  <Field
                    id="password"
                    name="password"
                    type="password"
                    autoComplete="current-password"
                    required
                    className={`appearance-none relative block w-full px-3 py-2 border ${
                      errors.password && touched.password ? 'border-red-300' : 'border-gray-300'
                    } placeholder-gray-500 text-gray-900 rounded-md focus:outline-none focus:ring-primary-500 focus:border-primary-500 focus:z-10 sm:text-sm`}
                    placeholder="Mot de passe"
                  />
                  {errors.password && touched.password && (
                    <p className="mt-1 text-sm text-red-600">{errors.password}</p>
                  )}
                </div>
              </div>

              <div>
                <button
                  type="submit"
                  disabled={isSubmitting}
                  className={`group relative w-full flex justify-center py-2 px-4 border border-transparent text-sm font-medium rounded-md text-white ${
                    isSubmitting ? 'bg-primary-400' : 'bg-blue-600 hover:bg-blue-700'
                  } focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500`}
                >
                  {isSubmitting ? 'Connexion en cours...' : 'Se connecter'}
                </button>
              </div>
            </Form>
          )}
        </Formik>
        
        <div className="text-center">
          <p className="text-sm text-gray-600">
            Pas encore de compte professionnel?{' '}
            <Link href="/pro/register" className="font-medium text-primary-600 hover:text-primary-500">
              S'inscrire
            </Link>
          </p>
        </div>
      </div>
    </div>
  );
}
