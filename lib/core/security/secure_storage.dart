import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service for securely storing sensitive data.
/// Uses platform-specific secure storage (Keychain on iOS, EncryptedSharedPreferences on Android).
abstract class SecureStorageService {
  /// Writes a value to secure storage.
  Future<void> write({required String key, required String value});

  /// Reads a value from secure storage.
  Future<String?> read({required String key});

  /// Deletes a value from secure storage.
  Future<void> delete({required String key});

  /// Deletes all values from secure storage.
  Future<void> deleteAll();

  /// Checks if a key exists in secure storage.
  Future<bool> containsKey({required String key});

  /// Gets all keys in secure storage.
  Future<Map<String, String>> readAll();
}

/// Storage keys used throughout the app.
abstract class StorageKeys {
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String userRole = 'user_role';
  static const String userProfile = 'user_profile';
  static const String encryptionKey = 'encryption_key';
  static const String biometricEnabled = 'biometric_enabled';
  static const String lastLoginTime = 'last_login_time';
  static const String deviceId = 'device_id';
  static const String fcmToken = 'fcm_token';
  static const String onboardingCompleted = 'onboarding_completed';
  static const String themeMode = 'theme_mode';
  static const String esp32IpAddress = 'esp32_ip_address';
}

/// Implementation of SecureStorageService using flutter_secure_storage.
class SecureStorageServiceImpl implements SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageServiceImpl(this._storage);

  @override
  Future<void> write({required String key, required String value}) async {
    await _storage.write(key: key, value: value);
  }

  @override
  Future<String?> read({required String key}) async {
    return _storage.read(key: key);
  }

  @override
  Future<void> delete({required String key}) async {
    await _storage.delete(key: key);
  }

  @override
  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }

  @override
  Future<bool> containsKey({required String key}) async {
    return _storage.containsKey(key: key);
  }

  @override
  Future<Map<String, String>> readAll() async {
    return _storage.readAll();
  }
}

/// Extension methods for convenient token management.
extension SecureStorageTokenExtension on SecureStorageService {
  /// Saves authentication tokens.
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await write(key: StorageKeys.accessToken, value: accessToken);
    await write(key: StorageKeys.refreshToken, value: refreshToken);
    await write(
      key: StorageKeys.lastLoginTime,
      value: DateTime.now().toIso8601String(),
    );
  }

  /// Gets the access token.
  Future<String?> getAccessToken() async {
    return read(key: StorageKeys.accessToken);
  }

  /// Gets the refresh token.
  Future<String?> getRefreshToken() async {
    return read(key: StorageKeys.refreshToken);
  }

  /// Clears all authentication data.
  Future<void> clearAuth() async {
    await delete(key: StorageKeys.accessToken);
    await delete(key: StorageKeys.refreshToken);
    await delete(key: StorageKeys.userId);
    await delete(key: StorageKeys.userRole);
    await delete(key: StorageKeys.userProfile);
  }

  /// Checks if user is logged in.
  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
