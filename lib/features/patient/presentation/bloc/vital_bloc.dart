import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/vital_repository.dart';
import '../../domain/entities/vital_sign.dart';

// --- Events ---
abstract class VitalEvent extends Equatable {
  const VitalEvent();
  @override
  List<Object> get props => [];
}

class ConnectVitalDevice extends VitalEvent {
  final String ipAddress;
  const ConnectVitalDevice(this.ipAddress);
  @override
  List<Object> get props => [ipAddress];
}

class DisconnectVitalDevice extends VitalEvent {}

class VitalDataReceived extends VitalEvent {
  final VitalSign vitalSign;
  const VitalDataReceived(this.vitalSign);
  @override
  List<Object> get props => [vitalSign];
}

// --- States ---
abstract class VitalState extends Equatable {
  const VitalState();
  @override
  List<Object> get props => [];
}

class VitalInitial extends VitalState {}

class VitalConnecting extends VitalState {}

class VitalConnected extends VitalState {
  final List<VitalSign> history;
  final VitalSign current;

  const VitalConnected({
    required this.history,
    required this.current,
  });

  @override
  List<Object> get props => [history, current];
}

class VitalDisconnected extends VitalState {}

class VitalError extends VitalState {
  final String message;
  const VitalError(this.message);
  @override
  List<Object> get props => [message];
}

// --- BLoC ---
class VitalBloc extends Bloc<VitalEvent, VitalState> {
  final VitalRepository repository;
  StreamSubscription? _vitalSubscription;

  // Keep last 60 points for 1-minute history (assuming 1Hz)
  static const int _maxHistoryLength = 60;

  VitalBloc({required this.repository}) : super(VitalInitial()) {
    on<ConnectVitalDevice>(_onConnect);
    on<DisconnectVitalDevice>(_onDisconnect);
    on<VitalDataReceived>(_onDataReceived);
  }

  Future<void> _onConnect(
    ConnectVitalDevice event,
    Emitter<VitalState> emit,
  ) async {
    emit(VitalConnecting());
    try {
      await repository.connect(event.ipAddress);

      // Cancel existing subscription if any
      await _vitalSubscription?.cancel();

      _vitalSubscription = repository.vitalSignStream.listen(
        (failureOrVisual) {
          failureOrVisual.fold(
            (failure) => add(DisconnectVitalDevice()), // Or handle error
            (vital) => add(VitalDataReceived(vital)),
          );
        },
      );
    } catch (e) {
      emit(VitalError("Failed to connect: $e"));
    }
  }

  Future<void> _onDisconnect(
    DisconnectVitalDevice event,
    Emitter<VitalState> emit,
  ) async {
    await _vitalSubscription?.cancel();
    await repository.disconnect();
    emit(VitalDisconnected());
  }

  void _onDataReceived(
    VitalDataReceived event,
    Emitter<VitalState> emit,
  ) {
    final List<VitalSign> currentHistory;

    if (state is VitalConnected) {
      currentHistory = List.of((state as VitalConnected).history);
    } else {
      currentHistory = [];
    }

    currentHistory.add(event.vitalSign);
    if (currentHistory.length > _maxHistoryLength) {
      currentHistory.removeAt(0);
    }

    emit(VitalConnected(
      history: currentHistory,
      current: event.vitalSign,
    ));
  }

  @override
  Future<void> close() {
    _vitalSubscription?.cancel();
    repository.disconnect();
    return super.close();
  }
}
