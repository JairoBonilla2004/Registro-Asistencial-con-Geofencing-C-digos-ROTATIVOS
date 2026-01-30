import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/device.dart';

abstract class DeviceRepository {
  Future<Either<Failure, Device>> registerDevice({
    required String deviceIdentifier,
    required String platform,
    required String fcmToken,
  });

  Future<Either<Failure, void>> updateFCMToken({
    required String deviceId,
    required String fcmToken,
  });

  Future<Either<Failure, void>> deactivateDevice({
    required String deviceId,
  });
}
