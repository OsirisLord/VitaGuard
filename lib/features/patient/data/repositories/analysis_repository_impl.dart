import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/services/tflite_service.dart';
import '../../domain/entities/diagnosis_result.dart';
import '../../domain/repositories/analysis_repository.dart';
import '../models/diagnosis_model.dart';

class AnalysisRepositoryImpl implements AnalysisRepository {
  final TfliteService tfliteService;
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;
  final NetworkInfo networkInfo;

  AnalysisRepositoryImpl({
    required this.tfliteService,
    required this.firestore,
    required this.storage,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, DiagnosisResult>> analyzeXray({
    required File image,
    required String patientId,
  }) async {
    try {
      // 1. Run inference locally (doesn't need internet)
      final results = await tfliteService.analyzeImage(image);

      // Find the class with highest probability
      String diagnosis = 'Normal';
      double confidence = 0.0;

      results.forEach((key, value) {
        if (value > confidence) {
          confidence = value;
          diagnosis = key;
        }
      });

      // 2. Upload image if connected
      String imageUrl = '';
      if (await networkInfo.isConnected) {
        try {
          final ref = storage
              .ref()
              .child('xrays/$patientId/${DateTime.now().millisecondsSinceEpoch}.jpg');
          await ref.putFile(image);
          imageUrl = await ref.getDownloadURL();
        } catch (e) {
          // If upload fails, we still want to return the local analysis result
          print('Failed to upload image: $e');
        }
      }

      final result = DiagnosisResult(
        id: const Uuid().v4(),
        patientId: patientId,
        timestamp: DateTime.now(),
        imageUrl: imageUrl,
        diagnosis: diagnosis,
        confidence: confidence,
        probabilities: results,
      );

      return Right(result);
    } on ModelException catch (e) {
      return Left(ModelFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveDiagnosis(DiagnosisResult result) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final model = DiagnosisModel.fromEntity(result);
      await firestore
          .collection('diagnoses')
          .doc(result.id)
          .set(model.toMap());
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<DiagnosisResult>>> getPatientHistory(
      String patientId) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final snapshot = await firestore
          .collection('diagnoses')
          .where('patientId', isEqualTo: patientId)
          .orderBy('timestamp', descending: true)
          .get();

      final results = snapshot.docs
          .map((doc) => DiagnosisModel.fromFirestore(doc))
          .toList();

      return Right(results);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, DiagnosisResult>> getDiagnosisById(String id) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final doc = await firestore.collection('diagnoses').doc(id).get();
      if (!doc.exists) {
        return const Left(ServerFailure(message: 'Diagnosis not found'));
      }
      return Right(DiagnosisModel.fromFirestore(doc));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
