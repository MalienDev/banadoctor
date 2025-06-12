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
      '/api/v1/auth/login/',
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
      '/api/v1/auth/register/',
      data: {
        'email': email,
        'password': password,
        'first_name': firstName,
        'last_name': lastName,
        if (phoneNumber != null) 'phone_number': phoneNumber,
        'role': role,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<void> logout() async {
    // Logout is handled client-side by clearing tokens.
    // No remote call is needed unless using a token blacklist.
    return Future.value();
  }

  @override
  Future<Map<String, dynamic>> getCurrentUser() async {
    final response = await _dioClient.dio.get('/api/v1/auth/profile/');
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<void> forgotPassword(String email) async {
    await _dioClient.dio.post(
      '/api/v1/auth/request-reset-email/',
      data: {'email': email},
    );
  }

  @override
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    // This implementation assumes 'token' contains both uidb64 and the token,
    // which might need adjustment based on how they are passed from the presentation layer.
    await _dioClient.dio.post(
      '/api/v1/auth/password-reset-complete/',
      data: {
        'token': token, // This likely needs to be split into uidb64 and token
        'password': newPassword,
      },
    );
  }

  @override
  Future<Map<String, dynamic>> updateProfile({
    required String userId, // Not needed for updating the current user's profile
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? profileImageUrl,
  }) async {
    final data = <String, dynamic>{};
    if (firstName != null) data['first_name'] = firstName;
    if (lastName != null) data['last_name'] = lastName;
    if (phoneNumber != null) data['phone_number'] = phoneNumber;
    // 'profileImageUrl' is not in the backend model, so it's ignored.

    final response = await _dioClient.dio.patch(
      '/api/v1/auth/profile/',
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
      '/api/v1/auth/change-password/',
      data: {
        'old_password': currentPassword,
        'new_password': newPassword,
      },
    );
  }

  @override
  Future<void> verifyEmail(String token) async {
    // This endpoint does not exist on the backend.
    throw UnimplementedError();
  }

  @override
  Future<void> verifyPhone(String code) async {
    // This endpoint does not exist on the backend.
    throw UnimplementedError();
  }
}
