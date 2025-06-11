import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final DioClient _dioClient;
  final SharedPreferences _sharedPreferences;
  final FlutterSecureStorage _secureStorage;
  final Logger _logger;

  AuthRepositoryImpl({
    required DioClient dioClient,
    required SharedPreferences sharedPreferences,
    required FlutterSecureStorage secureStorage,
    required Logger logger,
  })  : _dioClient = dioClient,
        _sharedPreferences = sharedPreferences,
        _secureStorage = secureStorage,
        _logger = logger;

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      final user = User.fromJson(response.data['data']['user']);
      final token = response.data['data']['token'] as String;
      final refreshToken = response.data['data']['refreshToken'] as String;

      // Save tokens
      await _saveTokens(token, refreshToken);
      await _saveUser(user);

      return right(user);
    } on DioException catch (e) {
      _logger.e('Login error: ${e.message}');
      return left(ServerFailure.fromDioException(e));
    } catch (e, stackTrace) {
      _logger.e('Unexpected login error', error: e, stackTrace: stackTrace);
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phoneNumber,
    required String role,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        '/auth/register',
        data: {
          'email': email,
          'password': password,
          'firstName': firstName,
          'lastName': lastName,
          if (phoneNumber != null) 'phoneNumber': phoneNumber,
          'role': role,
        },
      );

      final user = User.fromJson(response.data['data']['user']);
      final token = response.data['data']['token'] as String;
      final refreshToken = response.data['data']['refreshToken'] as String;

      // Save tokens
      await _saveTokens(token, refreshToken);
      await _saveUser(user);

      return right(user);
    } on DioException catch (e) {
      _logger.e('Registration error: ${e.message}');
      return left(ServerFailure.fromDioException(e));
    } catch (e, stackTrace) {
      _logger.e('Unexpected registration error', error: e, stackTrace: stackTrace);
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      // Clear all auth data
      await _secureStorage.deleteAll();
      await _sharedPreferences.remove('user');
      
      return right(null);
    } catch (e, stackTrace) {
      _logger.e('Logout error', error: e, stackTrace: stackTrace);
      return left(CacheFailure('Failed to logout'));
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      final userJson = _sharedPreferences.getString('user');
      if (userJson == null) {
        return left(CacheFailure('No user found'));
      }
      
      final user = User.fromJson(json.decode(userJson) as Map<String, dynamic>);
      return right(user);
    } catch (e, stackTrace) {
      _logger.e('Get current user error', error: e, stackTrace: stackTrace);
      return left(CacheFailure('Failed to get current user'));
    }
  }

  @override
  Future<Either<Failure, void>> forgotPassword(String email) async {
    try {
      await _dioClient.dio.post(
        '/auth/forgot-password',
        data: {'email': email},
      );
      return right(null);
    } on DioException catch (e) {
      _logger.e('Forgot password error: ${e.message}');
      return left(ServerFailure.fromDioException(e));
    } catch (e, stackTrace) {
      _logger.e('Unexpected forgot password error', error: e, stackTrace: stackTrace);
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      await _dioClient.dio.post(
        '/auth/reset-password',
        data: {
          'token': token,
          'newPassword': newPassword,
        },
      );
      return right(null);
    } on DioException catch (e) {
      _logger.e('Reset password error: ${e.message}');
      return left(ServerFailure.fromDioException(e));
    } catch (e, stackTrace) {
      _logger.e('Unexpected reset password error', error: e, stackTrace: stackTrace);
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateProfile({
    required String userId,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? profileImageUrl,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (firstName != null) data['firstName'] = firstName;
      if (lastName != null) data['lastName'] = lastName;
      if (phoneNumber != null) data['phoneNumber'] = phoneNumber;
      if (profileImageUrl != null) data['profileImageUrl'] = profileImageUrl;

      final response = await _dioClient.dio.patch(
        '/users/$userId',
        data: data,
      );

      // Update local user data
      final user = User.fromJson(response.data['data']);
      await _saveUser(user);

      return right(null);
    } on DioException catch (e) {
      _logger.e('Update profile error: ${e.message}');
      return left(ServerFailure.fromDioException(e));
    } catch (e, stackTrace) {
      _logger.e('Unexpected update profile error', error: e, stackTrace: stackTrace);
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _dioClient.dio.post(
        '/auth/change-password',
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );
      return right(null);
    } on DioException catch (e) {
      _logger.e('Change password error: ${e.message}');
      return left(ServerFailure.fromDioException(e));
    } catch (e, stackTrace) {
      _logger.e('Unexpected change password error', error: e, stackTrace: stackTrace);
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> verifyEmail(String token) async {
    try {
      await _dioClient.dio.post(
        '/auth/verify-email',
        data: {'token': token},
      );
      return right(null);
    } on DioException catch (e) {
      _logger.e('Verify email error: ${e.message}');
      return left(ServerFailure.fromDioException(e));
    } catch (e, stackTrace) {
      _logger.e('Unexpected verify email error', error: e, stackTrace: stackTrace);
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> verifyPhone(String code) async {
    try {
      await _dioClient.dio.post(
        '/auth/verify-phone',
        data: {'code': code},
      );
      return right(null);
    } on DioException catch (e) {
      _logger.e('Verify phone error: ${e.message}');
      return left(ServerFailure.fromDioException(e));
    } catch (e, stackTrace) {
      _logger.e('Unexpected verify phone error', error: e, stackTrace: stackTrace);
      return left(ServerFailure(e.toString()));
    }
  }

  // Helper methods
  Future<void> _saveTokens(String token, String refreshToken) async {
    await _secureStorage.write(key: 'auth_token', value: token);
    await _secureStorage.write(key: 'refresh_token', value: refreshToken);
    
    // Update Dio headers
    _dioClient.dio.options.headers['Authorization'] = 'Bearer $token';
  }

  Future<void> _saveUser(User user) async {
    await _sharedPreferences.setString(
      'user',
      json.encode(user.toJson()),
    );
  }
}
