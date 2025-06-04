import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

import '../models/user.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService;
  final FlutterSecureStorage _storage;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  
  AuthService({required ApiService apiService, required FlutterSecureStorage storage})
      : _apiService = apiService,
        _storage = storage;

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'auth_token');
    return token != null;
  }

  // Get current user type
  Future<String?> getUserType() async {
    return await _storage.read(key: 'user_type');
  }

  // Email & Password Authentication
  Future<User> loginWithEmailAndPassword(String email, String password) async {
    try {
      final response = await _apiService.login(email, password);
      return User.fromJson(response['user']);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String userType,
    String? phoneNumber,
  }) async {
    try {
      await _apiService.register({
        'email': email,
        'password': password,
        'first_name': firstName,
        'last_name': lastName,
        'user_type': userType,
        if (phoneNumber != null) 'phone_number': phoneNumber,
      });
    } catch (e) {
      rethrow;
    }
  }

  // Social Authentication
  Future<User> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw Exception('Google sign in was cancelled');

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with Google credentials
      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final firebaseUser = userCredential.user;
      
      if (firebaseUser == null) {
        throw Exception('Failed to sign in with Google');
      }

      // TODO: Call your backend API to register/login the user
      // This is a simplified example - adjust according to your backend
      final response = await _apiService.login(firebaseUser.email ?? '', '');
      return User.fromJson(response['user']);
    } catch (e) {
      rethrow;
    }
  }

  Future<User> signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      
      if (result.status != LoginStatus.success) {
        throw Exception('Facebook login failed');
      }

      final OAuthCredential credential = 
          FacebookAuthProvider.credential(result.accessToken!.token);
      
      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final firebaseUser = userCredential.user;
      
      if (firebaseUser == null) {
        throw Exception('Failed to sign in with Facebook');
      }

      // TODO: Call your backend API to register/login the user
      // This is a simplified example - adjust according to your backend
      final response = await _apiService.login(firebaseUser.email ?? '', '');
      return User.fromJson(response['user']);
    } catch (e) {
      rethrow;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      // Sign out from Firebase
      await _firebaseAuth.signOut();
      
      // Sign out from Google
      await _googleSignIn.signOut();
      
      // Sign out from Facebook
      await FacebookAuth.instance.logOut();
      
      // Clear secure storage
      await _storage.deleteAll();
    } catch (e) {
      rethrow;
    }
  }

  // Password Reset
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    }
  }

  // Token Management
  Future<String?> getAuthToken() async {
    return await _storage.read(key: 'auth_token');
  }

  Future<void> persistAuthToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  Future<void> deleteAuthToken() async {
    await _storage.delete(key: 'auth_token');
  }
}
