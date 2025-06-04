import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:medecin_mobile/src/models/user.dart';
import 'package:medecin_mobile/src/models/rendez_vous.dart';
import 'package:medecin_mobile/src/models/transaction.dart';
import 'package:medecin_mobile/src/routes/app_routes.dart';
import 'package:medecin_mobile/src/services/auth_service.dart';
import 'package:medecin_mobile/src/utils/constants.dart';
import 'package:medecin_mobile/src/utils/helpers.dart';

enum HttpMethod { get, post, put, patch, delete }

class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final int? statusCode;
  final dynamic rawResponse;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.statusCode,
    this.rawResponse,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json, 
    T Function(dynamic) fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      statusCode: json['statusCode'],
      rawResponse: json,
    );
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException(this.message, {this.statusCode, this.data});

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final String baseUrl = kApiBaseUrl;
  final Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Add authentication interceptor
  String? _token;
  String? get token => _token;

  // Set authentication token
  void setToken(String? token) {
    _token = token;
    if (token != null) {
      _headers['Authorization'] = 'Bearer $token';
    } else {
      _headers.remove('Authorization');
    }
  }

  // Main request method
  Future<dynamic> _request<T>({
    required HttpMethod method,
    required String endpoint,
    dynamic body,
    Map<String, String>? headers,
    bool requiresAuth = true,
    T Function(dynamic)? fromJsonT,
  }) async {
    try {
      // Add authentication header if required
      if (requiresAuth && _token == null) {
        throw ApiException('Authentication required', statusCode: 401);
      }

      // Prepare the request
      final url = Uri.parse('$baseUrl$endpoint');
      final requestHeaders = Map<String, String>.from(_headers);
      if (headers != null) {
        requestHeaders.addAll(headers);
      }

      http.Response response;

      // Make the request
      switch (method) {
        case HttpMethod.get:
          response = await http.get(url, headers: requestHeaders);
          break;
        case HttpMethod.post:
          response = await http.post(
            url,
            headers: requestHeaders,
            body: body is Map || body is List ? jsonEncode(body) : body,
          );
          break;
        case HttpMethod.put:
          response = await http.put(
            url,
            headers: requestHeaders,
            body: body is Map || body is List ? jsonEncode(body) : body,
          );
          break;
        case HttpMethod.patch:
          response = await http.patch(
            url,
            headers: requestHeaders,
            body: body is Map || body is List ? jsonEncode(body) : body,
          );
          break;
        case HttpMethod.delete:
          response = await http.delete(
            url,
            headers: requestHeaders,
            body: body is Map || body is List ? jsonEncode(body) : body,
          );
          break;
      }

      // Handle the response
      return _handleResponse<T>(response, fromJsonT: fromJsonT);
    } on SocketException {
      throw ApiException('No Internet connection');
    } on FormatException {
      throw ApiException('Bad response format');
    } on http.ClientException catch (e) {
      throw ApiException(e.message);
    } catch (e) {
      rethrow;
    }
  }

  // Handle API response
  dynamic _handleResponse<T>(
    http.Response response, {
    T Function(dynamic)? fromJsonT,
  }) {
    final statusCode = response.statusCode;
    final responseBody = response.body;

    try {
      final jsonResponse = jsonDecode(responseBody);

      // Handle successful responses (2xx)
      if (statusCode >= 200 && statusCode < 300) {
        if (fromJsonT != null) {
          return ApiResponse<T>.fromJson(jsonResponse, fromJsonT);
        }
        return jsonResponse;
      }

      // Handle error responses
      final errorMessage = jsonResponse['message'] ?? 'An error occurred';
      throw ApiException(
        errorMessage,
        statusCode: statusCode,
        data: jsonResponse,
      );
    } on FormatException {
      // Handle non-JSON response
      if (statusCode >= 200 && statusCode < 300) {
        return responseBody;
      }
      throw ApiException(
        'Invalid response format',
        statusCode: statusCode,
        data: responseBody,
      );
    }
  }

  // Authentication
  Future<User> login(String email, String password) async {
    final response = await _request(
      method: HttpMethod.post,
      endpoint: '/auth/login',
      body: {'email': email, 'password': password},
      requiresAuth: false,
      fromJsonT: (json) => User.fromJson(json),
    );
    return response.data;
  }

  Future<User> register(Map<String, dynamic> userData) async {
    final response = await _request(
      method: HttpMethod.post,
      endpoint: '/auth/register',
      body: userData,
      requiresAuth: false,
      fromJsonT: (json) => User.fromJson(json),
    );
    return response.data;
  }

  Future<void> logout() async {
    await _request(
      method: HttpMethod.post,
      endpoint: '/auth/logout',
    );
  }

  // User
  Future<User> getCurrentUser() async {
    final response = await _request(
      method: HttpMethod.get,
      endpoint: '/users/me',
      fromJsonT: (json) => User.fromJson(json),
    );
    return response.data;
  }

  Future<User> updateProfile(Map<String, dynamic> userData) async {
    final response = await _request(
      method: HttpMethod.put,
      endpoint: '/users/me',
      body: userData,
      fromJsonT: (json) => User.fromJson(json),
    );
    return response.data;
  }

  // Appointments
  Future<List<RendezVous>> getAppointments({String? status}) async {
    final endpoint = status != null 
        ? '/appointments?status=$status' 
        : '/appointments';
    
    final response = await _request(
      method: HttpMethod.get,
      endpoint: endpoint,
      fromJsonT: (json) => (json as List)
          .map((item) => RendezVous.fromJson(item))
          .toList(),
    );
    return response.data;
  }

  Future<RendezVous> getAppointment(String id) async {
    final response = await _request(
      method: HttpMethod.get,
      endpoint: '/appointments/$id',
      fromJsonT: (json) => RendezVous.fromJson(json),
    );
    return response.data;
  }

  Future<RendezVous> bookAppointment(Map<String, dynamic> appointmentData) async {
    final response = await _request(
      method: HttpMethod.post,
      endpoint: '/appointments',
      body: appointmentData,
      fromJsonT: (json) => RendezVous.fromJson(json),
    );
    return response.data;
  }

  Future<RendezVous> updateAppointment(
    String id, 
    Map<String, dynamic> updates,
  ) async {
    final response = await _request(
      method: HttpMethod.patch,
      endpoint: '/appointments/$id',
      body: updates,
      fromJsonT: (json) => RendezVous.fromJson(json),
    );
    return response.data;
  }

  Future<void> cancelAppointment(String id) async {
    await _request(
      method: HttpMethod.delete,
      endpoint: '/appointments/$id/cancel',
    );
  }

  // Transactions
  Future<List<Transaction>> getTransactions() async {
    final response = await _request(
      method: HttpMethod.get,
      endpoint: '/transactions',
      fromJsonT: (json) => (json as List)
          .map((item) => Transaction.fromJson(item))
          .toList(),
    );
    return response.data;
  }

  Future<Transaction> getTransaction(String id) async {
    final response = await _request(
      method: HttpMethod.get,
      endpoint: '/transactions/$id',
      fromJsonT: (json) => Transaction.fromJson(json),
    );
    return response.data;
  }

  // File Upload
  Future<String> uploadFile(File file, {String? fieldName}) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/upload'),
    );

    if (_token != null) {
      request.headers['Authorization'] = 'Bearer $_token';
    }

    request.files.add(await http.MultipartFile.fromPath(
      fieldName ?? 'file',
      file.path,
    ));

    final response = await request.send();
    final responseData = await response.stream.bytesToString();
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final jsonResponse = jsonDecode(responseData);
      return jsonResponse['url'] ?? jsonResponse['path'];
    } else {
      throw ApiException(
        'Failed to upload file',
        statusCode: response.statusCode,
        data: responseData,
      );
    }
  }

  // Error handling interceptor
  void _handleError(dynamic error, StackTrace stackTrace) {
    if (error is ApiException) {
      if (error.statusCode == 401) {
        // Handle unauthorized error (e.g., token expired)
        // You might want to log out the user here
        // AuthService().logout();
      }
      debugPrint('API Error: ${error.message}');
      debugPrint('Status Code: ${error.statusCode}');
      debugPrint('Response: ${error.data}');
    } else {
      debugPrint('Unexpected error: $error');
      debugPrint('Stack trace: $stackTrace');
    }
  }
}