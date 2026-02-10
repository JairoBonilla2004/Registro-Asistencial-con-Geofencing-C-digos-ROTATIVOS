import 'package:dartz/dartz.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/device.dart';
import '../../domain/repositories/device_repository.dart';
import '../datasources/remote/device_remote_datasource.dart';

class DeviceRepositoryImpl implements DeviceRepository {
  final DeviceRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  DeviceRepositoryImpl(this.remoteDataSource, this.networkInfo);

  @override
  Future<Either<Failure, Device>> registerDevice({
    required String deviceIdentifier,
    required String platform,
    required String fcmToken,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.registerDevice(
          deviceIdentifier: deviceIdentifier,
          platform: platform,
          fcmToken: fcmToken,
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
  Future<Either<Failure, void>> updateFCMToken({
    required String deviceId,
    required String fcmToken,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.updateFCMToken(
          deviceId: deviceId,
          fcmToken: fcmToken,
        );
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
  Future<Either<Failure, void>> deactivateDevice({
    required String deviceId,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deactivateDevice(deviceId: deviceId);
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
