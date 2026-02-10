import 'package:dartz/dartz.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/remote/notification_remote_datasource.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  NotificationRepositoryImpl(this.remoteDataSource, this.networkInfo);

  @override
  Future<Either<Failure, List<AppNotification>>> getUnreadNotifications() async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getUnreadNotifications();
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
  Future<Either<Failure, void>> markAsRead(String notificationId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.markAsRead(notificationId);
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
  Future<Either<Failure, void>> markAllAsRead() async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.markAllAsRead();
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
