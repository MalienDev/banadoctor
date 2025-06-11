import 'package:dio/dio.dart';

import '../../domain/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  });
  
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phoneNumber,
    required String role,
  });
  
  Future<void> logout();
  
  Future<Map<String, dynamic>> getCurrentUser();
  
  Future<void> forgotPassword(String email);
  
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  });
  
  Future<Map<String, dynamic>> updateProfile({
    required String userId,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? profileImageUrl,
  });
  
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
  
  Future<void> verifyEmail(String token);
  
  Future<void> verifyPhone(String code);
}
