import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/sync_result.dart';
import '../../repositories/attendance_repository.dart';

class SyncOfflineAttendancesUseCase {
  final AttendanceRepository repository;

  SyncOfflineAttendancesUseCase(this.repository);

  Future<Either<Failure, SyncResult>> call() async {
    return await repository.syncOfflineAttendances();
  }
}
