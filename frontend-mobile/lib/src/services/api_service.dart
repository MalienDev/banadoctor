import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:medecin_mobile/src/models/user_model.dart';
import 'package:medecin_mobile/src/models/appointment_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const String baseUrl = 'https://your-api-url.com/api';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Add auth token to headers
  Future<void> _addAuthToken() async {
    final token = await _storage.read(key: 'auth_token');
    if (token != null) {
      _headers['Authorization'] = 'Bearer $token';
    }
  }

  // Handle API response
  dynamic _handleResponse(http.Response response) {
    final responseData = json.decode(utf8.decode(response.bodyBytes));
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return responseData;
    } else {
      throw Exception(responseData['message'] ?? 'Une erreur est survenue');
    }
  }

  // Authentication
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login/'),
      headers: _headers,
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );

    final responseData = _handleResponse(response);
    await _storage.write(key: 'auth_token', value: responseData['token']);
    await _storage.write(key: 'user_type', value: responseData['user_type']);
    
    return responseData;
  }

  // User Registration
  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register/'),
      headers: _headers,
      body: json.encode(userData),
    );

    return _handleResponse(response);
  }

  // Get current user profile
  Future<User> getCurrentUser() async {
    await _addAuthToken();
    final response = await http.get(
      Uri.parse('$baseUrl/auth/me/'),
      headers: _headers,
    );

    final responseData = _handleResponse(response);
    return User.fromJson(responseData);
  }

  // Search doctors
  Future<List<User>> searchDoctors({String? query, double? lat, double? lng}) async {
    await _addAuthToken();
    final uri = Uri.parse('$baseUrl/search/doctors/')
        .replace(queryParameters: {
      if (query != null) 'q': query,
      if (lat != null) 'lat': lat.toString(),
      if (lng != null) 'lng': lng.toString(),
    });

    final response = await http.get(uri, headers: _headers);
    final responseData = _handleResponse(response);
    
    return (responseData as List).map((json) => User.fromJson(json)).toList();
  }

  // Get doctor details
  Future<User> getDoctorDetails(int doctorId) async {
    await _addAuthToken();
    final response = await http.get(
      Uri.parse('$baseUrl/doctors/$doctorId/'),
      headers: _headers,
    );

    final responseData = _handleResponse(response);
    return User.fromJson(responseData);
  }

  // Book appointment
  Future<Appointment> bookAppointment({
    required int doctorId,
    required DateTime date,
    required String timeSlot,
    String? reason,
  }) async {
    await _addAuthToken();
    
    final response = await http.post(
      Uri.parse('$baseUrl/appointments/'),
      headers: _headers,
      body: json.encode({
        'doctor': doctorId,
        'appointment_date': date.toIso8601String().split('T')[0],
        'time_slot': timeSlot,
        'reason': reason,
      }),
    );

    final responseData = _handleResponse(response);
    return Appointment.fromJson(responseData);
  }

  // Get user appointments
  Future<List<Appointment>> getUserAppointments() async {
    await _addAuthToken();
    final response = await http.get(
      Uri.parse('$baseUrl/appointments/'),
      headers: _headers,
    );

    final responseData = _handleResponse(response);
    return (responseData as List).map((json) => Appointment.fromJson(json)).toList();
  }

  // Update appointment status
  Future<Appointment> updateAppointmentStatus(int appointmentId, String status) async {
    await _addAuthToken();
    final response = await http.patch(
      Uri.parse('$baseUrl/appointments/$appointmentId/'),
      headers: _headers,
      body: json.encode({'status': status}),
    );

    final responseData = _handleResponse(response);
    return Appointment.fromJson(responseData);
  }

  // Logout
  Future<void> logout() async {
    await _addAuthToken();
    try {
      await http.post(
        Uri.parse('$baseUrl/auth/logout/'),
        headers: _headers,
      );
    } finally {
      await _storage.deleteAll();
    }
  }
}
