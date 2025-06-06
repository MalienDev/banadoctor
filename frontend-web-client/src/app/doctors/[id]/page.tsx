import { StarIcon, MapPinIcon, ClockIcon, PhoneIcon, EnvelopeIcon, CalendarIcon, CheckCircleIcon } from '@heroicons/react/24/solid';

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
  availability: {
    day: string;
    hours: string;
  }[];
  about: string;
  education: {
    degree: string;
    university: string;
    year: string;
  }[];
  experience: {
    position: string;
    hospital: string;
    duration: string;
  }[];
};

const doctor: Doctor = {
  id: 1,
  name: 'Dr. Marie Dupont',
  specialty: 'Cardiologue',
  address: '123 Rue de Paris, 75001 Paris',
  rating: 4.8,
  reviews: 124,
  image: '/doctors/doctor1.jpg',
  price: 60,
  languages: ['Français', 'Anglais'],
  availability: [
    { day: 'Lundi', hours: '09:00 - 13:00, 14:00 - 18:00' },
    { day: 'Mardi', hours: '09:00 - 13:00, 14:00 - 18:00' },
    { day: 'Jeudi', hours: '09:00 - 13:00, 14:00 - 18:00' },
  ],
  about: 'Le Dr. Marie Dupont est une cardiologue expérimentée avec plus de 15 ans d\'expérience dans le diagnostic et le traitement des maladies cardiovasculaires. Elle est spécialisée dans les échocardiographies et les tests d\'effort.',
  education: [
    {
      degree: 'Doctorat en Médecine',
      university: 'Université Paris Descartes',
      year: '2005',
    },
    {
      degree: 'DES de Cardiologie',
      university: 'Hôpital Européen Georges-Pompidou',
      year: '2010',
    },
  ],
  experience: [
    {
      position: 'Cardiologue',
      hospital: 'Hôpital Pitié-Salpêtrière',
      duration: '2015 - Présent',
    },
    {
      position: 'Interne en Cardiologie',
      hospital: 'Hôpital Bichat',
      duration: '2010 - 2015',
    },
  ],
};

type Review = {
  id: number;
  author: string;
  rating: number;
  date: string;
  comment: string;
};

const reviews: Review[] = [
  {
    id: 1,
    author: 'Jean Dupont',
    rating: 5,
    date: '15 mars 2025',
    comment: 'Excellente médecin, très à l\'écoute et professionnelle. Je la recommande vivement !',
  },
  {
    id: 2,
    author: 'Sophie Martin',
    rating: 4,
    date: '2 mars 2025',
    comment: 'Bonne expérience globale, bien que l\'attente ait été un peu longue.',
  },
];

