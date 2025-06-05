# Application Mobile BanaDoctor

Application mobile développée avec Flutter pour la plateforme BanaDoctor.

## 📱 Prérequis

- Flutter 3.7.0 ou supérieur
- Dart 3.0.0 ou supérieur
- Android Studio / Xcode (pour le développement natif)
- Compte Firebase (pour les notifications et l'authentification)
- Compte Google Play (pour Android)
- Compte Apple Developer (pour iOS)

## 🚀 Configuration initiale

### 1. Cloner le dépôt
```bash
git clone https://github.com/votre-org/banadoctor.git
cd banadoctor/frontend-mobile
```

### 2. Installer les dépendances
```bash
flutter pub get
```

### 3. Configurer les variables d'environnement
Créer un fichier `.env` à la racine du projet :
```env
# Configuration API
API_BASE_URL=https://api.banadoctor.com

# Configuration Firebase (Android)
FIREBASE_ANDROID_API_KEY=your_android_api_key
FIREBASE_ANDROID_APP_ID=your_android_app_id
FIREBASE_ANDROID_MESSAGING_SENDER_ID=your_messaging_sender_id
FIREBASE_ANDROID_PROJECT_ID=your_project_id
FIREBASE_ANDROID_STORAGE_BUCKET=your_storage_bucket

# Configuration Firebase (iOS)
FIREBASE_IOS_API_KEY=your_ios_api_key
FIREBASE_IOS_APP_ID=your_ios_app_id
FIREBASE_IOS_MESSAGING_SENDER_ID=your_messaging_sender_id
FIREBASE_IOS_PROJECT_ID=your_project_id
FIREBASE_IOS_STORAGE_BUCKET=your_storage_bucket
FIREBASE_IOS_CLIENT_ID=your_client_id
FIREBASE_IOS_BUNDLE_ID=com.banadoctor.app

# Autres configurations
MAPS_API_KEY=your_google_maps_api_key
```

## 🛠 Configuration de Firebase

### 1. Créer un projet Firebase
1. Allez sur la [console Firebase](https://console.firebase.google.com/)
2. Créez un nouveau projet ou sélectionnez un projet existant
3. Ajoutez une application Android et/ou iOS selon vos besoins

### 2. Télécharger les fichiers de configuration
- Pour Android : `google-services.json` (à placer dans `android/app/`)
- Pour iOS : `GoogleService-Info.plist` (à ajouter à Xcode)

### 3. Activer les services nécessaires
- Authentication (Email/Password, Google, Apple, etc.)
- Cloud Firestore
- Cloud Storage
- Cloud Messaging (pour les notifications push)

## 🏃‍♂️ Exécution de l'application

### Mode développement
```bash
# Démarrer l'application sur un appareil connecté ou un émulateur
flutter run

# Pour un appareil spécifique
flutter run -d <device_id>

# Pour le mode profil (performance)
flutter run --profile
```

### Génération des builds

#### Android
```bash
# Build d'APK
flutter build apk --release

# Build d'App Bundle (pour le Play Store)
flutter build appbundle --release
```

#### iOS
```bash
# Ouvrir le projet dans Xcode
open ios/Runner.xcworkspace

# Dans Xcode :
# 1. Configurer les certificats de signature
# 2. Sélectionner l'équipe de développement
# 3. Archiver et exporter l'application
```

## 🏗 Structure du projet

```
lib/
├── core/                  # Code de base et utilitaires
│   ├── constants/         # Constantes de l'application
│   ├── errors/            # Gestion des erreurs
│   ├── network/           # Gestion des appels réseau
│   └── utils/             # Utilitaires divers
├── data/                  # Couche données
│   ├── datasources/       # Sources de données (API, local)
│   ├── models/           # Modèles de données
│   └── repositories/      # Implémentations des repositories
├── domain/                # Logique métier
│   ├── entities/         # Entités du domaine
│   ├── repositories/     # Interfaces des repositories
│   └── usecases/         # Cas d'utilisation
├── presentation/          # Interface utilisateur
│   ├── bloc/             # Gestion d'état avec BLoC
│   ├── pages/            # Écrans de l'application
│   ├── widgets/          # Widgets réutilisables
│   └── app.dart         # Configuration de l'application
└── main.dart             # Point d'entrée de l'application
```

## 🔒 Configuration des clés API

### Google Maps
1. Activez l'API Google Maps pour Android/iOS
2. Créez une clé API avec les restrictions appropriées
3. Ajoutez la clé dans le fichier `.env`

### Autres services
Suivez les mêmes étapes pour les autres services (Stripe, Sentry, etc.)

## 🧪 Tests

### Exécuter tous les tests
```bash
flutter test
```

### Exécuter les tests avec couverture
```bash
# Générer le rapport de couverture
flutter test --coverage

# Générer un rapport HTML (nécessite lcov)
genhtml coverage/lcov.info -o coverage/html
```

## 🚀 Déploiement

### Google Play Store
1. Créez une clé de téléchargement :
   ```bash
   keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
2. Configurez `key.properties` dans `android/`
3. Mettez à jour `android/app/build.gradle`
4. Créez un bundle de version :
   ```bash
   flutter build appbundle --release
   ```
5. Téléchargez sur le Play Console

### App Store Connect
1. Configurez les certificats et les profils de provisionnement dans Xcode
2. Archivez l'application depuis Xcode
3. Téléchargez sur App Store Connect via Organizer

## 📱 Fonctionnalités clés

- Authentification sécurisée
- Prise de rendez-vous en temps réel
- Messagerie entre patients et médecins
- Rappels de rendez-vous
- Paiements intégrés
- Stockage sécurisé des dossiers médicaux
- Notifications push

## 🤝 Contribution

1. Créez une branche pour votre fonctionnalité :
   ```bash
   git checkout -b feature/nouvelle-fonctionnalite
   ```
2. Faites vos modifications et committez :
   ```bash
   git commit -m "Ajouter une nouvelle fonctionnalité"
   ```
3. Poussez vers la branche :
   ```bash
   git push origin feature/nouvelle-fonctionnalite
   ```
4. Créez une Pull Request

## 📄 Licence

[LICENSE](LICENSE)
