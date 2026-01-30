import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/attendance_session.dart';
import '../../repositories/session_repository.dart';

class GetActiveSessionsUseCase {
  final SessionRepository repository;

  GetActiveSessionsUseCase(this.repository);

  Future<Either<Failure, List<AttendanceSession>>> call() async {
    return await repository.getActiveSessions();
  }
}
