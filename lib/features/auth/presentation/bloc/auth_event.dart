import 'package:equatable/equatable.dart';

/// Events for the AuthBloc.
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Event to check the current authentication status.
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// Event to log in a user.
class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

/// Event to register a new user.
class AuthRegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String role;
  final String displayName;
  final String? phoneNumber;
  final Map<String, dynamic>? roleSpecificData;

  const AuthRegisterRequested({
    required this.email,
    required this.password,
    required this.role,
    required this.displayName,
    this.phoneNumber,
    this.roleSpecificData,
  });

  @override
  List<Object?> get props => [
        email,
        password,
        role,
        displayName,
        phoneNumber,
        roleSpecificData,
      ];
}

/// Event to log out the current user.
class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

/// Event to request password reset.
class AuthForgotPasswordRequested extends AuthEvent {
  final String email;

  const AuthForgotPasswordRequested({required this.email});

  @override
  List<Object?> get props => [email];
}

/// Event when user changes from auth state stream.
class AuthUserChanged extends AuthEvent {
  final dynamic user;

  const AuthUserChanged(this.user);

  @override
  List<Object?> get props => [user];
}
