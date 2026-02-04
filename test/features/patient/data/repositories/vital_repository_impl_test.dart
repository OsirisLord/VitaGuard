import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:vitaguard/core/services/websocket_service.dart';
import 'package:vitaguard/features/patient/data/repositories/vital_repository_impl.dart';
import 'package:vitaguard/features/patient/domain/entities/vital_sign.dart';

import 'vital_repository_impl_test.mocks.dart';

@GenerateMocks([WebSocketService])
void main() {
  late VitalRepositoryImpl repository;
  late MockWebSocketService mockWebSocketService;
  late StreamController<dynamic> websocketController;

  setUp(() {
    mockWebSocketService = MockWebSocketService();
    websocketController = StreamController<dynamic>();
    
    // Mock stream behavior
    when(mockWebSocketService.stream).thenAnswer((_) => websocketController.stream);
    
    repository = VitalRepositoryImpl(mockWebSocketService);
  });

  tearDown(() {
    websocketController.close();
  });

  const tIp = '192.168.1.100';
  const tVitalJson = '{"spo2": 98, "bpm": 75, "temp": 36.5}';
  final tVital = VitalSign(
    timestamp: DateTime.now(), // Repository creates new timestamp so we might need strict matchign
    spo2: 98,
    bpm: 75,
    temperature: 36.5,
  );

  test('should call connect on socket service', () async {
    // Act
    await repository.connect(tIp);
    
    // Assert
    verify(mockWebSocketService.connect('ws://$tIp:81'));
  });

  test('should emit VitalSign when valid JSON is received', () async {
    // Arrange
    // We need to mock parseData because repository uses it
    when(mockWebSocketService.parseData(any)).thenAnswer((realInvocation) {
      // Simple manual mock logic or use ArgumentCaptor if needed
      // But since we are mocking the service, we should mock this helper too
      // The implementation calls _socketService.parseData
      if (realInvocation.positionalArguments[0] == tVitalJson) {
         return {"spo2": 98, "bpm": 75, "temp": 36.5};
      }
      return null;
    });

    // Act
    expectLater(
      repository.vitalSignStream,
      emits(predicate<Either<dynamic, VitalSign>>((result) {
        return result.isRight() && result.getOrElse(() => throw 'error').spo2 == 98;
      })),
    );
    
    // Simulate connection first to ensure listeners are active if required by implementation
    // (Impl calls listen in constructor, so it should be fine)
    
    websocketController.add(tVitalJson);
  });
}
