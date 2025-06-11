import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../core/config/app_config.dart';
import '../../core/network/dio_client.dart';
import '../../features/auth/data/datasources/auth_local_data_source.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories_impl/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

final GetIt sl = GetIt.instance;

Future<void> init() async {
  // External
  await _initExternalDependencies();
  
  // Core
  _initCoreDependencies();
  
  // Features - Auth
  _initAuthDependencies();
  
  // Features - Home
  _initHomeDependencies();
  
  // Features - Profile
  _initProfileDependencies();
  
  // Features - Appointments
  _initAppointmentDependencies();
}

Future<void> _initExternalDependencies() async {
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  
  // Initialize Secure Storage
  const secureStorage = FlutterSecureStorage();
  sl.registerLazySingleton<FlutterSecureStorage>(() => secureStorage);
  
  // Initialize Logger
  sl.registerLazySingleton<Logger>(
    () => Logger(
      printer: PrettyPrinter(
        methodCount: 0,
        errorMethodCount: 5,
        lineLength: 50,
        colors: true,
        printEmojis: true,
      ),
    ),
  );
}

void _initCoreDependencies() {
  // Dio Client
  sl.registerLazySingleton<DioClient>(
    () => DioClient(
      dio: Dio(),
      logger: sl<Logger>(),
    ),
  );
  
  // App Config
  sl.registerLazySingleton<AppConfig>(
    () => AppConfig(),
  );
}

void _initAuthDependencies() {
  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dioClient: sl()),
  );
  
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(
      sharedPreferences: sl(),
      secureStorage: sl(),
    ),
  );
  
  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      logger: sl(),
    ),
  );
  
  // Use cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  
  // Providers
  sl.registerFactory(
    () => AuthProvider(
      loginUseCase: sl(),
      logger: sl(),
    ),
  );
}

void _initHomeDependencies() {
  // Will be implemented when needed
}

void _initProfileDependencies() {
  // Will be implemented when needed
}

void _initAppointmentDependencies() {
  // Will be implemented when needed
}
