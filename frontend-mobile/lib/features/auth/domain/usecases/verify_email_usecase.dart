import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

class VerifyEmailUseCase {
  final AuthRepository _authRepository;

  VerifyEmailUseCase(this._authRepository);

  Future<Either<Failure, void>> call(String token) async {
    return await _authRepository.verifyEmail(token);
  }
}
