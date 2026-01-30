import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../domain/entities/report.dart';
import '../../../domain/repositories/report_repository.dart';

class GenerateReportUseCase {
  final ReportRepository repository;

  GenerateReportUseCase(this.repository);

  Future<Either<Failure, Report>> call({
    required String reportType,
    DateTime? startDate,
    DateTime? endDate,
    String? sessionId,
  }) async {
    return await repository.generateReport(
      reportType: reportType,
      startDate: startDate,
      endDate: endDate,
      sessionId: sessionId,
    );
  }
}
