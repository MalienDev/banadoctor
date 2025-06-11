import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/models/user_model.dart';
import 'auth_local_data_source.dart';

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  static const String _userKey = 'cached_user';
  static const String _authTokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  
  final SharedPreferences sharedPreferences;
  final FlutterSecureStorage secureStorage;

  AuthLocalDataSourceImpl({
    required this.sharedPreferences,
    required this.secureStorage,
  });

  @override
  Future<void> cacheUser(User user) async {
    await sharedPreferences.setString(
      _userKey,
      jsonEncode(user.toJson()),
    );
  }

  @override
  Future<User?> getCachedUser() async {
    final userJson = sharedPreferences.getString(_userKey);
    if (userJson == null) return null;
    
    try {
      final userMap = jsonDecode(userJson) as Map<String, dynamic>;
      return User.fromJson(userMap);
    } catch (e) {
      await clearCache();
      return null;
    }
  }

  @override
  Future<void> clearCache() async {
    await sharedPreferences.remove(_userKey);
  }

  @override
  Future<String?> getAuthToken() async {
    return await secureStorage.read(key: _authTokenKey);
  }

  @override
  Future<void> cacheAuthToken(String token) async {
    await secureStorage.write(key: _authTokenKey, value: token);
  }

  @override
  Future<String?> getRefreshToken() async {
    return await secureStorage.read(key: _refreshTokenKey);
  }

  @override
  Future<void> cacheRefreshToken(String refreshToken) async {
    await secureStorage.write(key: _refreshTokenKey, value: refreshToken);
  }

  @override
  Future<void> clearAuthTokens() async {
    await secureStorage.delete(key: _authTokenKey);
    await secureStorage.delete(key: _refreshTokenKey);
  }
}
