import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

class VerifyPhoneUseCase {
  final AuthRepository _authRepository;

  VerifyPhoneUseCase(this._authRepository);

  Future<Either<Failure, void>> call(String code) async {
    return await _authRepository.verifyPhone(code);
  }
}
