import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dotenv/dotenv.dart';

import 'package:medecin_mobile/core/network/dio_client.dart';
import 'package:medecin_mobile/features/auth/providers/auth_module_provider.dart';
import 'package:medecin_mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:medecin_mobile/features/auth/presentation/screens/splash_auth_screen.dart';
import 'package:medecin_mobile/src/screens/auth/register_screen.dart';
import 'package:medecin_mobile/src/screens/dashboard_screen.dart';
import 'package:medecin_mobile/core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  final sharedPreferences = await SharedPreferences.getInstance();

  final dioClient = DioClient(
    baseUrl: dotenv.get('API_BASE_URL'),
    logLevel: dotenv.get('LOG_LEVEL', fallback: 'debug'),
  );

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        dioClientProvider.overrideWithValue(dioClient),
      ],
      child: const MyApp(),
    ),
  );
}

final _router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashAuthScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
  ],
);

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      routerConfig: _router,
      title: 'BanaDoctor',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
    );
  }
}
