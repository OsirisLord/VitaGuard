import 'package:equatable/equatable.dart';

/// Base class for all failures in the application.
/// Uses Equatable for easy comparison in tests.
abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure({
    required this.message,
    this.code,
  });

  @override
  List<Object?> get props => [message, code];
}

/// Failure when server returns an error response.
class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure({
    required super.message,
    super.code,
    this.statusCode,
  });

  @override
  List<Object?> get props => [message, code, statusCode];
}

/// Failure when there's no internet connection.
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'No internet connection. Please check your network.',
    super.code = 'NETWORK_ERROR',
  });
}

/// Failure when cached data is not found.
class CacheFailure extends Failure {
  const CacheFailure({
    super.message = 'No cached data available.',
    super.code = 'CACHE_ERROR',
  });
}

/// Failure for authentication-related errors.
class AuthFailure extends Failure {
  const AuthFailure({
    required super.message,
    super.code,
  });

  /// User not found
  factory AuthFailure.userNotFound() => const AuthFailure(
        message: 'No user found with this email.',
        code: 'USER_NOT_FOUND',
      );

  /// Wrong password
  factory AuthFailure.wrongPassword() => const AuthFailure(
        message: 'Incorrect password. Please try again.',
        code: 'WRONG_PASSWORD',
      );

  /// Email already in use
  factory AuthFailure.emailInUse() => const AuthFailure(
        message: 'This email is already registered.',
        code: 'EMAIL_IN_USE',
      );

  /// Invalid email format
  factory AuthFailure.invalidEmail() => const AuthFailure(
        message: 'Please enter a valid email address.',
        code: 'INVALID_EMAIL',
      );

  /// Weak password
  factory AuthFailure.weakPassword() => const AuthFailure(
        message: 'Password is too weak. Use at least 8 characters.',
        code: 'WEAK_PASSWORD',
      );

  /// Session expired
  factory AuthFailure.sessionExpired() => const AuthFailure(
        message: 'Your session has expired. Please login again.',
        code: 'SESSION_EXPIRED',
      );

  /// Unauthorized access
  factory AuthFailure.unauthorized() => const AuthFailure(
        message: 'You are not authorized to perform this action.',
        code: 'UNAUTHORIZED',
      );
}

/// Failure for validation errors.
class ValidationFailure extends Failure {
  final Map<String, List<String>>? fieldErrors;

  const ValidationFailure({
    required super.message,
    super.code = 'VALIDATION_ERROR',
    this.fieldErrors,
  });

  @override
  List<Object?> get props => [message, code, fieldErrors];
}

/// Failure for IoT/Device connection errors.
class DeviceFailure extends Failure {
  const DeviceFailure({
    required super.message,
    super.code,
  });

  /// Device not found
  factory DeviceFailure.notFound() => const DeviceFailure(
        message: 'ESP32 device not found. Make sure it is powered on.',
        code: 'DEVICE_NOT_FOUND',
      );

  /// Connection lost
  factory DeviceFailure.connectionLost() => const DeviceFailure(
        message: 'Lost connection to the monitoring device.',
        code: 'CONNECTION_LOST',
      );

  /// Timeout
  factory DeviceFailure.timeout() => const DeviceFailure(
        message: 'Connection to device timed out.',
        code: 'DEVICE_TIMEOUT',
      );
}

/// Failure for AI/ML model errors.
class ModelFailure extends Failure {
  const ModelFailure({
    required super.message,
    super.code,
  });

  /// Model not loaded
  factory ModelFailure.notLoaded() => const ModelFailure(
        message: 'AI model is not loaded. Please restart the app.',
        code: 'MODEL_NOT_LOADED',
      );

  /// Invalid input
  factory ModelFailure.invalidInput() => const ModelFailure(
        message: 'The image could not be processed. Please try another.',
        code: 'INVALID_INPUT',
      );

  /// Inference error
  factory ModelFailure.inferenceError() => const ModelFailure(
        message: 'Error analyzing the image. Please try again.',
        code: 'INFERENCE_ERROR',
      );
}

/// Unknown/unexpected failure.
class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = 'An unexpected error occurred. Please try again.',
    super.code = 'UNKNOWN_ERROR',
  });
}
