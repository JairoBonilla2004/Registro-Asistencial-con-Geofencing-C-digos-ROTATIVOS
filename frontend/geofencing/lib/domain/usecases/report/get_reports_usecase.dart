import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../domain/entities/report.dart';
import '../../../domain/repositories/report_repository.dart';

class GetReportsUseCase {
  final ReportRepository repository;

  GetReportsUseCase(this.repository);

  Future<Either<Failure, List<Report>>> call() async {
    return await repository.getReports();
  }
}
