import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/user.dart';

/// User model for data layer operations.
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.role,
    super.displayName,
    super.photoUrl,
    super.phoneNumber,
    super.emailVerified,
    required super.createdAt,
    super.lastLoginAt,
    super.patientProfile,
    super.doctorProfile,
    super.companionProfile,
    super.facilityProfile,
  });

  /// Creates a UserModel from Firestore document.
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel.fromMap(data, doc.id);
  }

  /// Creates a UserModel from a map.
  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    final role = map['role'] as String? ?? 'patient';

    return UserModel(
      id: id,
      email: map['email'] as String? ?? '',
      role: role,
      displayName: map['displayName'] as String?,
      photoUrl: map['photoUrl'] as String?,
      phoneNumber: map['phoneNumber'] as String?,
      emailVerified: map['emailVerified'] as bool? ?? false,
      createdAt: _parseTimestamp(map['createdAt']),
      lastLoginAt: _parseNullableTimestamp(map['lastLoginAt']),
      patientProfile:
          role == 'patient' ? _parsePatientProfile(map['profile']) : null,
      doctorProfile:
          role == 'doctor' ? _parseDoctorProfile(map['profile']) : null,
      companionProfile:
          role == 'companion' ? _parseCompanionProfile(map['profile']) : null,
      facilityProfile:
          role == 'facility' ? _parseFacilityProfile(map['profile']) : null,
    );
  }

  /// Converts to a map for Firestore.
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'role': role,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'phoneNumber': phoneNumber,
      'emailVerified': emailVerified,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt':
          lastLoginAt != null ? Timestamp.fromDate(lastLoginAt!) : null,
      'profile': _getProfileMap(),
    };
  }

  Map<String, dynamic>? _getProfileMap() {
    if (patientProfile != null) {
      return {
        'assignedDoctorId': patientProfile!.assignedDoctorId,
        'companionIds': patientProfile!.companionIds,
        'facilityId': patientProfile!.facilityId,
        'dateOfBirth': patientProfile!.dateOfBirth != null
            ? Timestamp.fromDate(patientProfile!.dateOfBirth!)
            : null,
        'gender': patientProfile!.gender,
        'bloodType': patientProfile!.bloodType,
        'medicalConditions': patientProfile!.medicalConditions,
        'allergies': patientProfile!.allergies,
      };
    }
    if (doctorProfile != null) {
      return {
        'licenseNumber': doctorProfile!.licenseNumber,
        'specialization': doctorProfile!.specialization,
        'facilityId': doctorProfile!.facilityId,
        'hospitalName': doctorProfile!.hospitalName,
        'yearsOfExperience': doctorProfile!.yearsOfExperience,
        'patientIds': doctorProfile!.patientIds,
        'isVerified': doctorProfile!.isVerified,
      };
    }
    if (companionProfile != null) {
      return {
        'patientIds': companionProfile!.patientIds,
        'relationshipType': companionProfile!.relationshipType,
        'canViewVitals': companionProfile!.canViewVitals,
        'canReceiveAlerts': companionProfile!.canReceiveAlerts,
      };
    }
    if (facilityProfile != null) {
      return {
        'registrationNumber': facilityProfile!.registrationNumber,
        'facilityType': facilityProfile!.facilityType,
        'address': facilityProfile!.address,
        'city': facilityProfile!.city,
        'country': facilityProfile!.country,
        'doctorIds': facilityProfile!.doctorIds,
        'patientIds': facilityProfile!.patientIds,
        'isVerified': facilityProfile!.isVerified,
      };
    }
    return null;
  }

  /// Creates UserModel from User entity.
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      role: user.role,
      displayName: user.displayName,
      photoUrl: user.photoUrl,
      phoneNumber: user.phoneNumber,
      emailVerified: user.emailVerified,
      createdAt: user.createdAt,
      lastLoginAt: user.lastLoginAt,
      patientProfile: user.patientProfile,
      doctorProfile: user.doctorProfile,
      companionProfile: user.companionProfile,
      facilityProfile: user.facilityProfile,
    );
  }

  static DateTime _parseTimestamp(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is String) {
      return DateTime.parse(value);
    }
    return DateTime.now();
  }

  static DateTime? _parseNullableTimestamp(dynamic value) {
    if (value == null) return null;
    return _parseTimestamp(value);
  }

  static PatientProfile? _parsePatientProfile(Map<String, dynamic>? map) {
    if (map == null) return const PatientProfile();
    return PatientProfile(
      assignedDoctorId: map['assignedDoctorId'] as String?,
      companionIds: List<String>.from(map['companionIds'] ?? []),
      facilityId: map['facilityId'] as String?,
      dateOfBirth: _parseNullableTimestamp(map['dateOfBirth']),
      gender: map['gender'] as String?,
      bloodType: map['bloodType'] as String?,
      medicalConditions: List<String>.from(map['medicalConditions'] ?? []),
      allergies: List<String>.from(map['allergies'] ?? []),
    );
  }

  static DoctorProfile? _parseDoctorProfile(Map<String, dynamic>? map) {
    if (map == null) return null;
    return DoctorProfile(
      licenseNumber: map['licenseNumber'] as String? ?? '',
      specialization: map['specialization'] as String? ?? '',
      facilityId: map['facilityId'] as String?,
      hospitalName: map['hospitalName'] as String?,
      yearsOfExperience: map['yearsOfExperience'] as int? ?? 0,
      patientIds: List<String>.from(map['patientIds'] ?? []),
      isVerified: map['isVerified'] as bool? ?? false,
    );
  }

  static CompanionProfile? _parseCompanionProfile(Map<String, dynamic>? map) {
    if (map == null) return const CompanionProfile();
    return CompanionProfile(
      patientIds: List<String>.from(map['patientIds'] ?? []),
      relationshipType: map['relationshipType'] as String? ?? 'Family',
      canViewVitals: map['canViewVitals'] as bool? ?? true,
      canReceiveAlerts: map['canReceiveAlerts'] as bool? ?? true,
    );
  }

  static FacilityProfile? _parseFacilityProfile(Map<String, dynamic>? map) {
    if (map == null) return null;
    return FacilityProfile(
      registrationNumber: map['registrationNumber'] as String? ?? '',
      facilityType: map['facilityType'] as String? ?? '',
      address: map['address'] as String? ?? '',
      city: map['city'] as String?,
      country: map['country'] as String?,
      doctorIds: List<String>.from(map['doctorIds'] ?? []),
      patientIds: List<String>.from(map['patientIds'] ?? []),
      isVerified: map['isVerified'] as bool? ?? false,
    );
  }
}
