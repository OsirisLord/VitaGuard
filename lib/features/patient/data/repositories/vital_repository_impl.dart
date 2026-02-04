import 'dart:async';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/services/websocket_service.dart';
import '../entities/vital_sign.dart';

abstract class VitalRepository {
  Stream<Either<Failure, VitalSign>> get vitalSignStream;
  Future<void> connect(String deviceIp);
  Future<void> disconnect();
}

class VitalRepositoryImpl implements VitalRepository {
  final WebSocketService _socketService;
  final StreamController<Either<Failure, VitalSign>> _streamController =
      StreamController.broadcast();

  VitalRepositoryImpl(this._socketService) {
    _socketService.stream.listen(
      (data) {
        try {
          // Expecting raw string or bytes, trying to parse string
          final jsonMap = _socketService.parseData(data.toString());
          if (jsonMap != null) {
            final vital = VitalSign.fromJson(jsonMap);
            _streamController.add(Right(vital));
          } else {
            // Silently ignore parse errors or log them
            print('Invalid vital data format');
          }
        } catch (e) {
          _streamController.add(Left(ServerFailure(message: e.toString())));
        }
      },
      onError: (e) {
        _streamController.add(Left(ServerFailure(message: e.toString())));
      },
    );
  }

  @override
  Stream<Either<Failure, VitalSign>> get vitalSignStream =>
      _streamController.stream;

  @override
  Future<void> connect(String deviceIp) async {
    // Basic validation or formatting of IP could happen here
    final url = 'ws://$deviceIp:81';
    _socketService.connect(url);
  }

  @override
  Future<void> disconnect() async {
    _socketService.disconnect();
  }
}
