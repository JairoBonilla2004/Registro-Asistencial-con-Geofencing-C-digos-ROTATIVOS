import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../repositories/report_repository.dart';

class DeleteReportUseCase {
  final ReportRepository repository;

  DeleteReportUseCase(this.repository);

  Future<Either<Failure, void>> call(String reportId) async {
    return await repository.deleteReport(reportId);
  }
}
