import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/student_dashboard.dart';
import '../../entities/teacher_dashboard.dart';
import '../../repositories/statistics_repository.dart';

class GetDashboardUseCase {
  final StatisticsRepository repository;

  GetDashboardUseCase(this.repository);

  Future<Either<Failure, dynamic>> call() async {
    return await repository.getDashboard();
  }
}
