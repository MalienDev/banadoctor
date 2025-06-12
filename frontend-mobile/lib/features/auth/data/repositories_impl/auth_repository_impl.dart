import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../datasources/auth_remote_data_source.dart';
import '../../domain/models/user_model.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final SharedPreferences _sharedPreferences;
  final FlutterSecureStorage _secureStorage;
  final Logger _logger;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required SharedPreferences sharedPreferences,
    required FlutterSecureStorage secureStorage,
    required Logger logger,
  })  : _remoteDataSource = remoteDataSource,
        _sharedPreferences = sharedPreferences,
        _secureStorage = secureStorage,
        _logger = logger;

  @override
  Future<Either<Failure, User>> checkAuthStatus() async {
    try {
      final accessToken = await _secureStorage.read(key: 'access_token');
      if (accessToken == null) {
        _logger.i('No access token found in storage.');
        return left(CacheFailure('No access token found'));
      }

      final userModel = await _remoteDataSource.getUserProfile();
      await _saveUser(userModel);
      _logger.i('Auth status check successful for user: ${userModel.email}');
      return right(userModel);
    } on ServerException catch (e) {
      _logger.w('Auth status check failed, logging out. Reason: ${e.message}');
      await logout();
      return left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      _logger.e('Unexpected auth status check error', error: e, stackTrace: stackTrace);
      await logout();
      return left(ServerFailure('An unexpected error occurred during auth check.'));
    }
  }

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _remoteDataSource.login(email: email, password: password);
      
      final user = User.fromJson(response['user']);
      final accessToken = response['access'] as String;
      final refreshToken = response['refresh'] as String;

      await _saveTokens(accessToken, refreshToken);
      await _saveUser(user);

      return right(user);
    } on ServerException catch (e) {
      _logger.e('Login ServerException: ${e.message}');
      return left(ServerFailure(e.message));
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
      final response = await _remoteDataSource.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        role: role,
      );

      final user = User.fromJson(response['user']);
      final accessToken = response['access'] as String;
      final refreshToken = response['refresh'] as String;

      await _saveTokens(accessToken, refreshToken);
      await _saveUser(user);

      return right(user);
    } on ServerException catch (e) {
      _logger.e('Registration ServerException: ${e.message}');
      return left(ServerFailure(e.message));
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
      await _remoteDataSource.forgotPassword(email);
      return right(null);
    } on ServerException catch (e) {
      _logger.e('Forgot password error: ${e.message}');
      return left(ServerFailure(e.message));
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
      await _remoteDataSource.resetPassword(token: token, newPassword: newPassword);
      return right(null);
    } on ServerException catch (e) {
      _logger.e('Reset password error: ${e.message}');
      return left(ServerFailure(e.message));
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
      final response = await _remoteDataSource.updateProfile(
        userId: userId,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        profileImageUrl: profileImageUrl,
      );
      final user = User.fromJson(response);
      await _saveUser(user);
      return right(null);
    } on ServerException catch (e) {
      _logger.e('Update profile error: ${e.message}');
      return left(ServerFailure(e.message));
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
      await _remoteDataSource.changePassword(currentPassword: currentPassword, newPassword: newPassword);
      return right(null);
    } on ServerException catch (e) {
      _logger.e('Change password error: ${e.message}');
      return left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      _logger.e('Unexpected change password error', error: e, stackTrace: stackTrace);
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> verifyEmail(String token) async {
    try {
      await _remoteDataSource.verifyEmail(token);
      return right(null);
    } on ServerException catch (e) {
      _logger.e('Verify email error: ${e.message}');
      return left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      _logger.e('Unexpected verify email error', error: e, stackTrace: stackTrace);
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> verifyPhone(String code) async {
    try {
      await _remoteDataSource.verifyPhone(code);
      return right(null);
    } on ServerException catch (e) {
      _logger.e('Verify phone error: ${e.message}');
      return left(ServerFailure(e.message));
    } catch (e, stackTrace) {
      _logger.e('Unexpected verify phone error', error: e, stackTrace: stackTrace);
      return left(ServerFailure(e.toString()));
    }
  }

  // Helper methods
  Future<void> _saveTokens(String accessToken, String refreshToken) async {
    await _secureStorage.write(key: 'access_token', value: accessToken);
    await _secureStorage.write(key: 'refresh_token', value: refreshToken);
  }

  Future<void> _saveUser(User user) async {
    await _sharedPreferences.setString(
      'user',
      json.encode(user.toJson()),
    );
  }
}
