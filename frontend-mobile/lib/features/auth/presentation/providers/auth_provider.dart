import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:logger/logger.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/typedefs.dart';
import '../../domain/models/user_model.dart';
import '../../domain/usecases/forgot_password_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import '../../domain/usecases/verify_email_usecase.dart';
import '../../domain/usecases/verify_phone_usecase.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    loginUseCase: ref.watch(loginUseCaseProvider),
    registerUseCase: ref.watch(registerUseCaseProvider),
    forgotPasswordUseCase: ref.watch(forgotPasswordUseCaseProvider),
    resetPasswordUseCase: ref.watch(resetPasswordUseCaseProvider),
    verifyEmailUseCase: ref.watch(verifyEmailUseCaseProvider),
    verifyPhoneUseCase: ref.watch(verifyPhoneUseCaseProvider),
    logoutUseCase: ref.watch(logoutUseCaseProvider),
    logger: ref.watch(loggerProvider),
  );
});

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier({
    required this.loginUseCase,
    required this.logger,
  }) : super(const AuthState.initial());

  final LoginUseCase loginUseCase;
  final Logger logger;

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const AuthState.loading();
    
    final result = await loginUseCase.call(LoginParams(
      email: email,
      password: password,
    ));

    state = result.fold(
      (failure) {
        logger.e('Login failed: ${failure.message}');
        return AuthState.error(failure.message);
      },
      (user) {
        logger.i('Login successful for user: ${user.email}');
        return AuthState.authenticated(user);
      },
    );
  }

  Future<void> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phoneNumber,
    String role = 'patient',
  }) async {
    state = const AuthState.loading();
    
    final result = await registerUseCase.call(RegisterParams(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      phoneNumber: phoneNumber,
      role: role,
    ));

    state = result.fold(
      (failure) {
        logger.e('Registration failed: ${failure.message}');
        return AuthState.error(failure.message);
      },
      (user) {
        logger.i('Registration successful for user: ${user.email}');
        return AuthState.authenticated(user);
      },
    );
  }

  Future<Either<Failure, void>> forgotPassword(String email) async {
    state = const AuthState.loading();
    
    final result = await forgotPasswordUseCase.call(email);
    
    return result.fold(
      (failure) {
        logger.e('Forgot password failed: ${failure.message}');
        state = AuthState.error(failure.message);
        return left(failure);
      },
      (_) {
        logger.i('Password reset email sent to $email');
        state = const AuthState.unauthenticated();
        return right(null);
      },
    );
  }

  Future<Either<Failure, void>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    state = const AuthState.loading();
    
    final result = await resetPasswordUseCase.call(ResetPasswordParams(
      token: token,
      newPassword: newPassword,
    ));
    
    return result.fold(
      (failure) {
        logger.e('Password reset failed: ${failure.message}');
        state = AuthState.error(failure.message);
        return left(failure);
      },
      (_) {
        logger.i('Password reset successful');
        state = const AuthState.unauthenticated();
        return right(null);
      },
    );
  }

  Future<Either<Failure, void>> verifyEmail(String token) async {
    state = const AuthState.loading();
    
    final result = await verifyEmailUseCase.call(token);
    
    return result.fold(
      (failure) {
        logger.e('Email verification failed: ${failure.message}');
        state = AuthState.error(failure.message);
        return left(failure);
      },
      (_) {
        logger.i('Email verified successfully');
        // Update the user's email verification status
        if (state is _Authenticated) {
          final currentUser = (state as _Authenticated).user;
          final updatedUser = currentUser.copyWith(isEmailVerified: true);
          state = AuthState.authenticated(updatedUser);
        }
        return right(null);
      },
    );
  }

  Future<Either<Failure, void>> verifyPhone(String code) async {
    state = const AuthState.loading();
    
    final result = await verifyPhoneUseCase.call(code);
    
    return result.fold(
      (failure) {
        logger.e('Phone verification failed: ${failure.message}');
        state = AuthState.error(failure.message);
        return left(failure);
      },
      (_) {
        logger.i('Phone verified successfully');
        // Update the user's phone verification status
        if (state is _Authenticated) {
          final currentUser = (state as _Authenticated).user;
          final updatedUser = currentUser.copyWith(isPhoneVerified: true);
          state = AuthState.authenticated(updatedUser);
        }
        return right(null);
      },
    );
  }

  Future<void> logout() async {
    state = const AuthState.loading();
    
    final result = await logoutUseCase.call();
    
    result.fold(
      (failure) {
        logger.e('Logout failed: ${failure.message}');
        state = AuthState.error(failure.message);
      },
      (_) {
        logger.i('Logout successful');
        state = const AuthState.unauthenticated();
      },
    );
  }
}

@immutable
sealed class AuthState {
  const AuthState();

  const factory AuthState.initial() = _Initial;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.authenticated(User user) = _Authenticated;
  const factory AuthState.unauthenticated() = _Unauthenticated;
  const factory AuthState.error(String message) = _Error;

  bool get isInitial => this is _Initial;
  bool get isLoading => this is _Loading;
  bool get isAuthenticated => this is _Authenticated;
  bool get isUnauthenticated => this is _Unauthenticated;
  bool get isError => this is _Error;

  User? get user => isAuthenticated ? (this as _Authenticated).user : null;
  String? get errorMessage => isError ? (this as _Error).message : null;
}

class _Initial extends AuthState {
  const _Initial();
}

class _Loading extends AuthState {
  const _Loading();
}

class _Authenticated extends AuthState {
  final User user;
  
  const _Authenticated(this.user);
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _Authenticated && other.user == user;
  }
  
  @override
  int get hashCode => user.hashCode;
}

class _Unauthenticated extends AuthState {
  const _Unauthenticated();
}

class _Error extends AuthState {
  final String message;
  
  const _Error(this.message);
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _Error && other.message == message;
  }
  
  @override
  int get hashCode => message.hashCode;
}
