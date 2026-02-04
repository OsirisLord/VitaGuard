import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vitaguard/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:vitaguard/features/auth/presentation/bloc/auth_event.dart';
import 'package:vitaguard/features/auth/presentation/bloc/auth_state.dart';
import 'package:vitaguard/features/auth/presentation/pages/login_page.dart';

// Use mocktail for simpler class mocking without code gen for state classes
class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

void main() {
  late MockAuthBloc mockAuthBloc;

  setUp(() {
    mockAuthBloc = MockAuthBloc();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<AuthBloc>.value(
        value: mockAuthBloc,
        child: const LoginPage(),
      ),
    );
  }

  testWidgets('renders login form elements', (tester) async {
    when(() => mockAuthBloc.state).thenReturn(AuthInitial());

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2)); // Email & Password
    expect(find.text('Sign In'), findsOneWidget);
  });

  testWidgets('shows loading indicator when state is AuthLoading',
      (tester) async {
    when(() => mockAuthBloc.state).thenReturn(AuthLoading());

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows error snackbar when state is AuthError', (tester) async {
    // Determine the stream of states
    whenListen(
      mockAuthBloc,
      Stream.fromIterable(
          [AuthInitial(), const AuthError(message: 'Login Failed')]),
      initialState: AuthInitial(),
    );

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump(); // trigger listener

    expect(find.text('Login Failed'), findsOneWidget);
  });

  testWidgets('adds AuthLoginRequested event when login button is pressed',
      (tester) async {
    when(() => mockAuthBloc.state).thenReturn(AuthInitial());

    await tester.pumpWidget(createWidgetUnderTest());

    // Fill form
    await tester.enterText(find.byType(TextField).first, 'test@test.com');
    await tester.enterText(find.byType(TextField).last, 'password123');

    // Tap login
    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));

    // Verify event added
    verify(() => mockAuthBloc.add(const AuthLoginRequested(
        email: 'test@test.com', password: 'password123'))).called(1);
  });
}
