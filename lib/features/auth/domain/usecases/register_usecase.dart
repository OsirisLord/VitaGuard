import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Use case for registering a new user.
class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<Either<Failure, User>> call({
    required String email,
    required String password,
    required String role,
    required String displayName,
    String? phoneNumber,
    Map<String, dynamic>? roleSpecificData,
  }) {
    return repository.register(
      email: email,
      password: password,
      role: role,
      displayName: displayName,
      phoneNumber: phoneNumber,
      roleSpecificData: roleSpecificData,
    );
  }
}
