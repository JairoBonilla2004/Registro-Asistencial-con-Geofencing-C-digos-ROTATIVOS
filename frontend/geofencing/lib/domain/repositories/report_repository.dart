import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/report.dart';

abstract class ReportRepository {
  Future<Either<Failure, Report>> generateReport({
    required String reportType,
    DateTime? startDate,
    DateTime? endDate,
    String? sessionId,
  });

  Future<Either<Failure, List<Report>>> getReports();

  Future<Either<Failure, List<int>>> downloadReport(String reportId);
  
  Future<Either<Failure, void>> deleteReport(String reportId);
}
