import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../core/config/app_config.dart';

class DioClient {
  final Dio dio;
  final Logger logger;
  final AppConfig config = AppConfig();

  DioClient({
    required this.dio,
    required this.logger,
  }) {
    // Configure base options
    final baseOptions = BaseOptions(
      baseUrl: config.apiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-API-KEY': config.apiKey,
      },
    );

    dio.options = baseOptions;

    // Add interceptors
    if (kDebugMode) {
      dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
          maxWidth: 90,
        ),
      );
    }

    // Add auth interceptor
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Add auth token if available
        // final token = await _getAuthToken();
        // if (token != null) {
        //   options.headers['Authorization'] = 'Bearer $token';
        // }
        return handler.next(options);
      },
      onError: (DioException error, handler) async {
        // Handle 401 Unauthorized
        if (error.response?.statusCode == 401) {
          // Handle token refresh or logout
          // await _handleUnauthorized(error, handler);
          return;
        }
        
        // Handle no internet connection
        final connectivityResult = await Connectivity().checkConnectivity();
        if (connectivityResult == ConnectivityResult.none) {
          error = error.copyWith(
            error: 'No internet connection',
            type: DioExceptionType.unknown,
          );
        }
        
        return handler.next(error);
      },
    ));
  }

  // Future<String?> _getAuthToken() async {
  //   // Get token from secure storage
  //   final token = await sl<FlutterSecureStorage>().read(key: 'auth_token');
  //   return token;
  // }


  // Future<void> _handleUnauthorized(
  //     DioException error, ErrorInterceptorHandler handler) async {
  //   // Implement token refresh logic here
  //   // If refresh fails, log out the user
  //   await sl<AuthProvider>().logout();
  //   handler.reject(error);
  // }


  // Add your API methods here
  // Example:
  // Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
  //   try {
  //     final response = await dio.get(path, queryParameters: queryParameters);
  //     return response;
  //   } on DioException catch (e) {
  //     logger.e('GET request failed: ${e.message}');
  //     rethrow;
  //   }
  // }
}
