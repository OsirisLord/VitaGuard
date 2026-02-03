import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/security/secure_storage.dart';
import '../models/user_model.dart';

/// Local data source for caching user data.
abstract class AuthLocalDataSource {
  /// Caches the user data.
  Future<void> cacheUser(UserModel user);

  /// Gets the cached user.
  Future<UserModel?> getCachedUser();

  /// Clears the cached user.
  Future<void> clearCache();

  /// Checks if there's a cached user.
  Future<bool> hasCachedUser();
}

/// Implementation of AuthLocalDataSource using secure storage.
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage secureStorage;

  static const String _cachedUserKey = 'cached_user';

  AuthLocalDataSourceImpl({required this.secureStorage});

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      final userMap = user.toMap();
      // Convert DateTime to ISO string for JSON serialization
      userMap['createdAt'] = user.createdAt.toIso8601String();
      if (user.lastLoginAt != null) {
        userMap['lastLoginAt'] = user.lastLoginAt!.toIso8601String();
      }
      userMap['id'] = user.id;

      final jsonString = json.encode(userMap);
      await secureStorage.write(key: _cachedUserKey, value: jsonString);
      await secureStorage.write(key: StorageKeys.userId, value: user.id);
      await secureStorage.write(key: StorageKeys.userRole, value: user.role);
    } catch (e) {
      throw CacheException(message: 'Failed to cache user: $e');
    }
  }

  @override
  Future<UserModel?> getCachedUser() async {
    try {
      final jsonString = await secureStorage.read(key: _cachedUserKey);
      if (jsonString == null) return null;

      final userMap = json.decode(jsonString) as Map<String, dynamic>;
      final userId = userMap['id'] as String;
      return UserModel.fromMap(userMap, userId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await secureStorage.delete(key: _cachedUserKey);
      await secureStorage.delete(key: StorageKeys.userId);
      await secureStorage.delete(key: StorageKeys.userRole);
      await secureStorage.delete(key: StorageKeys.accessToken);
      await secureStorage.delete(key: StorageKeys.refreshToken);
    } catch (e) {
      throw CacheException(message: 'Failed to clear cache: $e');
    }
  }

  @override
  Future<bool> hasCachedUser() async {
    try {
      final jsonString = await secureStorage.read(key: _cachedUserKey);
      return jsonString != null && jsonString.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
