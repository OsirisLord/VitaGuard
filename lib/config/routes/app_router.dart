import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/companion/presentation/pages/companion_dashboard_page.dart';
import '../../features/doctor/presentation/pages/doctor_dashboard_page.dart';
import '../../features/facility/presentation/pages/facility_dashboard_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/onboarding/presentation/pages/role_selection_page.dart';
import '../../features/patient/presentation/pages/patient_dashboard_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';

/// Application router configuration using go_router.
abstract class AppRouter {
  /// Route names for navigation.
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String roleSelection = '/role-selection';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  // Dashboard routes
  static const String patientDashboard = '/patient';
  static const String doctorDashboard = '/doctor';
  static const String companionDashboard = '/companion';
  static const String facilityDashboard = '/facility';

  // Feature routes
  static const String xrayAnalysis = '/xray-analysis';
  static const String vitalMonitoring = '/vital-monitoring';
  static const String chat = '/chat';
  static const String notifications = '/notifications';
  static const String profile = '/profile';
  static const String settings = '/settings';

  /// GoRouter configuration.
  static final GoRouter router = GoRouter(
    initialLocation: splash,
    debugLogDiagnostics: true,
    redirect: _handleRedirect,
    routes: [
      // Splash Screen
      GoRoute(
        path: splash,
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),

      // Onboarding
      GoRoute(
        path: onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),

      // Role Selection
      GoRoute(
        path: roleSelection,
        name: 'roleSelection',
        builder: (context, state) => const RoleSelectionPage(),
      ),

      // Authentication
      GoRoute(
        path: login,
        name: 'login',
        builder: (context, state) {
          final role = state.uri.queryParameters['role'];
          return LoginPage(selectedRole: role);
        },
      ),
      GoRoute(
        path: register,
        name: 'register',
        builder: (context, state) {
          final role = state.uri.queryParameters['role'];
          return RegisterPage(selectedRole: role);
        },
      ),
      GoRoute(
        path: forgotPassword,
        name: 'forgotPassword',
        builder: (context, state) => const ForgotPasswordPage(),
      ),

      // Patient Dashboard
      GoRoute(
        path: patientDashboard,
        name: 'patientDashboard',
        builder: (context, state) => const PatientDashboardPage(),
        routes: [
          GoRoute(
            path: 'xray-analysis',
            name: 'patientXrayAnalysis',
            builder: (context, state) => const Placeholder(),
          ),
          GoRoute(
            path: 'vitals',
            name: 'patientVitals',
            builder: (context, state) => const Placeholder(),
          ),
        ],
      ),

      // Doctor Dashboard
      GoRoute(
        path: doctorDashboard,
        name: 'doctorDashboard',
        builder: (context, state) => const DoctorDashboardPage(),
        routes: [
          GoRoute(
            path: 'patients',
            name: 'doctorPatients',
            builder: (context, state) => const Placeholder(),
          ),
          GoRoute(
            path: 'patient/:id',
            name: 'doctorPatientDetail',
            builder: (context, state) {
              final patientId = state.pathParameters['id']!;
              return Placeholder(key: ValueKey(patientId));
            },
          ),
        ],
      ),

      // Companion Dashboard
      GoRoute(
        path: companionDashboard,
        name: 'companionDashboard',
        builder: (context, state) => const CompanionDashboardPage(),
      ),

      // Facility Dashboard
      GoRoute(
        path: facilityDashboard,
        name: 'facilityDashboard',
        builder: (context, state) => const FacilityDashboardPage(),
      ),

      // Chat
      GoRoute(
        path: chat,
        name: 'chat',
        builder: (context, state) => const Placeholder(),
        routes: [
          GoRoute(
            path: ':chatId',
            name: 'chatDetail',
            builder: (context, state) {
              final chatId = state.pathParameters['chatId']!;
              return Placeholder(key: ValueKey(chatId));
            },
          ),
        ],
      ),

      // Notifications
      GoRoute(
        path: notifications,
        name: 'notifications',
        builder: (context, state) => const NotificationsPage(),
      ),

      // Profile
      GoRoute(
        path: profile,
        name: 'profile',
        builder: (context, state) => const ProfilePage(),
      ),

      // Settings
      GoRoute(
        path: settings,
        name: 'settings',
        builder: (context, state) => const Placeholder(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              state.uri.toString(),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(splash),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );

  /// Handle authentication-based redirects.
  static String? _handleRedirect(BuildContext context, GoRouterState state) {
    final authState = context.read<AuthBloc>().state;
    final isLoggingIn = state.matchedLocation == login ||
        state.matchedLocation == register ||
        state.matchedLocation == forgotPassword;
    final isOnboarding = state.matchedLocation == onboarding ||
        state.matchedLocation == roleSelection ||
        state.matchedLocation == splash;

    // If authenticated, redirect to appropriate dashboard
    if (authState is Authenticated) {
      if (isLoggingIn || isOnboarding) {
        return _getDashboardRoute(authState.user.role);
      }
      return null;
    }

    // If not authenticated, redirect to login (unless already there)
    if (authState is Unauthenticated && !isLoggingIn && !isOnboarding) {
      return login;
    }

    return null;
  }

  /// Get the dashboard route for a user role.
  static String _getDashboardRoute(String role) {
    switch (role.toLowerCase()) {
      case 'patient':
        return patientDashboard;
      case 'doctor':
        return doctorDashboard;
      case 'companion':
        return companionDashboard;
      case 'facility':
        return facilityDashboard;
      default:
        return login;
    }
  }
}
