import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

class ResetPasswordParams {
  final String token;
  final String newPassword;

  ResetPasswordParams({
    required this.token,
    required this.newPassword,
  });
}

class ResetPasswordUseCase {
  final AuthRepository _authRepository;

  ResetPasswordUseCase(this._authRepository);

  Future<Either<Failure, void>> call(ResetPasswordParams params) async {
    return await _authRepository.resetPassword(
      token: params.token,
      newPassword: params.newPassword,
    );
  }
}
