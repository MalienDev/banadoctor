import 'package:equatable/equatable.dart';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

abstract class Failure extends Equatable {
  final String message;
  final StackTrace? stackTrace;

  const Failure(this.message, [this.stackTrace]);

  @override
  List<Object?> get props => [message, stackTrace];

  @override
  String toString() => 'Failure(message: $message, stackTrace: $stackTrace)';
}

// General failures
class ServerFailure extends Failure {
  const ServerFailure(String message, [StackTrace? stackTrace])
      : super(message, stackTrace);

  factory ServerFailure.fromDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return const ServerFailure('Connection timeout. Please try again.');
      case DioExceptionType.sendTimeout:
        return const ServerFailure('Send timeout. Please try again.');
      case DioExceptionType.receiveTimeout:
        return const ServerFailure('Receive timeout. Please try again.');
      case DioExceptionType.badResponse:
        return _handleResponseError(e.response);
      case DioExceptionType.cancel:
        return const ServerFailure('Request cancelled');
      case DioExceptionType.unknown:
        if (e.message?.contains('SocketException') ?? false) {
          return const ServerFailure('No internet connection');
        }
        return ServerFailure('Unexpected error: ${e.message}');
      default:
        return ServerFailure('Unexpected error: ${e.message}');
    }
  }

  static ServerFailure _handleResponseError(Response? response) {
    final statusCode = response?.statusCode;
    final data = response?.data;
    
    if (statusCode == null) {
      return const ServerFailure('No status code in response');
    }

    final message = data is Map<String, dynamic> 
        ? data['message']?.toString() ?? 'An error occurred'
        : 'An error occurred';

    switch (statusCode) {
      case 400:
        return ServerFailure(message);
      case 401:
        return ServerFailure(message.isNotEmpty ? message : 'Unauthorized');
      case 403:
        return ServerFailure(message.isNotEmpty ? message : 'Forbidden');
      case 404:
        return ServerFailure(message.isNotEmpty ? message : 'Not found');
      case 422:
        final errors = data is Map<String, dynamic> 
            ? data['errors'] as Map<String, dynamic>?
            : null;
        if (errors != null) {
          return ServerFailure(
            errors.entries
                .map((e) => '${e.key}: ${e.value.join(', ')}')
                .join('\n'),
          );
        }
        return ServerFailure(message);
      case 500:
        return const ServerFailure('Internal server error');
      case 502:
        return const ServerFailure('Bad gateway');
      case 503:
        return const ServerFailure('Service unavailable');
      case 504:
        return const ServerFailure('Gateway timeout');
      default:
        return ServerFailure('Error: $statusCode - $message');
    }
  }
}

class CacheFailure extends Failure {
  const CacheFailure(String message) : super(message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(String message) : super(message);
}

class ValidationFailure extends Failure {
  final Map<String, List<String>> errors;

  const ValidationFailure({
    required String message,
    this.errors = const {},
  }) : super(message);

  @override
  List<Object?> get props => [message, errors];

  @override
  String toString() => 'ValidationFailure(message: $message, errors: $errors)';
}

class PermissionFailure extends Failure {
  const PermissionFailure(String message) : super(message);
}

class AuthFailure extends Failure {
  const AuthFailure(String message) : super(message);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure(String message) : super(message);
}

class TimeoutFailure extends Failure {
  const TimeoutFailure(String message) : super(message);
}

class NoInternetFailure extends Failure {
  const NoInternetFailure() : super('No internet connection');
}

class UnsupportedFailure extends Failure {
  const UnsupportedFailure(String message) : super(message);
}

class FormatFailure extends Failure {
  const FormatFailure(String message) : super(message);
}

typedef ResultFuture<T> = Future<Either<Failure, T>>;
typedef ResultVoid = ResultFuture<void>;
typedef DataMap = Map<String, dynamic>;
