import 'package:equatable/equatable.dart';

/// Entity representing the result of an AI diagnosis.
class DiagnosisResult extends Equatable {
  final String id;
  final String patientId;
  final DateTime timestamp;
  final String imageUrl;
  final String diagnosis; // 'Normal' or 'Pneumonia'
  final double confidence;
  final Map<String, double> probabilities;
  final String? doctorNotes;
  final bool isVerified;

  const DiagnosisResult({
    required this.id,
    required this.patientId,
    required this.timestamp,
    required this.imageUrl,
    required this.diagnosis,
    required this.confidence,
    required this.probabilities,
    this.doctorNotes,
    this.isVerified = false,
  });

  @override
  List<Object?> get props => [
        id,
        patientId,
        timestamp,
        imageUrl,
        diagnosis,
        confidence,
        probabilities,
        doctorNotes,
        isVerified,
      ];
}
