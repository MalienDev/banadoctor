import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

// Screens
import 'src/screens/login_screen.dart';
import 'src/screens/register_screen.dart';
import 'src/screens/dashboard_patient.dart';
import 'src/screens/dashboard_medecin.dart';

// Services
import 'src/services/auth_service.dart';

// Providers
import 'src/providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Initialize secure storage
  const storage = FlutterSecureStorage();
  
  // Check for existing token
  final token = await storage.read(key: 'auth_token');
  final userType = await storage.read(key: 'user_type');
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            authService: AuthService(),
            storage: const FlutterSecureStorage(),
          ),
        ),
      ],
      child: const MedecinAfricaApp(),
    ),
  );
}

class MedecinAfricaApp extends StatelessWidget {
  const MedecinAfricaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Médecin Africa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32),
          primary: const Color(0xFF2E7D32),
          secondary: const Color(0xFF8BC34A),
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2E7D32),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          if (authProvider.isLoading) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          
          if (authProvider.isAuthenticated) {
            return authProvider.userType == 'doctor' 
                ? const DashboardMedecin() 
                : const DashboardPatient();
          }
          
          return const LoginScreen();
        },
      ),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/patient/dashboard': (context) => const DashboardPatient(),
        '/doctor/dashboard': (context) => const DashboardMedecin(),
      },
    );
  }
}
