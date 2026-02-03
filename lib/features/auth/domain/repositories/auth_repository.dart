import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/user.dart';

/// Repository interface for authentication operations.
abstract class AuthRepository {
  /// Logs in a user with email and password.
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  });

  /// Registers a new user.
  Future<Either<Failure, User>> register({
    required String email,
    required String password,
    required String role,
    required String displayName,
    String? phoneNumber,
    Map<String, dynamic>? roleSpecificData,
  });

  /// Logs out the current user.
  Future<Either<Failure, void>> logout();

  /// Gets the currently authenticated user.
  Future<Either<Failure, User?>> getCurrentUser();

  /// Sends a password reset email.
  Future<Either<Failure, void>> forgotPassword({required String email});

  /// Resets the password with a code.
  Future<Either<Failure, void>> resetPassword({
    required String code,
    required String newPassword,
  });

  /// Updates the user profile.
  Future<Either<Failure, User>> updateProfile({
    String? displayName,
    String? photoUrl,
    String? phoneNumber,
    Map<String, dynamic>? roleSpecificData,
  });

  /// Sends an email verification.
  Future<Either<Failure, void>> sendEmailVerification();

  /// Checks if the user is authenticated.
  Future<bool> isAuthenticated();

  /// Stream of authentication state changes.
  Stream<User?> get authStateChanges;
}
