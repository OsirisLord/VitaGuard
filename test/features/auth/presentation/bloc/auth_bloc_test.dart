import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:vitaguard/core/errors/failures.dart';
import 'package:vitaguard/features/auth/domain/entities/user.dart';
import 'package:vitaguard/features/auth/domain/usecases/get_current_user.dart';
import 'package:vitaguard/features/auth/domain/usecases/login_usecase.dart';
import 'package:vitaguard/features/auth/domain/usecases/logout_usecase.dart';
import 'package:vitaguard/features/auth/domain/usecases/register_usecase.dart';
import 'package:vitaguard/features/auth/presentation/bloc/auth_bloc.dart';

import 'auth_bloc_test.mocks.dart';

@GenerateMocks([LoginUseCase, RegisterUseCase, LogoutUseCase, GetCurrentUser])
void main() {
  late AuthBloc authBloc;
  late MockLoginUseCase mockLoginUseCase;
  late MockRegisterUseCase mockRegisterUseCase;
  late MockLogoutUseCase mockLogoutUseCase;
  late MockGetCurrentUser mockGetCurrentUser;

  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
    mockRegisterUseCase = MockRegisterUseCase();
    mockLogoutUseCase = MockLogoutUseCase();
    mockGetCurrentUser = MockGetCurrentUser();

    authBloc = AuthBloc(
      loginUseCase: mockLoginUseCase,
      registerUseCase: mockRegisterUseCase,
      logoutUseCase: mockLogoutUseCase,
      getCurrentUser: mockGetCurrentUser,
    );
  });

  tearDown(() {
    authBloc.close();
  });

  final tUser = User(
    id: '1',
    email: 'test@test.com',
    displayName: 'Test User',
    role: 'patient',
    createdAt: DateTime.now(),
  );
  const tEmail = 'test@test.com';
  const tPassword = 'password';

  test('initial state should be AuthInitial', () {
    expect(authBloc.state, AuthInitial());
  });

  blocTest<AuthBloc, AuthState>(
    'emits [AuthLoading, Authenticated] when LoginRequested is added and success',
    build: () {
      when(mockLoginUseCase(
              email: anyNamed('email'), password: anyNamed('password')))
          .thenAnswer((_) async => Right(tUser));
      when(mockGetCurrentUser()).thenAnswer((_) async => Right(tUser));
      return authBloc;
    },
    act: (bloc) =>
        bloc.add(const AuthLoginRequested(email: tEmail, password: tPassword)),
    expect: () => [
      const AuthLoading(message: 'Signing in...'),
      Authenticated(tUser),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'emits [AuthLoading, AuthError] when LoginRequested is added and failure',
    build: () {
      when(mockLoginUseCase(
              email: anyNamed('email'), password: anyNamed('password')))
          .thenAnswer(
              (_) async => const Left(ServerFailure(message: 'Server Error')));
      return authBloc;
    },
    act: (bloc) =>
        bloc.add(const AuthLoginRequested(email: tEmail, password: tPassword)),
    expect: () => [
      const AuthLoading(message: 'Signing in...'),
      const AuthError(message: 'Server Error'),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'emits [AuthLoading, Unauthenticated] when LogoutRequested is added',
    build: () {
      when(mockLogoutUseCase()).thenAnswer((_) async => const Right(unit));
      return authBloc;
    },
    act: (bloc) => bloc.add(const AuthLogoutRequested()),
    expect: () => [
      const AuthLoading(message: 'Signing out...'),
      Unauthenticated(),
    ],
  );
}
