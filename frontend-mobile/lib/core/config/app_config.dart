import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  // Private constructor
  AppConfig._();

  // Singleton instance
  static final AppConfig _instance = AppConfig._();
  
  // Factory constructor to return the same instance
  factory AppConfig() => _instance;

  // Initialize the configuration
  static Future<void> initialize() async {
    await dotenv.load(fileName: ".env");
  }

  // API Configuration
  String get apiBaseUrl => dotenv.get('API_BASE_URL');
  String get apiKey => dotenv.get('API_KEY');

  // Firebase Configuration
  String get firebaseApiKey => dotenv.get('FIREBASE_API_KEY');
  String get firebaseAuthDomain => dotenv.get('FIREBASE_AUTH_DOMAIN');
  String get firebaseProjectId => dotenv.get('FIREBASE_PROJECT_ID');
  String get firebaseStorageBucket => dotenv.get('FIREBASE_STORAGE_BUCKET');
  String get firebaseMessagingSenderId => dotenv.get('FIREBASE_MESSAGING_SENDER_ID');
  String get firebaseAppId => dotenv.get('FIREBASE_APP_ID');
  String get firebaseMeasurementId => dotenv.get('FIREBASE_MEASUREMENT_ID');

  // App Configuration
  String get appName => dotenv.get('APP_NAME');
  String get appVersion => dotenv.get('APP_VERSION');
  String get environment => dotenv.get('ENVIRONMENT');

  // Logging
  bool get enableLogging => dotenv.get('ENABLE_LOGGING') == 'true';
  String get logLevel => dotenv.get('LOG_LEVEL');

  // Feature Flags
  bool get enableAnalytics => dotenv.get('ENABLE_ANALYTICS') == 'true';
  bool get enableCrashlytics => dotenv.get('ENABLE_CRASHLYTICS') == 'true';

  // Other
  String get defaultLocale => dotenv.get('DEFAULT_LOCALE');
  List<String> get supportedLocales => dotenv.get('SUPPORTED_LOCALES').split(',');

  // Check if in development mode
  bool get isDevelopment => environment == 'development';
  bool get isProduction => environment == 'production';
  bool get isStaging => environment == 'staging';
}