export default function DoctorDetailPage() {
  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white shadow">
        <div className="max-w-7xl mx-auto py-6 px-4 sm:px-6 lg:px-8">
          <h1 className="text-3xl font-bold text-gray-900">Profil du médecin</h1>
        </div>
      </header>

      <main className="max-w-7xl mx-auto py-6 sm:px-6 lg:px-8">
        <div className="px-4 sm:px-0">
          <div className="bg-white shadow overflow-hidden sm:rounded-lg">
            {/* Doctor Header */}
            <div className="px-4 py-5 sm:px-6 border-b border-gray-200">
              <div className="flex flex-col md:flex-row md:items-center md:justify-between">
                <div className="flex items-center">
                  <div className="h-24 w-24 rounded-full bg-gray-200 overflow-hidden flex-shrink-0">
                    <div className="h-full w-full flex items-center justify-center text-3xl font-bold text-gray-500">
                      {doctor.name.charAt(0)}
                    </div>
                  </div>
                  <div className="ml-6">
                    <h2 className="text-2xl font-bold text-gray-900">{doctor.name}</h2>
                    <p className="text-lg text-gray-600">{doctor.specialty}</p>
                    <div className="mt-1 flex items-center">
                      <div className="flex items-center">
                        <StarIcon className="h-5 w-5 text-yellow-400" />
                        <span className="ml-1 text-gray-600">
                          {doctor.rating} <span className="text-gray-400">({doctor.reviews} avis)</span>
                        </span>
                      </div>
                      <span className="mx-2 text-gray-300">•</span>
                      <div className="flex items-center text-gray-600">
                        <MapPinIcon className="h-4 w-4 mr-1" />
                        <span>{doctor.address}</span>
                      </div>
                    </div>
                  </div>
                </div>
                <div className="mt-4 md:mt-0">
                  <div className="text-2xl font-bold text-primary-600">{doctor.price}€</div>
                  <div className="text-sm text-gray-500">par consultation</div>
                </div>
              </div>
            </div>

            <div className="px-4 py-5 sm:p-6">
              <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
                {/* Left Column */}
                <div className="lg:col-span-2">
                  {/* About */}
                  <div className="mb-8">
                    <h3 className="text-lg font-medium text-gray-900 mb-4">À propos</h3>
                    <p className="text-gray-600">{doctor.about}</p>
                  </div>

                  {/* Education */}
                  <div className="mb-8">
                    <h3 className="text-lg font-medium text-gray-900 mb-4">Formation</h3>
                    <div className="space-y-4">
                      {doctor.education.map((edu, index) => (
                        <div key={index} className="flex">
                          <div className="flex-shrink-0 h-10 w-10 rounded-full bg-blue-100 flex items-center justify-center">
                            <CheckCircleIcon className="h-6 w-6 text-blue-600" />
                          </div>
                          <div className="ml-4">
                            <h4 className="text-sm font-medium text-gray-900">{edu.degree}</h4>
                            <p className="text-sm text-gray-600">{edu.university}</p>
                            <p className="text-xs text-gray-500">{edu.year}</p>
                          </div>
                        </div>
                      ))}
                    </div>
                  </div>

                  {/* Experience */}
                  <div className="mb-8">
                    <h3 className="text-lg font-medium text-gray-900 mb-4">Expérience</h3>
                    <div className="space-y-4">
                      {doctor.experience.map((exp, index) => (
                        <div key={index} className="flex">
                          <div className="flex-shrink-0 h-10 w-10 rounded-full bg-blue-100 flex items-center justify-center">
                            <CheckCircleIcon className="h-6 w-6 text-blue-600" />
                          </div>
                          <div className="ml-4">
                            <h4 className="text-sm font-medium text-gray-900">{exp.position}</h4>
                            <p className="text-sm text-gray-600">{exp.hospital}</p>
                            <p className="text-xs text-gray-500">{exp.duration}</p>
                          </div>
                        </div>
                      ))}
                    </div>
                  </div>

                  {/* Reviews */}
                  <div>
                    <h3 className="text-lg font-medium text-gray-900 mb-4">Avis des patients</h3>
                    <div className="space-y-6">
                      {reviews.map((review) => (
                        <div key={review.id} className="border-b border-gray-200 pb-6">
                          <div className="flex items-center justify-between">
                            <div>
                              <h4 className="text-sm font-medium text-gray-900">{review.author}</h4>
                              <div className="flex items-center mt-1">
                                {[1, 2, 3, 4, 5].map((rating) => (
                                  <StarIcon
                                    key={rating}
                                    className={`h-4 w-4 ${
                                      rating <= review.rating ? 'text-yellow-400' : 'text-gray-300'
                                    }`}
                                    aria-hidden="true"
                                  />
                                ))}
                              </div>
                            </div>
                            <p className="text-sm text-gray-500">{review.date}</p>
                          </div>
                          <p className="mt-2 text-sm text-gray-600">{review.comment}</p>
                        </div>
                      ))}
                    </div>
                  </div>
                </div>

                {/* Right Column - Appointment */}
                <div className="lg:col-span-1">
                  <div className="bg-white border border-gray-200 rounded-lg p-6 shadow-sm sticky top-6">
                    <h3 className="text-lg font-medium text-gray-900 mb-4">Prendre rendez-vous</h3>
                    
                    <div className="space-y-4">
                      <div>
                        <label htmlFor="date" className="block text-sm font-medium text-gray-700">Date</label>
                        <div className="mt-1 relative rounded-md shadow-sm">
                          <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                            <CalendarIcon className="h-5 w-5 text-gray-400" />
                          </div>
                          <input
                            type="date"
                            name="date"
                            id="date"
                            className="focus:ring-primary-500 focus:border-primary-500 block w-full pl-10 sm:text-sm border-gray-300 rounded-md h-10"
                            min={new Date().toISOString().split('T')[0]}
                          />
                        </div>
                      </div>

                      <div>
                        <label htmlFor="time" className="block text-sm font-medium text-gray-700">Heure</label>
                        <select
                          id="time"
                          name="time"
                          className="mt-1 block w-full pl-3 pr-10 py-2 text-base border-gray-300 focus:outline-none focus:ring-primary-500 focus:border-primary-500 sm:text-sm rounded-md h-10"
                          defaultValue=""
                        >
                          <option value="">Sélectionner une heure</option>
                          <option>09:00</option>
                          <option>09:30</option>
                          <option>10:00</option>
                          <option>10:30</option>
                          <option>11:00</option>
                          <option>11:30</option>
                          <option>14:00</option>
                          <option>14:30</option>
                          <option>15:00</option>
                          <option>15:30</option>
                          <option>16:00</option>
                          <option>16:30</option>
                          <option>17:00</option>
                          <option>17:30</option>
                        </select>
                      </div>

                      <div className="pt-2">
                        <button
                          type="button"
                          className="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-primary-600 hover:bg-primary-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500"
                        >
                          Confirmer le rendez-vous
                        </button>
                      </div>
                    </div>

                    <div className="mt-6 border-t border-gray-200 pt-6">
                      <h4 className="text-sm font-medium text-gray-900 mb-3">Disponibilités</h4>
                      <ul className="space-y-3">
                        {doctor.availability.map((slot, index) => (
                          <li key={index} className="flex justify-between">
                            <span className="text-sm text-gray-600">{slot.day}</span>
                            <span className="text-sm font-medium text-gray-900">{slot.hours}</span>
                          </li>
                        ))}
                      </ul>
                    </div>

                    <div className="mt-6 border-t border-gray-200 pt-6">
                      <h4 className="text-sm font-medium text-gray-900 mb-3">Contact</h4>
                      <div className="space-y-2">
                        <div className="flex items-center">
                          <PhoneIcon className="h-5 w-5 text-gray-400 mr-2" />
                          <span className="text-sm text-gray-600">+33 1 23 45 67 89</span>
                        </div>
                        <div className="flex items-center">
                          <EnvelopeIcon className="h-5 w-5 text-gray-400 mr-2" />
                          <span className="text-sm text-blue-600">contact@drmariedupont.fr</span>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </main>
    </div>
  );
}
