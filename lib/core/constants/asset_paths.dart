/// Asset paths for images, icons, animations, and other resources.
abstract class AssetPaths {
  // Base paths
  static const String _images = 'assets/images';
  static const String _icons = 'assets/icons';
  static const String _animations = 'assets/animations';
  static const String _models = 'assets/models';

  // Logo and Branding
  static const String logo = '$_images/logo.png';
  static const String logoWhite = '$_images/logo_white.png';
  static const String logoIcon = '$_images/logo_icon.png';

  // Onboarding Images
  static const String onboarding1 = '$_images/onboarding_1.png';
  static const String onboarding2 = '$_images/onboarding_2.png';
  static const String onboarding3 = '$_images/onboarding_3.png';
  static const String supportLovedOnes = '$_images/support_loved_ones.png';
  static const String stayConnected = '$_images/stay_connected.png';

  // Role Icons
  static const String patientIcon = '$_icons/patient.svg';
  static const String doctorIcon = '$_icons/doctor.svg';
  static const String companionIcon = '$_icons/companion.svg';
  static const String facilityIcon = '$_icons/facility.svg';

  // Vital Signs Icons
  static const String heartRateIcon = '$_icons/heart_rate.svg';
  static const String oxygenIcon = '$_icons/oxygen.svg';
  static const String temperatureIcon = '$_icons/temperature.svg';
  static const String alertIcon = '$_icons/alert.svg';

  // Medical Icons
  static const String xrayIcon = '$_icons/xray.svg';
  static const String stethoscopeIcon = '$_icons/stethoscope.svg';
  static const String lungIcon = '$_icons/lung.svg';
  static const String reportIcon = '$_icons/report.svg';

  // UI Icons
  static const String homeIcon = '$_icons/home.svg';
  static const String chatIcon = '$_icons/chat.svg';
  static const String notificationIcon = '$_icons/notification.svg';
  static const String settingsIcon = '$_icons/settings.svg';
  static const String profileIcon = '$_icons/profile.svg';

  // Animations (Lottie)
  static const String loadingAnimation = '$_animations/loading.json';
  static const String successAnimation = '$_animations/success.json';
  static const String errorAnimation = '$_animations/error.json';
  static const String heartbeatAnimation = '$_animations/heartbeat.json';
  static const String scanningAnimation = '$_animations/scanning.json';
  static const String emptyStateAnimation = '$_animations/empty_state.json';

  // AI Models
  static const String pneumoniaModel = '$_models/efficientnet_b0_int8.tflite';
  static const String modelLabels = '$_models/labels.txt';

  // Placeholder Images
  static const String avatarPlaceholder = '$_images/avatar_placeholder.png';
  static const String xrayPlaceholder = '$_images/xray_placeholder.png';
}
