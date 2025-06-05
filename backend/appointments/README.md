# Appointments App

This app handles all appointment-related functionality for the Medecin Africa platform, including scheduling, management, and notifications.

## Features

- **Appointment Management**: Create, view, update, and cancel appointments
- **Doctor Schedules**: Manage doctor availability and working hours
- **Time Slots**: Handle available time slots and prevent double-booking
- **Reminders**: Automatic email reminders for upcoming appointments
- **Status Updates**: Notifications for appointment status changes

## Models

### Appointment
Represents a booking between a patient and a doctor.

### TimeSlot
Represents available time slots for appointments, linked to a doctor's schedule.

### AppointmentReminder
Tracks and sends reminders for upcoming appointments.

### DoctorSchedule
Stores a doctor's working hours and availability.

## API Endpoints

### Appointments
- `GET /api/v1/appointments/` - List all appointments (filterable by user role)
- `POST /api/v1/appointments/create/` - Create a new appointment
- `GET /api/v1/appointments/{id}/` - Get appointment details
- `PUT /api/v1/appointments/{id}/` - Update an appointment
- `DELETE /api/v1/appointments/{id}/` - Cancel an appointment

### Doctor Schedule
- `GET /api/v1/appointments/doctor/schedule/` - Get or update doctor's schedule

### Time Slots
- `GET /api/v1/appointments/timeslots/` - List available time slots

### Doctor Availability
- `GET /api/v1/appointments/doctor/{id}/availability/` - Check doctor's availability

### Book Appointment
- `POST /api/v1/appointments/book/` - Book a new appointment

### Reminders
- `GET /api/v1/appointments/{id}/reminders/` - Get or create appointment reminders

## Signals

The app includes several signals to handle automatic notifications:

- **Appointment Creation**: Sends confirmation email
- **Status Updates**: Notifies users of appointment status changes
- **Reminders**: Sends 24-hour reminders for upcoming appointments

## Templates

Email templates are located in `templates/emails/`:

- `appointment_confirmation.html` - Confirmation of new appointment
- `appointment_status_update.html` - Notification of status change
- Text versions of both templates are also available

## Testing

Run tests with:
```bash
python manage.py test appointments
```

## Contributing

1. Create a new branch for your feature
2. Write tests for your changes
3. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
