import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  final FlutterSecureStorage _storage;
  
  bool _isLoading = false;
  User? _currentUser;
  String? _userType;
  String? _authToken;
  
  // Getters
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _authToken != null;
  User? get currentUser => _currentUser;
  String? get userType => _userType;
  String? get authToken => _authToken;

  AuthProvider({
    required AuthService authService,
    required FlutterSecureStorage storage,
  })  : _authService = authService,
        _storage = storage {
    _loadUserData();
  }

  // Load user data from secure storage
  Future<void> _loadUserData() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _authToken = await _storage.read(key: 'auth_token');
      _userType = await _storage.read(key: 'user_type');
      
      // If we have a token, try to fetch the user profile
      if (_authToken != null) {
        // TODO: Fetch user profile from API
        // _currentUser = await _authService.getCurrentUser();
      }
    } catch (e) {
      // If there's an error, clear the auth state
      debugPrint('Error loading user data: $e');
      await _clearAuthData();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Login with email and password
  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _authService.loginWithEmailAndPassword(email, password);
      _currentUser = user;
      _userType = user.userType;
      _authToken = await _authService.getAuthToken();
      
      // Save auth data to secure storage
      await _storage.write(key: 'auth_token', value: _authToken);
      await _storage.write(key: 'user_type', value: _userType);
      
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Register a new user
  Future<void> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String userType,
    String? phoneNumber,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.registerWithEmailAndPassword(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        userType: userType,
        phoneNumber: phoneNumber,
      );
      
      // After successful registration, log the user in
      await login(email, password);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Social login
  Future<void> socialLogin(SocialLoginType type) async {
    _isLoading = true;
    notifyListeners();

    try {
      User user;
      
      switch (type) {
        case SocialLoginType.google:
          user = await _authService.signInWithGoogle();
          break;
        case SocialLoginType.facebook:
          user = await _authService.signInWithFacebook();
          break;
      }
      
      _currentUser = user;
      _userType = user.userType;
      _authToken = await _authService.getAuthToken();
      
      // Save auth data to secure storage
      await _storage.write(key: 'auth_token', value: _authToken);
      await _storage.write(key: 'user_type', value: _userType);
      
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _authService.logout();
      await _clearAuthData();
    } catch (e) {
      debugPrint('Error during logout: $e');
      rethrow;
    }
  }

  // Clear all auth data
  Future<void> _clearAuthData() async {
    _currentUser = null;
    _userType = null;
    _authToken = null;
    _isLoading = false;
    
    // Clear secure storage
    await _storage.deleteAll();
    
    notifyListeners();
  }

  // Check if user is authenticated
  Future<bool> checkAuthStatus() async {
    final token = await _storage.read(key: 'auth_token');
    return token != null;
  }

  // Update user profile
  Future<void> updateProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? profileImageUrl,
  }) async {
    if (_currentUser == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      // TODO: Call API to update profile
      // final updatedUser = await _authService.updateProfile(...);
      // _currentUser = updatedUser;
      
      notifyListeners();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.sendPasswordResetEmail(email);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

enum SocialLoginType {
  google,
  facebook,
}
