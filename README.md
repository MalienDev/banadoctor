# BanaDoctor - Plateforme de Santé Connectée

## 📋 Présentation du projet
BanaDoctor est une plateforme SaaS innovante dédiée à la gestion des rendez-vous médicaux et au suivi des patients. Notre solution connecte les professionnels de santé avec leurs patients, facilitant la prise de rendez-vous, la gestion des dossiers médicaux et le suivi des traitements.

## 🎯 Objectifs
- Simplifier la prise de rendez-vous médicaux
- Centraliser les dossiers médicaux des patients
- Faciliter la communication entre professionnels de santé et patients
- Assurer la sécurité et la confidentialité des données de santé

## 🛠️ Stack Technique

### Backend
- **API REST** : Django REST Framework
- **Base de données** : PostgreSQL
- **Cache** : Redis
- **File d'attente** : Celery avec Redis
- **Authentification** : JWT, OAuth2

### Frontend Web
- **Framework** : Next.js 13+ avec App Router
- **Langage** : TypeScript
- **UI/UX** : Tailwind CSS, Shadcn/UI
- **State Management** : React Query, Zustand

### Mobile (Flutter)
- **Framework** : Flutter 3.x
- **State Management** : Riverpod
- **Local Storage** : Hive
- **Maps** : Google Maps/Mapbox

### Infrastructure
- **Conteneurisation** : Docker, Docker Compose
- **Orchestration** : Kubernetes
- **CI/CD** : GitHub Actions
- **Monitoring** : Prometheus, Grafana, Loki
- **Logging** : ELK Stack
- **Tracing** : Jaeger, OpenTelemetry

## 🚀 Prérequis

### Outils de développement
- **Docker** : 20.10+
- **Docker Compose** : 2.15.0+
- **kubectl** : 1.25+
- **Helm** : 3.10+ (pour le déploiement Kubernetes)
- **Git** : 2.30+

### Environnements
- **Backend** : Python 3.10+
- **Frontend Web** : Node.js 18+, npm 9+/yarn 1.22+
- **Mobile** : Flutter 3.7+, Android Studio/Xcode

## 🏃‍♂️ Démarrage rapide

### Avec Docker Compose (développement)

```bash
# Cloner le dépôt
git clone https://github.com/votre-org/banadoctor.git
cd banadoctor

# Copier et configurer les variables d'environnement
cp .env.example .env
# Éditer le fichier .env selon vos besoins

# Démarrer les services
docker-compose up -d

# Appliquer les migrations (dans un nouveau terminal)
docker-compose exec backend python manage.py migrate

# Créer un superutilisateur
docker-compose exec backend python manage.py createsuperuser

# L'application sera disponible à :
# - Frontend Web : http://localhost:3000
# - Backend API : http://localhost:8000
# - Admin Django : http://localhost:8000/admin
```

## 🚀 Déploiement

### Environnements
- **Staging** : `kubectl apply -f k8s/staging/`
- **Production** : `kubectl apply -f k8s/production/`

### Configuration Kubernetes
Assurez-vous d'avoir configuré votre contexte Kubernetes et d'avoir les droits nécessaires :

```bash
# Vérifier le contexte actuel
kubectl config current-context

# Vérifier les droits
kubectl auth can-i create deployments
kubectl auth can-i create services

# Appliquer la configuration pour l'environnement de staging
kubectl config use-context staging-cluster
kubectl apply -f k8s/staging/

# Pour la production
kubectl config use-context production-cluster
kubectl apply -f k8s/production/
```

## 📚 Documentation détaillée

- [Backend](/backend/README.md) - Documentation technique du backend Django
- [Frontend Web](/frontend-web/README.md) - Guide du développement frontend Next.js
- [Application Mobile](/frontend-mobile/README.md) - Documentation Flutter et déploiement mobile
- [Infrastructure](/infra/README.md) - Architecture et déploiement Kubernetes

## 📄 Licence
[LICENSE](LICENSE)
