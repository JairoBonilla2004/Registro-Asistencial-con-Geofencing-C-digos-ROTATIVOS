import 'package:equatable/equatable.dart';

/// Entidad de Validación de Ubicación
class LocationValidation extends Equatable {
  final bool withinCampus;
  final NearestZone? nearestZone;
  final List<ZoneDistance>? allZones;

  const LocationValidation({
    required this.withinCampus,
    this.nearestZone,
    this.allZones,
  });

  @override
  List<Object?> get props => [withinCampus, nearestZone, allZones];
}

/// Entidad de Zona Más Cercana
class NearestZone extends Equatable {
  final String id;
  final String name;
  final double distance;
  final bool withinZone;

  const NearestZone({
    required this.id,
    required this.name,
    required this.distance,
    required this.withinZone,
  });

  @override
  List<Object?> get props => [id, name, distance, withinZone];
}

/// Entidad de Distancia a Zona
class ZoneDistance extends Equatable {
  final String id;
  final String name;
  final double distance;
  final bool withinZone;

  const ZoneDistance({
    required this.id,
    required this.name,
    required this.distance,
    required this.withinZone,
  });

  @override
  List<Object?> get props => [id, name, distance, withinZone];
}
