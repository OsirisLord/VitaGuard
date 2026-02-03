/// Application-wide constant values.
abstract class AppConstants {
  // App Info
  static const String appName = 'VitaGuard';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';

  // Session
  static const Duration sessionTimeout = Duration(minutes: 30);
  static const Duration tokenRefreshBuffer = Duration(minutes: 5);

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Vital Signs Thresholds
  static const int normalSpo2Min = 95;
  static const int warningSpo2Min = 90;
  static const int criticalSpo2Min = 85;

  static const int normalBpmMin = 60;
  static const int normalBpmMax = 100;
  static const int warningBpmMax = 120;
  static const int criticalBpmMax = 150;

  // Image Upload
  static const int maxImageSizeMB = 10;
  static const int maxImageWidth = 1024;
  static const int maxImageHeight = 1024;
  static const int imageQuality = 85;

  // Cache
  static const Duration cacheValidDuration = Duration(hours: 24);
  static const int maxCacheSizeMB = 100;

  // Network
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const int maxRetries = 3;

  // Animation Durations
  static const Duration fastAnimation = Duration(milliseconds: 150);
  static const Duration normalAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);

  // Debounce
  static const Duration searchDebounce = Duration(milliseconds: 500);
  static const Duration buttonDebounce = Duration(milliseconds: 300);

  // IoT/ESP32
  static const Duration vitalUpdateInterval = Duration(seconds: 5);
  static const Duration reconnectDelay = Duration(seconds: 3);
  static const int maxReconnectAttempts = 5;

  // Encryption
  static const int encryptionKeyLength = 32;
  static const int ivLength = 16;

  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const int minNameLength = 2;
  static const int maxNameLength = 100;
  static const int maxBioLength = 500;
}
