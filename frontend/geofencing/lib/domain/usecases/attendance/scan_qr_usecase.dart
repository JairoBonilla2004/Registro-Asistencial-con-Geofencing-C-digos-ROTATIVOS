import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/attendance.dart';
import '../../entities/sensor_data.dart';
import '../../repositories/attendance_repository.dart';

class ScanQRUseCase {
  final AttendanceRepository repository;

  ScanQRUseCase(this.repository);

  Future<Either<Failure, Attendance>> call({
    required String token,
    required double latitude,
    required double longitude,
    String? deviceId,
    List<SensorData>? sensorData,
  }) async {
    if (token.isEmpty) {
      return Left(const ValidationFailure('Token QR inválido'));
    }

    if (latitude < -90 || latitude > 90) {
      return Left(const ValidationFailure('Latitud inválida'));
    }

    if (longitude < -180 || longitude > 180) {
      return Left(const ValidationFailure('Longitud inválida'));
    }

    return await repository.validateQR(
      token: token,
      latitude: latitude,
      longitude: longitude,
      deviceId: deviceId,
      sensorData: sensorData,
    );
  }
}
