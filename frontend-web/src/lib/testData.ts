import { Appointment } from '@/types/appointment';

// Données de test pour les rendez-vous
export const testAppointments: Appointment[] = [
  {
    id: 1,
    scheduled_date: '2025-06-15',
    start_time: '09:00:00',
    end_time: '09:30:00',
    status: 'scheduled',
    status_display: 'Confirmé',
    appointment_type: 'consultation',
    type_display: 'Consultation',
    patient_name: 'Jean Dupont',
    doctor_name: 'Dr. Marie Martin',
    is_paid: false,
    amount: '5000',
    location: 'Cabinet Principal, 1er étage',
    meetingLink: 'https://meet.example.com/abc123'
  },
  {
    id: 2,
    scheduled_date: '2025-06-16',
    start_time: '14:30:00',
    end_time: '15:00:00',
    status: 'scheduled',
    status_display: 'Confirmé',
    appointment_type: 'follow-up',
    type_display: 'Suivi',
    patient_name: 'Sophie Lambert',
    doctor_name: 'Dr. Pierre Dubois',
    is_paid: true,
    amount: '3000',
    location: 'Cabinet Secondaire, RDC',
    meetingLink: 'https://meet.example.com/def456'
  },
  {
    id: 3,
    scheduled_date: '2025-06-17',
    start_time: '11:15:00',
    end_time: '11:45:00',
    status: 'completed',
    status_display: 'Terminé',
    appointment_type: 'check-up',
    type_display: 'Bilan de santé',
    patient_name: 'Thomas Leroy',
    doctor_name: 'Dr. Marie Martin',
    is_paid: true,
    amount: '7500',
    location: 'Cabinet Principal, 2ème étage'
  }
];
