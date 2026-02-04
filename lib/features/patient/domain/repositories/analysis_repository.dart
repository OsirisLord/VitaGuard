import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import 'diagnosis_result.dart';

/// Repository interface for X-ray analysis operations.
abstract class AnalysisRepository {
  /// Analyzes an X-ray image using the AI model.
  Future<Either<Failure, DiagnosisResult>> analyzeXray({
    required File image,
    required String patientId,
  });

  /// Saves the diagnosis result to the backend.
  Future<Either<Failure, void>> saveDiagnosis(DiagnosisResult result);

  /// Gets the diagnosis history for a patient.
  Future<Either<Failure, List<DiagnosisResult>>> getPatientHistory(
      String patientId);

  /// Gets a specific diagnosis by ID.
  Future<Either<Failure, DiagnosisResult>> getDiagnosisById(String id);
}
