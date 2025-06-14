# Generated by Django 4.2.22 on 2025-06-09 00:58

from django.conf import settings
from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    initial = True

    dependencies = [
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
    ]

    operations = [
        migrations.CreateModel(
            name="Appointment",
            fields=[
                (
                    "id",
                    models.BigAutoField(
                        auto_created=True,
                        primary_key=True,
                        serialize=False,
                        verbose_name="ID",
                    ),
                ),
                (
                    "appointment_type",
                    models.CharField(
                        choices=[
                            ("consultation", "Consultation"),
                            ("follow_up", "Suivi"),
                            ("emergency", "Urgence"),
                            ("vaccination", "Vaccination"),
                            ("other", "Autre"),
                        ],
                        default="consultation",
                        max_length=20,
                    ),
                ),
                (
                    "status",
                    models.CharField(
                        choices=[
                            ("pending", "En attente"),
                            ("confirmed", "Confirmé"),
                            ("completed", "Terminé"),
                            ("cancelled", "Annulé"),
                            ("no_show", "Non venu"),
                        ],
                        default="pending",
                        max_length=20,
                    ),
                ),
                ("scheduled_date", models.DateField()),
                ("start_time", models.TimeField()),
                ("end_time", models.TimeField()),
                ("reason", models.TextField(blank=True, null=True)),
                ("symptoms", models.TextField(blank=True, null=True)),
                ("diagnosis", models.TextField(blank=True, null=True)),
                ("prescription", models.TextField(blank=True, null=True)),
                ("notes", models.TextField(blank=True, null=True)),
                ("is_paid", models.BooleanField(default=False)),
                (
                    "amount",
                    models.DecimalField(decimal_places=2, default=0.0, max_digits=10),
                ),
                ("created_at", models.DateTimeField(auto_now_add=True)),
                ("updated_at", models.DateTimeField(auto_now=True)),
                (
                    "doctor",
                    models.ForeignKey(
                        limit_choices_to={"user_type": "doctor"},
                        on_delete=django.db.models.deletion.CASCADE,
                        related_name="doctor_appointments",
                        to=settings.AUTH_USER_MODEL,
                    ),
                ),
                (
                    "patient",
                    models.ForeignKey(
                        limit_choices_to={"user_type": "patient"},
                        on_delete=django.db.models.deletion.CASCADE,
                        related_name="patient_appointments",
                        to=settings.AUTH_USER_MODEL,
                    ),
                ),
            ],
            options={
                "ordering": ["-scheduled_date", "start_time"],
                "unique_together": {("doctor", "scheduled_date", "start_time")},
            },
        ),
        migrations.CreateModel(
            name="AppointmentReminder",
            fields=[
                (
                    "id",
                    models.BigAutoField(
                        auto_created=True,
                        primary_key=True,
                        serialize=False,
                        verbose_name="ID",
                    ),
                ),
                (
                    "reminder_type",
                    models.CharField(
                        choices=[
                            ("email", "Email"),
                            ("sms", "SMS"),
                            ("push", "Push Notification"),
                        ],
                        max_length=10,
                    ),
                ),
                ("scheduled_time", models.DateTimeField()),
                ("sent_time", models.DateTimeField(blank=True, null=True)),
                ("is_sent", models.BooleanField(default=False)),
                ("created_at", models.DateTimeField(auto_now_add=True)),
                (
                    "appointment",
                    models.ForeignKey(
                        on_delete=django.db.models.deletion.CASCADE,
                        related_name="reminders",
                        to="appointments.appointment",
                    ),
                ),
            ],
        ),
        migrations.CreateModel(
            name="TimeSlot",
            fields=[
                (
                    "id",
                    models.BigAutoField(
                        auto_created=True,
                        primary_key=True,
                        serialize=False,
                        verbose_name="ID",
                    ),
                ),
                ("date", models.DateField()),
                ("start_time", models.TimeField()),
                ("end_time", models.TimeField()),
                ("is_available", models.BooleanField(default=True)),
                (
                    "appointment",
                    models.OneToOneField(
                        blank=True,
                        null=True,
                        on_delete=django.db.models.deletion.SET_NULL,
                        related_name="time_slot",
                        to="appointments.appointment",
                    ),
                ),
                (
                    "doctor",
                    models.ForeignKey(
                        limit_choices_to={"user_type": "doctor"},
                        on_delete=django.db.models.deletion.CASCADE,
                        related_name="time_slots",
                        to=settings.AUTH_USER_MODEL,
                    ),
                ),
            ],
            options={
                "ordering": ["date", "start_time"],
                "unique_together": {("doctor", "date", "start_time", "end_time")},
            },
        ),
        migrations.CreateModel(
            name="DoctorSchedule",
            fields=[
                (
                    "id",
                    models.BigAutoField(
                        auto_created=True,
                        primary_key=True,
                        serialize=False,
                        verbose_name="ID",
                    ),
                ),
                (
                    "day_of_week",
                    models.IntegerField(
                        choices=[
                            (0, "Monday"),
                            (1, "Tuesday"),
                            (2, "Wednesday"),
                            (3, "Thursday"),
                            (4, "Friday"),
                            (5, "Saturday"),
                            (6, "Sunday"),
                        ]
                    ),
                ),
                ("start_time", models.TimeField()),
                ("end_time", models.TimeField()),
                ("is_working_day", models.BooleanField(default=True)),
                (
                    "doctor",
                    models.ForeignKey(
                        limit_choices_to={"user_type": "doctor"},
                        on_delete=django.db.models.deletion.CASCADE,
                        related_name="schedules",
                        to=settings.AUTH_USER_MODEL,
                    ),
                ),
            ],
            options={
                "ordering": ["day_of_week", "start_time"],
                "unique_together": {("doctor", "day_of_week")},
            },
        ),
    ]
