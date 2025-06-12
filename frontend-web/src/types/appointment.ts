export type AppointmentStatus = 'scheduled' | 'completed' | 'cancelled' | 'no_show';
export type AppointmentType = 'consultation' | 'follow-up' | 'check-up';

export interface Appointment {
  id: number;
  scheduled_date: string;
  start_time: string;
  end_time: string;
  status: AppointmentStatus;
  status_display: string;
  appointment_type: AppointmentType;
  type_display: string;
  patient_name: string;
  doctor_name: string;
  is_paid: boolean;
  amount: string;
  location?: string;
  meetingLink?: string;
}
