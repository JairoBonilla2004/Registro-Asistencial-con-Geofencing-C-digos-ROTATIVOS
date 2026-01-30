import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/geofence_zone.dart';

abstract class GeofenceRepository {
  Future<Either<Failure, List<GeofenceZone>>> getAllZones();

  Future<Either<Failure, GeofenceZone>> getZoneById(String zoneId);

  Future<Either<Failure, GeofenceZone>> createZone({
    required String name,
    required double latitude,
    required double longitude,
    required double radiusMeters,
  });

  Future<Either<Failure, GeofenceZone>> updateZone({
    required String zoneId,
    String? name,
    double? radiusMeters,
  });

  Future<Either<Failure, void>> deleteZone(String zoneId);
}
