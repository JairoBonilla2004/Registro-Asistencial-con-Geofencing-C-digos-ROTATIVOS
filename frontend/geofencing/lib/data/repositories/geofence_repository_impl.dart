import 'package:dartz/dartz.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/geofence_zone.dart';
import '../../domain/repositories/geofence_repository.dart';
import '../datasources/remote/geofence_remote_datasource.dart';

class GeofenceRepositoryImpl implements GeofenceRepository {
  final GeofenceRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  GeofenceRepositoryImpl(this.remoteDataSource, this.networkInfo);

  @override
  Future<Either<Failure, List<GeofenceZone>>> getAllZones() async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getZones();
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
  Future<Either<Failure, GeofenceZone>> getZoneById(String zoneId) async {
    if (await networkInfo.isConnected) {
      try {
        final zones = await remoteDataSource.getZones();
        final zone = zones.firstWhere(
          (z) => z.id == zoneId,
          orElse: () => throw ServerException('Zone not found', '404'),
        );
        return Right(zone.toEntity());
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
  Future<Either<Failure, GeofenceZone>> createZone({
    required String name,
    required double latitude,
    required double longitude,
    required double radiusMeters,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.createZone(
          name: name,
          latitude: latitude,
          longitude: longitude,
          radiusMeters: radiusMeters,
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
  Future<Either<Failure, GeofenceZone>> updateZone({
    required String zoneId,
    String? name,
    double? radiusMeters,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.updateZone(
          zoneId: zoneId,
          name: name,
          radiusMeters: radiusMeters,
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
  Future<Either<Failure, void>> deleteZone(String zoneId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteZone(zoneId);
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
