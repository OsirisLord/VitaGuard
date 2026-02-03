/// API endpoints for VitaGuard backend services.
abstract class ApiEndpoints {
  // Base URLs
  static const String baseUrl = 'https://api.vitaguard.com/v1';
  static const String iotGatewayUrl = 'ws://192.168.1.100:8080'; // ESP32 WebSocket

  // Auth Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String verifyEmail = '/auth/verify-email';

  // User Endpoints
  static const String userProfile = '/users/profile';
  static const String updateProfile = '/users/profile';
  static const String deleteAccount = '/users/delete';

  // Patient Endpoints
  static const String patients = '/patients';
  static const String patientById = '/patients/{id}';
  static const String patientVitals = '/patients/{id}/vitals';
  static const String patientDiagnoses = '/patients/{id}/diagnoses';
  static const String assignDoctor = '/patients/{id}/assign-doctor';
  static const String addCompanion = '/patients/{id}/companions';

  // Doctor Endpoints
  static const String doctors = '/doctors';
  static const String doctorById = '/doctors/{id}';
  static const String doctorPatients = '/doctors/{id}/patients';

  // Diagnosis Endpoints
  static const String diagnoses = '/diagnoses';
  static const String diagnosisById = '/diagnoses/{id}';
  static const String uploadXray = '/diagnoses/upload-xray';
  static const String analyzeXray = '/diagnoses/analyze';

  // Vital Monitoring Endpoints
  static const String vitals = '/vitals';
  static const String latestVitals = '/vitals/latest';
  static const String vitalHistory = '/vitals/history';
  static const String vitalAlerts = '/vitals/alerts';

  // Chat Endpoints
  static const String chats = '/chats';
  static const String chatById = '/chats/{id}';
  static const String chatMessages = '/chats/{id}/messages';

  // Notification Endpoints
  static const String notifications = '/notifications';
  static const String markRead = '/notifications/{id}/read';
  static const String notificationSettings = '/notifications/settings';

  // Facility Endpoints
  static const String facilities = '/facilities';
  static const String facilityById = '/facilities/{id}';
  static const String facilityReports = '/facilities/{id}/reports';

  // Helper method to replace path parameters
  static String withParams(String endpoint, Map<String, String> params) {
    String result = endpoint;
    params.forEach((key, value) {
      result = result.replaceAll('{$key}', value);
    });
    return result;
  }
}
