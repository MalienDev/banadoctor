# Backend BanaDoctor

## 🏗️ Structure du projet

```
backend/
├── apps/                   # Applications Django
│   ├── accounts/           # Gestion des utilisateurs et authentification
│   ├── appointments/       # Gestion des rendez-vous
│   ├── patients/           # Gestion des dossiers patients
│   └── ...
├── config/                # Configuration du projet Django
│   ├── settings/
│   │   ├── base.py
│   │   ├── development.py
│   │   └── production.py
│   ├── asgi.py
│   ├── urls.py
│   └── wsgi.py
├── manage.py
└── requirements/           # Dépendances Python
    ├── base.txt
    ├── development.txt
    └── production.txt
```

## 🚀 Configuration de l'environnement

### Prérequis
- Python 3.10+
- PostgreSQL 13+
- Redis 6.2+

### Installation

1. **Cloner le dépôt**
   ```bash
   git clone https://github.com/votre-org/banadoctor.git
   cd banadoctor/backend
   ```

2. **Créer et activer un environnement virtuel**
   ```bash
   python -m venv venv
   # Sur Windows
   .\venv\Scripts\activate
   # Sur macOS/Linux
   source venv/bin/activate
   ```

3. **Installer les dépendances**
   ```bash
   pip install -r requirements/development.txt
   ```

4. **Configurer les variables d'environnement**
   Créer un fichier `.env` à la racine du backend :
   ```env
   DEBUG=True
   SECRET_KEY=votre-secret-key
   DATABASE_URL=postgres://user:password@localhost:5432/banadoctor
   REDIS_URL=redis://localhost:6379/0
   ALLOWED_HOSTS=localhost,127.0.0.1
   CORS_ALLOWED_ORIGINS=http://localhost:3000,http://127.0.0.1:3000
   ```

## 🛠️ Commandes utiles

### Gestion des migrations
```bash
# Créer les migrations
python manage.py makemigrations

# Appliquer les migrations
python manage.py migrate

# Voir l'état des migrations
python manage.py showmigrations
```

### Gestion des utilisateurs
```bash
# Créer un superutilisateur
python manage.py createsuperuser

# Changer un mot de passe utilisateur
python manage.py changepassword <username>
```

### Données de test
```bash
# Charger les données initiales
python manage.py loaddata initial_data.json

# Créer des données de test
python manage.py create_test_data
```

### Lancer le serveur de développement
```bash
python manage.py runserver
```

## 🔒 Authentification

Le backend utilise JWT pour l'authentification. Les endpoints protégés nécessitent un token JWT valide dans le header `Authorization: Bearer <token>`.

### Obtenir un token JWT
```http
POST /api/token/
Content-Type: application/json

{
    "username": "votre_utilisateur",
    "password": "votre_mot_de_passe"
}
```

### Rafraîchir un token
```http
POST /api/token/refresh/
Content-Type: application/json

{
    "refresh": "votre_refresh_token"
}
```

## 🧪 Tests

### Lancer les tests
```bash
# Tous les tests
python manage.py test

# Tests spécifiques à une application
python manage.py test apps.accounts.tests

# Avec couverture de code
coverage run manage.py test
coverage report -m
```

## 🐳 Développement avec Docker

### Lancer les services
```bash
docker-compose up -d
```

### Exécuter des commandes dans le conteneur
```bash
docker-compose exec backend python manage.py migrate
docker-compose exec backend python manage.py createsuperuser
```

## 🚀 Déploiement

### Variables d'environnement de production
```env
DEBUG=False
SECRET_KEY=generer-une-cle-secrete-securisee
DATABASE_URL=postgres://user:password@db:5432/banadoctor_prod
REDIS_URL=redis://redis:6379/0
ALLOWED_HOSTS=.votredomaine.com,api.votredomaine.com
CORS_ALLOWED_ORIGINS=https://votredomaine.com,https://app.votredomaine.com
```

### Migrations en production
```bash
# Appliquer les migrations
python manage.py migrate --settings=config.settings.production

# Collecter les fichiers statiques
python manage.py collectstatic --noinput --settings=config.settings.production
```

## 📊 Monitoring et logs

- **Logs d'application** : Configurés pour sortir sur la sortie standard (capturés par Docker/Kubernetes)
- **Métriques** : Exposées sur `/metrics` pour Prometheus
- **Health checks** : `/health/` pour vérifier l'état de l'application

## 🤝 Contribution

1. Créer une branche pour votre fonctionnalité : `git checkout -b feature/nouvelle-fonctionnalite`
2. Faire un commit de vos changements : `git commit -m 'Ajouter une nouvelle fonctionnalité'`
3. Pousser vers la branche : `git push origin feature/nouvelle-fonctionnalite`
4. Créer une Pull Request

## 📄 Licence

[LICENSE](LICENSE)
