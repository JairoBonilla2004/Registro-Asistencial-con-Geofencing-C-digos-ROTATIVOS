import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/attendance.dart';
import '../entities/attendance_history.dart';
import '../entities/location_validation.dart';
import '../entities/sync_result.dart';
import '../entities/sensor_data.dart';

abstract class AttendanceRepository {
  Future<Either<Failure, LocationValidation>> validateLocation({
    required String sessionId,
    required double latitude,
    required double longitude,
  });

  Future<Either<Failure, Attendance>> validateQR({
    required String token,
    required double latitude,
    required double longitude,
    String? deviceId,
    List<SensorData>? sensorData,
  });

  Future<Either<Failure, List<Attendance>>> getSessionAttendances(String sessionId);

  Future<Either<Failure, List<AttendanceHistory>>> getMyHistory({
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<Either<Failure, SyncResult>> syncOfflineAttendances();

  Future<Either<Failure, void>> saveOfflineAttendance({
    required String sessionId,
    required String token,
    required double latitude,
    required double longitude,
    required DateTime timestamp,
  });

  Future<List<Attendance>> getPendingAttendances();
}
