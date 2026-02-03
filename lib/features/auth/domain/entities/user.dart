import 'package:equatable/equatable.dart';

/// User roles in the VitaGuard ecosystem.
enum UserRole {
  patient,
  doctor,
  companion,
  facility,
}

/// Extension to get display names and properties for UserRole.
extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.patient:
        return 'Patient';
      case UserRole.doctor:
        return 'Doctor';
      case UserRole.companion:
        return 'Companion';
      case UserRole.facility:
        return 'Facility';
    }
  }

  String get description {
    switch (this) {
      case UserRole.patient:
        return 'Get diagnosed and monitor your health';
      case UserRole.doctor:
        return 'Review patients and provide medical feedback';
      case UserRole.companion:
        return 'Follow and support your loved ones';
      case UserRole.facility:
        return 'Manage appointments and deliver reports';
    }
  }

  String get value => name;

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.name.toLowerCase() == value.toLowerCase(),
      orElse: () => UserRole.patient,
    );
  }
}

/// User entity representing an authenticated user.
class User extends Equatable {
  final String id;
  final String email;
  final String role;
  final String? displayName;
  final String? photoUrl;
  final String? phoneNumber;
  final bool emailVerified;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  // Role-specific fields
  final PatientProfile? patientProfile;
  final DoctorProfile? doctorProfile;
  final CompanionProfile? companionProfile;
  final FacilityProfile? facilityProfile;

  const User({
    required this.id,
    required this.email,
    required this.role,
    this.displayName,
    this.photoUrl,
    this.phoneNumber,
    this.emailVerified = false,
    required this.createdAt,
    this.lastLoginAt,
    this.patientProfile,
    this.doctorProfile,
    this.companionProfile,
    this.facilityProfile,
  });

  /// Get the user's role as enum.
  UserRole get roleEnum => UserRoleExtension.fromString(role);

  /// Check if user is a patient.
  bool get isPatient => role.toLowerCase() == 'patient';

  /// Check if user is a doctor.
  bool get isDoctor => role.toLowerCase() == 'doctor';

  /// Check if user is a companion.
  bool get isCompanion => role.toLowerCase() == 'companion';

  /// Check if user is a facility.
  bool get isFacility => role.toLowerCase() == 'facility';

  /// Get the display name or email.
  String get name => displayName ?? email.split('@').first;

  /// Create a copy with updated fields.
  User copyWith({
    String? id,
    String? email,
    String? role,
    String? displayName,
    String? photoUrl,
    String? phoneNumber,
    bool? emailVerified,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    PatientProfile? patientProfile,
    DoctorProfile? doctorProfile,
    CompanionProfile? companionProfile,
    FacilityProfile? facilityProfile,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      role: role ?? this.role,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      emailVerified: emailVerified ?? this.emailVerified,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      patientProfile: patientProfile ?? this.patientProfile,
      doctorProfile: doctorProfile ?? this.doctorProfile,
      companionProfile: companionProfile ?? this.companionProfile,
      facilityProfile: facilityProfile ?? this.facilityProfile,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        role,
        displayName,
        photoUrl,
        phoneNumber,
        emailVerified,
        createdAt,
        lastLoginAt,
      ];
}

/// Patient-specific profile data.
class PatientProfile extends Equatable {
  final String? assignedDoctorId;
  final List<String> companionIds;
  final String? facilityId;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? bloodType;
  final List<String> medicalConditions;
  final List<String> allergies;

  const PatientProfile({
    this.assignedDoctorId,
    this.companionIds = const [],
    this.facilityId,
    this.dateOfBirth,
    this.gender,
    this.bloodType,
    this.medicalConditions = const [],
    this.allergies = const [],
  });

  @override
  List<Object?> get props => [
        assignedDoctorId,
        companionIds,
        facilityId,
        dateOfBirth,
        gender,
        bloodType,
        medicalConditions,
        allergies,
      ];
}

/// Doctor-specific profile data.
class DoctorProfile extends Equatable {
  final String licenseNumber;
  final String specialization;
  final String? facilityId;
  final String? hospitalName;
  final int yearsOfExperience;
  final List<String> patientIds;
  final bool isVerified;

  const DoctorProfile({
    required this.licenseNumber,
    required this.specialization,
    this.facilityId,
    this.hospitalName,
    this.yearsOfExperience = 0,
    this.patientIds = const [],
    this.isVerified = false,
  });

  @override
  List<Object?> get props => [
        licenseNumber,
        specialization,
        facilityId,
        hospitalName,
        yearsOfExperience,
        patientIds,
        isVerified,
      ];
}

/// Companion-specific profile data.
class CompanionProfile extends Equatable {
  final List<String> patientIds;
  final String relationshipType;
  final bool canViewVitals;
  final bool canReceiveAlerts;

  const CompanionProfile({
    this.patientIds = const [],
    this.relationshipType = 'Family',
    this.canViewVitals = true,
    this.canReceiveAlerts = true,
  });

  @override
  List<Object?> get props => [
        patientIds,
        relationshipType,
        canViewVitals,
        canReceiveAlerts,
      ];
}

/// Facility-specific profile data.
class FacilityProfile extends Equatable {
  final String registrationNumber;
  final String facilityType;
  final String address;
  final String? city;
  final String? country;
  final List<String> doctorIds;
  final List<String> patientIds;
  final bool isVerified;

  const FacilityProfile({
    required this.registrationNumber,
    required this.facilityType,
    required this.address,
    this.city,
    this.country,
    this.doctorIds = const [],
    this.patientIds = const [],
    this.isVerified = false,
  });

  @override
  List<Object?> get props => [
        registrationNumber,
        facilityType,
        address,
        city,
        country,
        doctorIds,
        patientIds,
        isVerified,
      ];
}
