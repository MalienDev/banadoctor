'use client';

import Link from 'next/link';
import { Formik, Form, Field } from 'formik';
import * as Yup from 'yup';
import { useAuth } from '@/contexts/AuthContext';
import { useState } from 'react';

const RegisterSchema = Yup.object().shape({
  firstName: Yup.string().required('Champ requis'),
  lastName: Yup.string().required('Champ requis'),
  email: Yup.string().email('Email invalide').required('Champ requis'),
  password: Yup.string()
    .min(8, 'Le mot de passe doit contenir au moins 8 caractères')
    .required('Champ requis'),
  confirmPassword: Yup.string()
    .oneOf([Yup.ref('password')], 'Les mots de passe ne correspondent pas')
    .required('Veuillez confirmer votre mot de passe'),
  terms: Yup.boolean().oneOf([true], "Vous devez accepter les conditions d'utilisation"),
});

export default function ProRegisterPage() {
  const { register, loading } = useAuth();
  const [showPassword, setShowPassword] = useState(false);

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
            Créer un compte professionnel
          </h2>
        </div>

        <Formik
          initialValues={{
            firstName: '',
            lastName: '',
            email: '',
            password: '',
            confirmPassword: '',
            terms: false,
          }}
          validationSchema={RegisterSchema}
          onSubmit={async (values, { setSubmitting, setStatus }) => {
            try {
              await register({
                first_name: values.firstName.trim(),
                last_name: values.lastName.trim(),
                email: values.email.trim().toLowerCase(),
                password: values.password,
                password2: values.confirmPassword,
                user_type: 'doctor', // Hardcoded for professionals
              });
              // Redirection is handled by AuthContext
            } catch (error) {
              setStatus("Une erreur s'est produite lors de l'inscription. Veuillez réessayer.");
            } finally {
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
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <label htmlFor="firstName" className="sr-only">
                      Prénom
                    </label>
                    <Field
                      id="firstName"
                      name="firstName"
                      type="text"
                      className={`appearance-none relative block w-full px-3 py-2 border ${
                        errors.firstName && touched.firstName ? 'border-red-300' : 'border-gray-300'
                      } placeholder-gray-500 text-gray-900 rounded-md focus:outline-none focus:ring-primary-500 focus:border-primary-500 focus:z-10 sm:text-sm`}
                      placeholder="Prénom"
                    />
                    {errors.firstName && touched.firstName && (
                      <p className="mt-1 text-xs text-red-600">{errors.firstName}</p>
                    )}
                  </div>
                  <div>
                    <label htmlFor="lastName" className="sr-only">
                      Nom
                    </label>
                    <Field
                      id="lastName"
                      name="lastName"
                      type="text"
                      className={`appearance-none relative block w-full px-3 py-2 border ${
                        errors.lastName && touched.lastName ? 'border-red-300' : 'border-gray-300'
                      } placeholder-gray-500 text-gray-900 rounded-md focus:outline-none focus:ring-primary-500 focus:border-primary-500 focus:z-10 sm:text-sm`}
                      placeholder="Nom"
                    />
                    {errors.lastName && touched.lastName && (
                      <p className="mt-1 text-xs text-red-600">{errors.lastName}</p>
                    )}
                  </div>
                </div>
                <div>
                  <label htmlFor="email" className="sr-only">
                    Adresse email
                  </label>
                  <Field
                    id="email"
                    name="email"
                    type="email"
                    className={`appearance-none relative block w-full px-3 py-2 border ${
                      errors.email && touched.email ? 'border-red-300' : 'border-gray-300'
                    } placeholder-gray-500 text-gray-900 rounded-md focus:outline-none focus:ring-primary-500 focus:border-primary-500 focus:z-10 sm:text-sm`}
                    placeholder="Adresse email"
                  />
                  {errors.email && touched.email && (
                    <p className="mt-1 text-xs text-red-600">{errors.email}</p>
                  )}
                </div>
                <div>
                  <label htmlFor="password" className="sr-only">
                    Mot de passe
                  </label>
                  <div className="relative">
                    <Field
                      id="password"
                      name="password"
                      type={showPassword ? 'text' : 'password'}
                      className={`appearance-none relative block w-full px-3 py-2 border ${
                        errors.password && touched.password ? 'border-red-300' : 'border-gray-300'
                      } placeholder-gray-500 text-gray-900 rounded-md focus:outline-none focus:ring-primary-500 focus:border-primary-500 focus:z-10 sm:text-sm`}
                      placeholder="Mot de passe"
                    />
                    <button
                      type="button"
                      onClick={() => setShowPassword(!showPassword)}
                      className="absolute inset-y-0 right-0 px-3 flex items-center text-sm leading-5"
                    >
                      {showPassword ? 'Hide' : 'Show'}
                    </button>
                  </div>
                  {errors.password && touched.password && (
                    <p className="mt-1 text-xs text-red-600">{errors.password}</p>
                  )}
                </div>
                <div>
                  <label htmlFor="confirmPassword" className="sr-only">
                    Confirmer le mot de passe
                  </label>
                  <Field
                    id="confirmPassword"
                    name="confirmPassword"
                    type="password"
                    className={`appearance-none relative block w-full px-3 py-2 border ${
                      errors.confirmPassword && touched.confirmPassword ? 'border-red-300' : 'border-gray-300'
                    } placeholder-gray-500 text-gray-900 rounded-md focus:outline-none focus:ring-primary-500 focus:border-primary-500 focus:z-10 sm:text-sm`}
                    placeholder="Confirmer le mot de passe"
                  />
                  {errors.confirmPassword && touched.confirmPassword && (
                    <p className="mt-1 text-xs text-red-600">{errors.confirmPassword}</p>
                  )}
                </div>
              </div>

              <div className="flex items-start">
                <div className="flex items-center h-5">
                  <Field
                    id="terms"
                    name="terms"
                    type="checkbox"
                    className="h-4 w-4 text-primary-600 focus:ring-primary-500 border-gray-300 rounded"
                  />
                </div>
                <div className="ml-3 text-sm">
                  <label htmlFor="terms" className="font-medium text-gray-700">
                    J'accepte les{' '}
                    <Link href="/terms" className="text-primary-600 hover:text-primary-500">
                      conditions d'utilisation
                    </Link>{' '}
                    et la{' '}
                    <Link href="/privacy" className="text-primary-600 hover:text-primary-500">
                      politique de confidentialité
                    </Link>
                  </label>
                  {errors.terms && typeof errors.terms === 'string' && (
                    <p className="mt-1 text-xs text-red-600">{errors.terms}</p>
                  )}
                </div>
              </div>

              <div>
                <button
                  type="submit"
                  disabled={isSubmitting}
                  className={`group relative w-full flex justify-center py-2 px-4 border border-transparent text-sm font-medium rounded-md text-white ${
                    isSubmitting ? 'bg-primary-400' : 'bg-primary-600 hover:bg-primary-700'
                  } focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500`}
                >
                  {isSubmitting ? 'Inscription en cours...' : "S'inscrire"}
                </button>
              </div>
            </Form>
          )}
        </Formik>

        <div className="text-center">
          <p className="text-sm text-gray-600">
            Déjà un compte professionnel ?{' '}
            <Link href="/pro/login" className="font-medium text-primary-600 hover:text-primary-500">
              Se connecter
            </Link>
          </p>
        </div>
      </div>
    </div>
  );
}
