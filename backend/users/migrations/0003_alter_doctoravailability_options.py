# Generated by Django 4.2.23 on 2025-06-14 13:12

from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('users', '0002_alter_user_location'),
    ]

    operations = [
        migrations.AlterModelOptions(
            name='doctoravailability',
            options={'ordering': ['day_of_week', 'start_time'], 'verbose_name_plural': 'Doctor Availabilities'},
        ),
    ]
