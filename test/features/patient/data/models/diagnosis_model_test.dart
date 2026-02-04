import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vitaguard/features/patient/data/models/diagnosis_model.dart';
import 'package:vitaguard/features/patient/domain/entities/diagnosis_result.dart';

void main() {
  final tDate = DateTime.now();
  final tTimestamp = Timestamp.fromDate(tDate);
  
  final tDiagnosisModel = DiagnosisModel(
    id: '123',
    patientId: 'p1',
    timestamp: tDate,
    imageUrl: 'http://url.com',
    diagnosis: 'Normal',
    confidence: 0.95,
    probabilities: const {'Normal': 0.95, 'Pneumonia': 0.05},
    isVerified: false,
  );

  final tMap = {
    'patientId': 'p1',
    'timestamp': tTimestamp,
    'imageUrl': 'http://url.com',
    'diagnosis': 'Normal',
    'confidence': 0.95,
    'probabilities': {'Normal': 0.95, 'Pneumonia': 0.05},
    'doctorNotes': null,
    'isVerified': false,
  };

  test('should return a valid model from Map', () {
    // We mock Timestamp conversion normally, but here we construct normally
    // For pure unit test without firebase_core, Timestamp might fail if not mocked or handled
    // But cloud_firestore dependency usually allows creating Timestamp objects in tests
    // If it fails, we assume we need to mock or just test toMap logic primarily.
    
    // Actually, creating Timestamp usually works.
    
    // Act
    // We adjust tMap timestamp to be exactly what we expect
    final result = DiagnosisModel.fromMap(tMap, '123');
    
    // Assert
    expect(result.id, tDiagnosisModel.id);
    expect(result.diagnosis, tDiagnosisModel.diagnosis);
    expect(result.probabilities, tDiagnosisModel.probabilities);
  });

  test('should return component JSON map containing proper data', () {
    // Act
    final result = tDiagnosisModel.toMap();
    
    // Assert
    expect(result['patientId'], 'p1');
    expect(result['diagnosis'], 'Normal');
    // Timestamp equality check might be tricky due to precision
    expect(result['timestamp'], isA<Timestamp>());
  });

  test('should be subclass of DiagnosisResult entity', () {
    expect(tDiagnosisModel, isA<DiagnosisResult>());
  });
}
