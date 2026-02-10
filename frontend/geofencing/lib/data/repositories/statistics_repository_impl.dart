import 'package:dartz/dartz.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/session_statistics.dart';
import '../../domain/entities/student_dashboard.dart';
import '../../domain/entities/teacher_dashboard.dart';
import '../../domain/repositories/statistics_repository.dart';
import '../datasources/remote/statistics_remote_datasource.dart';

class StatisticsRepositoryImpl implements StatisticsRepository {
  final StatisticsRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  StatisticsRepositoryImpl(this.remoteDataSource, this.networkInfo);

  @override
  Future<Either<Failure, dynamic>> getDashboard() async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getDashboard();
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
  Future<Either<Failure, StudentDashboard>> getStudentDashboard() async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getStudentDashboard();
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
  Future<Either<Failure, TeacherDashboard>> getTeacherDashboard() async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getTeacherDashboard();
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
  Future<Either<Failure, SessionStatistics>> getSessionStatistics(
      String sessionId) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getSessionStatistics(sessionId);
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
}
