import 'package:flutter/material.dart';

/// Brand colors for VitaGuard app matching the UI mockups.
abstract class AppColors {
  // Primary Colors (Navy Blue theme from mockups)
  static const Color primary = Color(0xFF1A365D);
  static const Color primaryLight = Color(0xFF2C5282);
  static const Color primaryDark = Color(0xFF0F2942);

  // Secondary Colors (Coral/Salmon accents)
  static const Color secondary = Color(0xFFE57373);
  static const Color secondaryLight = Color(0xFFFFAB91);
  static const Color secondaryDark = Color(0xFFD32F2F);

  // Background Colors
  static const Color background = Color(0xFFFAFAFA);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color cardBackground = Color(0xFFFFF5F5);

  // Text Colors
  static const Color textPrimary = Color(0xFF1A202C);
  static const Color textSecondary = Color(0xFF4A5568);
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFF718096);

  // Status Colors
  static const Color success = Color(0xFF48BB78);
  static const Color warning = Color(0xFFED8936);
  static const Color error = Color(0xFFE53E3E);
  static const Color info = Color(0xFF4299E1);

  // Vital Signs Colors
  static const Color heartRate = Color(0xFFE53E3E);
  static const Color oxygenLevel = Color(0xFF4299E1);
  static const Color normalVital = Color(0xFF48BB78);
  static const Color warningVital = Color(0xFFED8936);
  static const Color criticalVital = Color(0xFFE53E3E);

  // Role-specific Colors
  static const Color patientRole = Color(0xFF4299E1);
  static const Color doctorRole = Color(0xFF48BB78);
  static const Color companionRole = Color(0xFF9F7AEA);
  static const Color facilityRole = Color(0xFFED8936);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryLight, primary],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFF5F5), Color(0xFFFEEBEB)],
  );

  // Shadows
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get elevatedShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];
}
