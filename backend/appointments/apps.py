from django.apps import AppConfig


class AppointmentsConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'appointments'
    verbose_name = 'Gestion des Rendez-vous'
    
    def ready(self):
        # Import signals to register them
        import appointments.signals
