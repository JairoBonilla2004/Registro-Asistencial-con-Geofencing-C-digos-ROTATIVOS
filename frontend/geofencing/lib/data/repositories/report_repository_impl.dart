import 'package:dartz/dartz.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/report.dart';
import '../../domain/repositories/report_repository.dart';
import '../datasources/remote/report_remote_datasource.dart';

class ReportRepositoryImpl implements ReportRepository {
  final ReportRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  ReportRepositoryImpl(this.remoteDataSource, this.networkInfo);

  @override
  Future<Either<Failure, Report>> generateReport({
    required String reportType,
    DateTime? startDate,
    DateTime? endDate,
    String? sessionId,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.generateReport(
          reportType: reportType,
          startDate: startDate,
          endDate: endDate,
          sessionId: sessionId,
        );
        return Right(result.toEntity());
      } on AuthException catch (e) {
        return Left(AuthFailure(e.message, e.code));
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message, e.code));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(e.message));
      } catch (e) {
        return Left(UnknownFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, List<Report>>> getReports() async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getReports();
        return Right(result.map((model) => model.toEntity()).toList());
      } on AuthException catch (e) {
        return Left(AuthFailure(e.message, e.code));
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message, e.code));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(e.message));
      } catch (e) {
        return Left(UnknownFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, List<int>>> downloadReport(String reportId) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.downloadReport(reportId);
        return Right(result);
      } on AuthException catch (e) {
        return Left(AuthFailure(e.message, e.code));
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message, e.code));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(e.message));
      } catch (e) {
        return Left(UnknownFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteReport(String reportId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteReport(reportId);
        return const Right(null);
      } on AuthException catch (e) {
        return Left(AuthFailure(e.message, e.code));
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message, e.code));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(e.message));
      } catch (e) {
        return Left(UnknownFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure());
    }
  }
}
