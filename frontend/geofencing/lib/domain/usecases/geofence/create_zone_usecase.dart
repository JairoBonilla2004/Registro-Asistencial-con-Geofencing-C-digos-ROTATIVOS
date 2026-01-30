import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/geofence_zone.dart';
import '../../repositories/geofence_repository.dart';

class CreateZoneUseCase {
  final GeofenceRepository repository;

  CreateZoneUseCase(this.repository);

  Future<Either<Failure, GeofenceZone>> call({
    required String name,
    required double latitude,
    required double longitude,
    required double radiusMeters,
  }) async {
    return await repository.createZone(
      name: name,
      latitude: latitude,
      longitude: longitude,
      radiusMeters: radiusMeters,
    );
  }
}
