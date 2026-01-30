import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/geofence_zone.dart';
import '../../repositories/geofence_repository.dart';

class GetAllZonesUseCase {
  final GeofenceRepository repository;

  GetAllZonesUseCase(this.repository);

  Future<Either<Failure, List<GeofenceZone>>> call() async {
    return await repository.getAllZones();
  }
}
