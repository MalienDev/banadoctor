import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:uuid/uuid.dart';

import '../models/transaction.dart';
import 'api_service.dart';

class PaymentService {
  final ApiService _apiService;
  final FlutterSecureStorage _storage;
  final String _apiBaseUrl = 'https://api.medecinafrica.com/v1';
  final String _flutterwavePublicKey = 'YOUR_FLUTTERWAVE_PUBLIC_KEY';
  final String _paystackPublicKey = 'YOUR_PAYSTACK_PUBLIC_KEY';
  final String _currency = 'XOF'; // West African CFA franc

  PaymentService({
    required ApiService apiService,
    required FlutterSecureStorage storage,
  })  : _apiService = apiService,
        _storage = storage;

  // Initialize payment with Flutterwave
  Future<Map<String, dynamic>> initializeFlutterwavePayment({
    required double amount,
    required String email,
    String? phone,
    required String txRef,
    String? redirectUrl,
    bool isTestMode = true,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.flutterwave.com/v3/payments'),
        headers: {
          'Authorization': 'Bearer ${isTestMode ? 'FLWSECK_TEST-...' : _flutterwavePublicKey}',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'tx_ref': txRef,
          'amount': amount.toString(),
          'currency': _currency,
          'payment_options': 'card, mobilemoney',
          'redirect_url': redirectUrl ?? 'https://medecinafrica.com/payment/callback',
          'customer': {
            'email': email,
            if (phone != null) 'phone_number': phone,
            'name': 'Medecin Africa Customer',
          },
          'customizations': {
            'title': 'Medecin Africa',
            'description': 'Payment for medical consultation',
            'logo': 'https://medecinafrica.com/logo.png',
          },
        }),
      );

      final responseData = json.decode(response.body);
      
      if (response.statusCode == 200 && responseData['status'] == 'success') {
        return {
          'status': 'success',
          'paymentUrl': responseData['data']['link'],
          'transactionId': txRef,
        };
      } else {
        throw Exception(responseData['message'] ?? 'Failed to initialize payment');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Initialize payment with Paystack
  Future<Map<String, dynamic>> initializePaystackPayment({
    required double amount,
    required String email,
    String? phone,
    required String reference,
    bool isTestMode = true,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.paystack.co/transaction/initialize'),
        headers: {
          'Authorization': 'Bearer ${isTestMode ? 'sk_test_...' : _paystackPublicKey}',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'email': email,
          'amount': (amount * 100).toInt(), // Paystack uses kobo/pesewas
          'reference': reference,
          'currency': _currency,
          if (phone != null) 'mobile_money': {'phone': phone},
          'callback_url': 'https://medecinafrica.com/payment/callback',
          'metadata': {
            'custom_fields': [
              {
                'display_name': 'Service',
                'variable_name': 'service',
                'value': 'Medical Consultation',
              },
            ],
          },
        }),
      );

      final responseData = json.decode(response.body);
      
      if (response.statusCode == 200 && responseData['status'] == true) {
        return {
          'status': 'success',
          'authorizationUrl': responseData['data']['authorization_url'],
          'accessCode': responseData['data']['access_code'],
          'reference': reference,
        };
      } else {
        throw Exception(responseData['message'] ?? 'Failed to initialize payment');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Verify payment
  Future<bool> verifyPayment({
    required String transactionId,
    required String provider, // 'flutterwave' or 'paystack'
    bool isTestMode = true,
  }) async {
    try {
      if (provider == 'flutterwave') {
        final response = await http.get(
          Uri.parse('https://api.flutterwave.com/v3/transactions/$transactionId/verify'),
          headers: {
            'Authorization': 'Bearer ${isTestMode ? 'FLWSECK_TEST-...' : _flutterwavePublicKey}',
          },
        );

        final responseData = json.decode(response.body);
        return responseData['status'] == 'success' && 
               responseData['data']['status'] == 'successful';
      } else if (provider == 'paystack') {
        final response = await http.get(
          Uri.parse('https://api.paystack.co/transaction/verify/$transactionId'),
          headers: {
            'Authorization': 'Bearer ${isTestMode ? 'sk_test_...' : _paystackPublicKey}',
          },
        );

        final responseData = json.decode(response.body);
        return responseData['status'] == true && 
               responseData['data']['status'] == 'success';
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }

  // Launch payment URL in browser
  Future<void> launchPaymentUrl(String url) async {
    if (await canLaunchUrlString(url)) {
      await launchUrlString(
        url,
        mode: LaunchMode.externalApplication,
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  // Process appointment payment
  Future<Transaction> processAppointmentPayment({
    required String appointmentId,
    required double amount,
    required String email,
    String? phone,
    required String paymentMethod, // 'card', 'mobile_money', etc.
    String provider = 'flutterwave', // 'flutterwave' or 'paystack'
  }) async {
    try {
      // Generate a unique transaction reference
      final transactionRef = 'MED-${const Uuid().v4().substring(0, 8)}';
      
      // Initialize payment with the selected provider
      Map<String, dynamic> paymentInitResponse;
      
      if (provider == 'flutterwave') {
        paymentInitResponse = await initializeFlutterwavePayment(
          amount: amount,
          email: email,
          phone: phone,
          txRef: transactionRef,
          isTestMode: true, // Set to false in production
        );
        
        // Launch payment URL
        if (paymentInitResponse['status'] == 'success') {
          await launchPaymentUrl(paymentInitResponse['paymentUrl']);
        }
      } else if (provider == 'paystack') {
        paymentInitResponse = await initializePaystackPayment(
          amount: amount,
          email: email,
          phone: phone,
          reference: transactionRef,
          isTestMode: true, // Set to false in production
        );
        
        // Launch payment URL
        if (paymentInitResponse['status'] == 'success') {
          await launchPaymentUrl(paymentInitResponse['authorizationUrl']);
        }
      } else {
        throw Exception('Unsupported payment provider');
      }
      
      // In a real app, you would handle the payment verification via a webhook
      // or by checking the payment status after redirect
      
      // For demo purposes, we'll return a mock transaction
      return Transaction(
        id: transactionRef,
        reference: transactionRef,
        amount: amount,
        currency: _currency,
        status: TransactionStatus.pending,
        type: TransactionType.appointment,
        description: 'Payment for appointment #$appointmentId',
        paymentMethod: paymentMethod,
        paymentProvider: provider,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      rethrow;
    }
  }

  // Confirm payment with backend
  Future<void> confirmPayment({
    required String transactionId,
    required String provider,
  }) async {
    try {
      await _apiService.verifyPayment(transactionId);
      // The API will update the appointment status accordingly
    } catch (e) {
      rethrow;
    }
  }
}
