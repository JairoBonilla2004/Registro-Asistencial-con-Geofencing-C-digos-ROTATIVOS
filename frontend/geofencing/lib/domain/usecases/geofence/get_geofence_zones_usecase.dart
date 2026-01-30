import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/geofence_zone.dart';
import '../../repositories/geofence_repository.dart';

class GetGeofenceZonesUseCase {
  final GeofenceRepository repository;

  GetGeofenceZonesUseCase(this.repository);

  Future<Either<Failure, List<GeofenceZone>>> call() async {
    return await repository.getAllZones();
  }
}
