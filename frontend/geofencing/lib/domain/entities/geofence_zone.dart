import 'package:equatable/equatable.dart';

/// Entidad de Zona de Geofencing
class GeofenceZone extends Equatable {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final double radiusMeters;

  const GeofenceZone({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.radiusMeters,
  });

  @override
  List<Object?> get props => [id, name, latitude, longitude, radiusMeters];
}
