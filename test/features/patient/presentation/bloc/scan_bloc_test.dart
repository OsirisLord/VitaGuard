import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:vitaguard/core/errors/failures.dart';
import 'package:vitaguard/features/patient/domain/entities/diagnosis_result.dart';
import 'package:vitaguard/features/patient/domain/repositories/analysis_repository.dart';
import 'package:vitaguard/features/patient/presentation/bloc/scan_bloc.dart';

import 'scan_bloc_test.mocks.dart';

@GenerateMocks([AnalysisRepository])
void main() {
  late ScanBloc bloc;
  late MockAnalysisRepository mockRepository;

  setUp(() {
    mockRepository = MockAnalysisRepository();
    bloc = ScanBloc(repository: mockRepository, patientId: 'test_patient');
  });

  tearDown(() {
    bloc.close();
  });

  final tImage = File('test.jpg');
  final tResult = DiagnosisResult(
    id: '1',
    patientId: 'test_patient',
    timestamp: DateTime.now(),
    imageUrl: 'url',
    diagnosis: 'Normal',
    confidence: 0.99,
    probabilities: const {},
  );

  test('initial state should be ScanInitial', () {
    expect(bloc.state, ScanInitial());
  });

  blocTest<ScanBloc, ScanState>(
    'emits [ScanAnalyzing, ScanSuccess] when ScanImagePicked is added and analysis succeeds',
    build: () {
      when(mockRepository.analyzeXray(image: anyNamed('image'), patientId: anyNamed('patientId')))
          .thenAnswer((_) async => Right(tResult));
      return bloc;
    },
    act: (bloc) => bloc.add(ScanImagePicked(tImage)),
    expect: () => [
      ScanAnalyzing(),
      ScanSuccess(result: tResult, image: tImage),
    ],
  );

  blocTest<ScanBloc, ScanState>(
    'emits [ScanAnalyzing, ScanFailure] when analysis fails',
    build: () {
      when(mockRepository.analyzeXray(image: anyNamed('image'), patientId: anyNamed('patientId')))
          .thenAnswer((_) async => const Left(ServerFailure(message: 'Analysis failed')));
      return bloc;
    },
    act: (bloc) => bloc.add(ScanImagePicked(tImage)),
    expect: () => [
      ScanAnalyzing(),
      const ScanFailure('Analysis failed'),
    ],
  );

  blocTest<ScanBloc, ScanState>(
    'emits [ScanSaving, ScanSaved, ScanInitial] when ScanResultSaved is added',
    build: () {
      // Mock repository save
      when(mockRepository.saveDiagnosis(any))
          .thenAnswer((_) async => const Right(null));
      // Pre-seed state with Success so specific event works (bloc expects previous state for image?)
      // Actually ScanResultSaved accesses (state as ScanSuccess).image
      // So we must seed the state!
      bloc.emit(ScanSuccess(result: tResult, image: tImage));
      return bloc;
    },
    act: (bloc) => bloc.add(ScanResultSaved(tResult)),
    expect: () => [
      ScanSaving(),
      ScanSaved(),
      ScanInitial(), // Due to the delayed reset in the bloc
    ],
    wait: const Duration(seconds: 3), // Wait for the delayed emit
  );
}
