import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../repositories/report_repository.dart';

class DownloadReportUseCase {
  final ReportRepository repository;

  DownloadReportUseCase(this.repository);

  Future<Either<Failure, List<int>>> call(String reportId) async {
    return await repository.downloadReport(reportId);
  }
}
