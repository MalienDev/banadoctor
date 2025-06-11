import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';
import '../../domain/models/user_model.dart';
import 'auth_remote_data_source.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient _dioClient;

  AuthRemoteDataSourceImpl({required DioClient dioClient}) 
    : _dioClient = dioClient;

  @override
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _dioClient.dio.post(
      '/auth/login',
      data: {
        'email': email,
        'password': password,
      },
    );
    
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phoneNumber,
    required String role,
  }) async {
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
    
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<void> logout() async {
    await _dioClient.dio.post('/auth/logout');
  }

  @override
  Future<Map<String, dynamic>> getCurrentUser() async {
    final response = await _dioClient.dio.get('/auth/me');
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<void> forgotPassword(String email) async {
    await _dioClient.dio.post(
      '/auth/forgot-password',
      data: {'email': email},
    );
  }

  @override
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    await _dioClient.dio.post(
      '/auth/reset-password',
      data: {
        'token': token,
        'newPassword': newPassword,
      },
    );
  }

  @override
  Future<Map<String, dynamic>> updateProfile({
    required String userId,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? profileImageUrl,
  }) async {
    final data = <String, dynamic>{};
    if (firstName != null) data['firstName'] = firstName;
    if (lastName != null) data['lastName'] = lastName;
    if (phoneNumber != null) data['phoneNumber'] = phoneNumber;
    if (profileImageUrl != null) data['profileImageUrl'] = profileImageUrl;

    final response = await _dioClient.dio.patch(
      '/users/$userId',
      data: data,
    );
    
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _dioClient.dio.post(
      '/auth/change-password',
      data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    );
  }

  @override
  Future<void> verifyEmail(String token) async {
    await _dioClient.dio.post(
      '/auth/verify-email',
      data: {'token': token},
    );
  }

  @override
  Future<void> verifyPhone(String code) async {
    await _dioClient.dio.post(
      '/auth/verify-phone',
      data: {'code': code},
    );
  }
}
