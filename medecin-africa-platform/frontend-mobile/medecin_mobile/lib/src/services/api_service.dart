import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:logger/logger.dart';

import '../models/user.dart';
import '../models/rendez_vous.dart';
import '../models/transaction.dart';

class ApiService {
  static const String baseUrl = 'https://api.medecinafrica.com/v1';
  final http.Client client;
  final FlutterSecureStorage storage;
  final Logger logger = Logger();

  ApiService({required this.client, required this.storage});

  // Helper method to get auth headers
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await storage.read(key: 'auth_token');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Handle API response
  dynamic _handleResponse(http.Response response) {
    final responseData = json.decode(utf8.decode(response.bodyBytes));
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return responseData;
    } else {
      final errorMsg = responseData['message'] ?? 'Une erreur est survenue';
      throw Exception(errorMsg);
    }
  }

  // Authentication
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await client.post(
      Uri.parse('$baseUrl/auth/login/'),
      body: json.encode({
        'email': email,
        'password': password,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    final responseData = _handleResponse(response);
    
    // Store the token and user data
    await storage.write(key: 'auth_token', value: responseData['token']);
    await storage.write(key: 'user_type', value: responseData['user']['user_type']);
    
    return responseData;
  }

  Future<void> register(Map<String, dynamic> userData) async {
    final response = await client.post(
      Uri.parse('$baseUrl/auth/register/'),
      body: json.encode(userData),
      headers: {'Content-Type': 'application/json'},
    );
    
    _handleResponse(response);
  }

  // Doctors
  Future<List<User>> searchDoctors({
    String? query,
    double? lat,
    double? lng,
    String? speciality,
  }) async {
    final uri = Uri.parse('$baseUrl/search/doctors/').replace(
      queryParameters: {
        if (query != null) 'q': query,
        if (lat != null) 'lat': lat.toString(),
        if (lng != null) 'lng': lng.toString(),
        if (speciality != null) 'speciality': speciality,
      },
    );

    final response = await client.get(
      uri,
      headers: await _getAuthHeaders(),
    );

    final responseData = _handleResponse(response);
    return (responseData['results'] as List)
        .map((json) => User.fromJson(json))
        .toList();
  }

  Future<User> getDoctorProfile(String doctorId) async {
    final response = await client.get(
      Uri.parse('$baseUrl/doctors/$doctorId/'),
      headers: await _getAuthHeaders(),
    );

    return User.fromJson(_handleResponse(response));
  }

  // Appointments
  Future<RendezVous> bookAppointment({
    required String doctorId,
    required DateTime startTime,
    required String reason,
    String? notes,
  }) async {
    final response = await client.post(
      Uri.parse('$baseUrl/appointments/'),
      headers: await _getAuthHeaders(),
      body: json.encode({
        'doctor_id': doctorId,
        'start_time': startTime.toIso8601String(),
        'reason': reason,
        if (notes != null) 'notes': notes,
      }),
    );

    return RendezVous.fromJson(_handleResponse(response));
  }

  Future<List<RendezVous>> getUpcomingAppointments() async {
    final response = await client.get(
      Uri.parse('$baseUrl/appointments/upcoming/'),
      headers: await _getAuthHeaders(),
    );

    final responseData = _handleResponse(response);
    return (responseData['results'] as List)
        .map((json) => RendezVous.fromJson(json))
        .toList();
  }

  // Payments
  Future<Map<String, dynamic>> initiatePayment({
    required double amount,
    required String reference,
    String? email,
    String? phone,
  }) async {
    final response = await client.post(
      Uri.parse('$baseUrl/payments/initiate/'),
      headers: await _getAuthHeaders(),
      body: json.encode({
        'amount': amount,
        'reference': reference,
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
      }),
    );

    return _handleResponse(response);
  }

  Future<Transaction> verifyPayment(String reference) async {
    final response = await client.get(
      Uri.parse('$baseUrl/payments/verify/$reference/'),
      headers: await _getAuthHeaders(),
    );

    return Transaction.fromJson(_handleResponse(response));
  }

  // Notifications
  Future<void> registerDeviceToken(String token, String deviceId) async {
    await client.post(
      Uri.parse('$baseUrl/notifications/register-device/'),
      headers: await _getAuthHeaders(),
      body: json.encode({
        'registration_id': token,
        'device_id': deviceId,
        'type': 'android', // or 'ios' based on platform
      }),
    );
  }
}

// HTTP Interceptor for adding auth token to requests
class AuthInterceptor implements InterceptorContract {
  final FlutterSecureStorage storage;

  AuthInterceptor(this.storage);

  @override
  Future<RequestData> interceptRequest({required RequestData data}) async {
    try {
      final token = await storage.read(key: 'auth_token');
      if (token != null) {
        data.headers['Authorization'] = 'Bearer $token';
      }
    } catch (e) {
      print('Error in AuthInterceptor: $e');
    }
    return data;
  }

  @override
  Future<ResponseData> interceptResponse({required ResponseData data}) async {
    return data;
  }
}
