import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/attendance_session.dart';
import '../../repositories/session_repository.dart';

class GetTeacherSessionsUseCase {
  final SessionRepository repository;

  GetTeacherSessionsUseCase(this.repository);

  Future<Either<Failure, List<AttendanceSession>>> call() async {
    return await repository.getTeacherSessions();
  }
}
