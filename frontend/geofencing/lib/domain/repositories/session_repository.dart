import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/attendance_session.dart';
import '../entities/qr_token.dart';
import '../entities/session_statistics.dart';

abstract class SessionRepository {
  Future<Either<Failure, List<AttendanceSession>>> getActiveSessions();
  
  Future<Either<Failure, List<AttendanceSession>>> getTeacherSessions();

  Future<Either<Failure, AttendanceSession>> createSession({
    required String name,
    required String zoneId,
    required int qrRotationMinutes,
  });

  Future<Either<Failure, QRToken>> generateQRCode(String sessionId);

  Future<Either<Failure, void>> endSession(String sessionId);

  Future<Either<Failure, SessionStatistics>> getSessionStatistics(String sessionId);
}
