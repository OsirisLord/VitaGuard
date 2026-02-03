/// Validators for form input validation.
abstract class Validators {
  /// Email regex pattern.
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$',
  );

  /// Phone number regex pattern.
  static final RegExp _phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');

  /// Password strength regex (min 8 chars, 1 uppercase, 1 lowercase, 1 digit).
  static final RegExp _strongPasswordRegex = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d@$!%*?&]{8,}$',
  );

  /// Validates an email address.
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!_emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Validates a password.
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  /// Validates password strength.
  static String? validateStrongPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!_strongPasswordRegex.hasMatch(value)) {
      return 'Password must contain uppercase, lowercase, and a number';
    }
    return null;
  }

  /// Validates password confirmation.
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  /// Validates a required field.
  static String? validateRequired(String? value, [String fieldName = 'Field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validates a name field.
  static String? validateName(String? value, [String fieldName = 'Name']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    if (value.trim().length < 2) {
      return '$fieldName must be at least 2 characters';
    }
    if (value.trim().length > 100) {
      return '$fieldName must be less than 100 characters';
    }
    return null;
  }

  /// Validates a phone number.
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (!_phoneRegex.hasMatch(value.replaceAll(RegExp(r'[\s\-\(\)]'), ''))) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  /// Validates an optional phone number.
  static String? validateOptionalPhone(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    return validatePhone(value);
  }

  /// Validates a medical license number.
  static String? validateLicenseNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'License number is required';
    }
    if (value.length < 5) {
      return 'Please enter a valid license number';
    }
    return null;
  }

  /// Validates facility registration number.
  static String? validateFacilityRegNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Registration number is required';
    }
    if (value.length < 5) {
      return 'Please enter a valid registration number';
    }
    return null;
  }

  /// Validates vital sign values.
  static String? validateSpo2(int? value) {
    if (value == null) {
      return 'SpO2 value is required';
    }
    if (value < 0 || value > 100) {
      return 'SpO2 must be between 0 and 100';
    }
    return null;
  }

  /// Validates heart rate.
  static String? validateBpm(int? value) {
    if (value == null) {
      return 'Heart rate is required';
    }
    if (value < 30 || value > 250) {
      return 'Heart rate must be between 30 and 250';
    }
    return null;
  }
}
