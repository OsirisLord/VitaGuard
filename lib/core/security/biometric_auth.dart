import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

/// Service for biometric authentication (Face ID, Touch ID, Fingerprint).
abstract class BiometricAuthService {
  /// Checks if biometric authentication is available on the device.
  Future<bool> isAvailable();

  /// Gets the list of available biometric types.
  Future<List<BiometricType>> getAvailableBiometrics();

  /// Authenticates the user using biometrics.
  Future<bool> authenticate({required String reason});

  /// Checks if device has biometric hardware.
  Future<bool> canCheckBiometrics();
}

/// Implementation of BiometricAuthService using local_auth.
class BiometricAuthServiceImpl implements BiometricAuthService {
  final LocalAuthentication _localAuth;

  BiometricAuthServiceImpl() : _localAuth = LocalAuthentication();

  @override
  Future<bool> isAvailable() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();
      return canCheck && isSupported;
    } on PlatformException {
      return false;
    }
  }

  @override
  Future<bool> canCheckBiometrics() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } on PlatformException {
      return false;
    }
  }

  @override
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } on PlatformException {
      return [];
    }
  }

  @override
  Future<bool> authenticate({required String reason}) async {
    try {
      return await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // Allow PIN/pattern as fallback
          useErrorDialogs: true,
        ),
      );
    } on PlatformException catch (e) {
      // Handle specific platform exceptions
      switch (e.code) {
        case 'NotAvailable':
        case 'NotEnrolled':
        case 'LockedOut':
        case 'PermanentlyLockedOut':
          return false;
        default:
          return false;
      }
    }
  }
}

/// Extension to get human-readable biometric type names.
extension BiometricTypeExtension on BiometricType {
  String get displayName {
    switch (this) {
      case BiometricType.face:
        return 'Face ID';
      case BiometricType.fingerprint:
        return 'Fingerprint';
      case BiometricType.iris:
        return 'Iris';
      case BiometricType.strong:
        return 'Strong Biometric';
      case BiometricType.weak:
        return 'Weak Biometric';
    }
  }

  String get iconAsset {
    switch (this) {
      case BiometricType.face:
        return 'assets/icons/face_id.svg';
      case BiometricType.fingerprint:
        return 'assets/icons/fingerprint.svg';
      default:
        return 'assets/icons/biometric.svg';
    }
  }
}
