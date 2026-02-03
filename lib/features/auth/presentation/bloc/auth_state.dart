import 'package:equatable/equatable.dart';

import '../../domain/entities/user.dart';

/// States for the AuthBloc.
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any auth check.
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Loading state during auth operations.
class AuthLoading extends AuthState {
  final String? message;

  const AuthLoading({this.message});

  @override
  List<Object?> get props => [message];
}

/// Authenticated state with user data.
class Authenticated extends AuthState {
  final User user;

  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

/// Unauthenticated state.
class Unauthenticated extends AuthState {
  const Unauthenticated();
}

/// Error state with failure message.
class AuthError extends AuthState {
  final String message;
  final String? code;

  const AuthError({
    required this.message,
    this.code,
  });

  @override
  List<Object?> get props => [message, code];
}

/// Password reset email sent successfully.
class AuthPasswordResetSent extends AuthState {
  final String email;

  const AuthPasswordResetSent({required this.email});

  @override
  List<Object?> get props => [email];
}

/// Registration successful (may need email verification).
class AuthRegistrationSuccess extends AuthState {
  final User user;
  final bool needsEmailVerification;

  const AuthRegistrationSuccess({
    required this.user,
    this.needsEmailVerification = false,
  });

  @override
  List<Object?> get props => [user, needsEmailVerification];
}
