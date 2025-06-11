import '../../domain/models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheUser(User user);
  Future<User?> getCachedUser();
  Future<void> clearCache();
  Future<String?> getAuthToken();
  Future<void> cacheAuthToken(String token);
  Future<String?> getRefreshToken();
  Future<void> cacheRefreshToken(String refreshToken);
  Future<void> clearAuthTokens();
}
