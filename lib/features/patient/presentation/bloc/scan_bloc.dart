import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/diagnosis_result.dart';
import '../../domain/repositories/analysis_repository.dart';

// --- Events ---

abstract class ScanEvent extends Equatable {
  const ScanEvent();

  @override
  List<Object?> get props => [];
}

class ScanImagePicked extends ScanEvent {
  final File image;

  const ScanImagePicked(this.image);

  @override
  List<Object?> get props => [image];
}

class ScanResultSaved extends ScanEvent {
  final DiagnosisResult result;

  const ScanResultSaved(this.result);

  @override
  List<Object?> get props => [result];
}

class ScanReset extends ScanEvent {}

// --- States ---

abstract class ScanState extends Equatable {
  const ScanState();

  @override
  List<Object?> get props => [];
}

class ScanInitial extends ScanState {}

class ScanAnalyzing extends ScanState {}

class ScanSuccess extends ScanState {
  final DiagnosisResult result;
  final File image;

  const ScanSuccess({required this.result, required this.image});

  @override
  List<Object?> get props => [result, image];
}

class ScanFailure extends ScanState {
  final String message;

  const ScanFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class ScanSaving extends ScanState {}

class ScanSaved extends ScanState {}

// --- BLoC ---

class ScanBloc extends Bloc<ScanEvent, ScanState> {
  final AnalysisRepository repository;
  final String patientId; // We need current user ID

  ScanBloc({
    required this.repository,
    required this.patientId,
  }) : super(ScanInitial()) {
    on<ScanImagePicked>(_onImagePicked);
    on<ScanResultSaved>(_onResultSaved);
    on<ScanReset>((event, emit) => emit(ScanInitial()));
  }

  Future<void> _onImagePicked(
    ScanImagePicked event,
    Emitter<ScanState> emit,
  ) async {
    emit(ScanAnalyzing());

    // 1. Analyze
    final resultOrFailure = await repository.analyzeXray(
      image: event.image,
      patientId: patientId,
    );

    resultOrFailure.fold(
      (failure) => emit(ScanFailure(failure.message)),
      (result) => emit(ScanSuccess(result: result, image: event.image)),
    );
  }

  Future<void> _onResultSaved(
    ScanResultSaved event,
    Emitter<ScanState> emit,
  ) async {
    final currentImage = (state as ScanSuccess).image; // Keep image reference
    emit(ScanSaving());

    final resultOrFailure = await repository.saveDiagnosis(event.result);

    resultOrFailure.fold(
      (failure) => emit(ScanFailure(failure.message)),
      (_) => emit(ScanSaved()),
    );
    
    // Reset after short delay or keep as saved
    await Future.delayed(const Duration(seconds: 2));
    emit(ScanInitial());
  }
}
