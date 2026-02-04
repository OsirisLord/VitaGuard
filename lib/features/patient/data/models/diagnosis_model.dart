import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/diagnosis_result.dart';

/// Data model for DiagnosisResult with Firestore serialization.
class DiagnosisModel extends DiagnosisResult {
  const DiagnosisModel({
    required super.id,
    required super.patientId,
    required super.timestamp,
    required super.imageUrl,
    required super.diagnosis,
    required super.confidence,
    required super.probabilities,
    super.doctorNotes,
    super.isVerified,
  });

  factory DiagnosisModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DiagnosisModel.fromMap(data, doc.id);
  }

  factory DiagnosisModel.fromMap(Map<String, dynamic> map, String id) {
    return DiagnosisModel(
      id: id,
      patientId: map['patientId'] as String,
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      imageUrl: map['imageUrl'] as String,
      diagnosis: map['diagnosis'] as String,
      confidence: (map['confidence'] as num).toDouble(),
      probabilities: Map<String, double>.from(map['probabilities'] ?? {}),
      doctorNotes: map['doctorNotes'] as String?,
      isVerified: map['isVerified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'patientId': patientId,
      'timestamp': Timestamp.fromDate(timestamp),
      'imageUrl': imageUrl,
      'diagnosis': diagnosis,
      'confidence': confidence,
      'probabilities': probabilities,
      'doctorNotes': doctorNotes,
      'isVerified': isVerified,
    };
  }

  factory DiagnosisModel.fromEntity(DiagnosisResult result) {
    return DiagnosisModel(
      id: result.id,
      patientId: result.patientId,
      timestamp: result.timestamp,
      imageUrl: result.imageUrl,
      diagnosis: result.diagnosis,
      confidence: result.confidence,
      probabilities: result.probabilities,
      doctorNotes: result.doctorNotes,
      isVerified: result.isVerified,
    );
  }
}
