from .settings import *  # noqa

# Désactive uniquement les fonctionnalités GIS pour le développement local
if 'django.contrib.gis' in INSTALLED_APPS:
    INSTALLED_APPS.remove('django.contrib.gis')

# Configuration de base de données SQLite pour le développement
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': BASE_DIR / 'db.sqlite3',
    }
}

# Use in-memory cache for local development
CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.locmem.LocMemCache',
        'LOCATION': 'unique-snowflake', # Can be any unique string
    }
}

# Assurez-vous que les applications personnalisées sont bien dans INSTALLED_APPS
CUSTOM_APPS = [
    'users',
    'appointments',
    'notifications',
    'payments',
    'search',
]

for app in CUSTOM_APPS:
    if app not in INSTALLED_APPS:
        INSTALLED_APPS.append(app)
