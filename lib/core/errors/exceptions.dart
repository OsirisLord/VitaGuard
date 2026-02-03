/// Base class for all exceptions in the application.
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppException({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  String toString() => 'AppException: $message (code: $code)';
}

/// Exception thrown when server returns an error.
class ServerException extends AppException {
  final int? statusCode;

  const ServerException({
    required super.message,
    super.code,
    super.originalError,
    this.statusCode,
  });

  @override
  String toString() =>
      'ServerException: $message (status: $statusCode, code: $code)';
}

/// Exception thrown when there's no cached data.
class CacheException extends AppException {
  const CacheException({
    super.message = 'No cached data found',
    super.code = 'CACHE_MISS',
    super.originalError,
  });
}

/// Exception for authentication errors from Firebase.
class AuthException extends AppException {
  const AuthException({
    required super.message,
    super.code,
    super.originalError,
  });

  /// Factory to create from Firebase Auth error codes
  factory AuthException.fromFirebaseCode(String code) {
    switch (code) {
      case 'user-not-found':
        return const AuthException(
          message: 'No user found with this email.',
          code: 'USER_NOT_FOUND',
        );
      case 'wrong-password':
        return const AuthException(
          message: 'Incorrect password.',
          code: 'WRONG_PASSWORD',
        );
      case 'email-already-in-use':
        return const AuthException(
          message: 'This email is already registered.',
          code: 'EMAIL_IN_USE',
        );
      case 'invalid-email':
        return const AuthException(
          message: 'Invalid email address.',
          code: 'INVALID_EMAIL',
        );
      case 'weak-password':
        return const AuthException(
          message: 'Password is too weak.',
          code: 'WEAK_PASSWORD',
        );
      case 'operation-not-allowed':
        return const AuthException(
          message: 'This operation is not allowed.',
          code: 'OPERATION_NOT_ALLOWED',
        );
      case 'user-disabled':
        return const AuthException(
          message: 'This account has been disabled.',
          code: 'USER_DISABLED',
        );
      case 'too-many-requests':
        return const AuthException(
          message: 'Too many attempts. Please try again later.',
          code: 'TOO_MANY_REQUESTS',
        );
      case 'network-request-failed':
        return const AuthException(
          message: 'Network error. Please check your connection.',
          code: 'NETWORK_ERROR',
        );
      default:
        return AuthException(
          message: 'Authentication error: $code',
          code: code,
        );
    }
  }
}

/// Exception for network connectivity issues.
class NetworkException extends AppException {
  const NetworkException({
    super.message = 'No internet connection',
    super.code = 'NO_INTERNET',
    super.originalError,
  });
}

/// Exception for validation errors.
class ValidationException extends AppException {
  final Map<String, List<String>>? fieldErrors;

  const ValidationException({
    required super.message,
    super.code = 'VALIDATION_ERROR',
    super.originalError,
    this.fieldErrors,
  });
}

/// Exception for IoT device connection issues.
class DeviceException extends AppException {
  const DeviceException({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Exception for AI model errors.
class ModelException extends AppException {
  const ModelException({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Exception for permission denied.
class PermissionException extends AppException {
  const PermissionException({
    required super.message,
    super.code = 'PERMISSION_DENIED',
    super.originalError,
  });
}

/// Exception for feature not available.
class FeatureNotAvailableException extends AppException {
  const FeatureNotAvailableException({
    super.message = 'This feature is not available yet',
    super.code = 'FEATURE_NOT_AVAILABLE',
    super.originalError,
  });
}
