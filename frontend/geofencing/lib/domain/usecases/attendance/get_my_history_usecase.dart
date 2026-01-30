import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/attendance_history.dart';
import '../../repositories/attendance_repository.dart';

class GetMyHistoryUseCase {
  final AttendanceRepository repository;

  GetMyHistoryUseCase(this.repository);

  Future<Either<Failure, List<AttendanceHistory>>> call({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (startDate != null && endDate != null && startDate.isAfter(endDate)) {
      return Left(const ValidationFailure('Fecha inicio debe ser anterior a fecha fin'));
    }

    return await repository.getMyHistory(
      startDate: startDate,
      endDate: endDate,
    );
  }
}
