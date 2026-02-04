import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/vital_sign.dart';

abstract class VitalRepository {
  Stream<Either<Failure, VitalSign>> get vitalSignStream;
  Future<void> connect(String deviceIp);
  Future<void> disconnect();
}
