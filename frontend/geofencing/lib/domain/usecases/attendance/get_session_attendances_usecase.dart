import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/attendance.dart';
import '../../repositories/attendance_repository.dart';

class GetSessionAttendancesUseCase {
  final AttendanceRepository repository;

  GetSessionAttendancesUseCase(this.repository);

  Future<Either<Failure, List<Attendance>>> call(String sessionId) async {
    if (sessionId.isEmpty) {
      return Left(const ValidationFailure('ID de sesión requerido'));
    }

    return await repository.getSessionAttendances(sessionId);
  }
}
