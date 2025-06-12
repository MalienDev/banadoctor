import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../models/user_model.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> checkAuthStatus();

  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  });
  
  Future<Either<Failure, User>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phoneNumber,
    required String role,
  });
  
  Future<Either<Failure, void>> logout();
  
  Future<Either<Failure, User>> getCurrentUser();
  
  Future<Either<Failure, void>> forgotPassword(String email);
  
  Future<Either<Failure, void>> resetPassword({
    required String token,
    required String newPassword,
  });
  
  Future<Either<Failure, void>> updateProfile({
    required String userId,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? profileImageUrl,
  });
  
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  });
  
  Future<Either<Failure, void>> verifyEmail(String token);
  
  Future<Either<Failure, void>> verifyPhone(String code);
}
