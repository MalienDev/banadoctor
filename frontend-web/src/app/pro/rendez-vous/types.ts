export type Appointment = {
  id: number;
  patient: string;
  date: string;
  time: string;
  type: 'in-person' | 'teleconsultation';
  status: 'confirmé' | 'en attente' | 'annulé';
};
