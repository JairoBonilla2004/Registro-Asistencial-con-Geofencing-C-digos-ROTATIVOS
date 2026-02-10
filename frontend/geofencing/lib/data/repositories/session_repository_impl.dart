import 'package:dartz/dartz.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/attendance_session.dart';
import '../../domain/entities/qr_token.dart';
import '../../domain/entities/session_statistics.dart';
import '../../domain/repositories/session_repository.dart';
import '../datasources/remote/session_remote_datasource.dart';
import '../datasources/remote/statistics_remote_datasource.dart';

class SessionRepositoryImpl implements SessionRepository {
  final SessionRemoteDataSource remoteDataSource;
  final StatisticsRemoteDataSource statisticsDataSource;
  final NetworkInfo networkInfo;

  SessionRepositoryImpl(
    this.remoteDataSource,
    this.statisticsDataSource,
    this.networkInfo,
  );

  @override
  Future<Either<Failure, List<AttendanceSession>>> getActiveSessions() async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getActiveSessions();
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
  Future<Either<Failure, List<AttendanceSession>>> getTeacherSessions() async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getTeacherSessions();
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
  Future<Either<Failure, AttendanceSession>> createSession({
    required String name,
    required String zoneId,
    required int qrRotationMinutes,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.createSession(
          name: name,
          geofenceId: zoneId,
          startTime: DateTime.now(),
        );
        return Right(result.toEntity());
      } on ValidationException catch (e) {
        return Left(ValidationFailure(e.message, e.code));
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
  Future<Either<Failure, QRToken>> generateQRCode(String sessionId) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.generateQRCode(sessionId);
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
  Future<Either<Failure, void>> endSession(String sessionId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.endSession(sessionId);
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

  @override
  Future<Either<Failure, SessionStatistics>> getSessionStatistics(String sessionId) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await statisticsDataSource.getSessionStatistics(sessionId);
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
