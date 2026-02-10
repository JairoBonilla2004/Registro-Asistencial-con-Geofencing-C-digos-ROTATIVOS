import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/geofence_zone.dart';

part 'geofence_zone_model.g.dart';

@JsonSerializable()
class GeofenceZoneModel extends GeofenceZone {
  const GeofenceZoneModel({
    required super.id,
    required super.name,
    required super.latitude,
    required super.longitude,
    required super.radiusMeters,
  });

  factory GeofenceZoneModel.fromJson(Map<String, dynamic> json) =>
      _$GeofenceZoneModelFromJson(json);

  Map<String, dynamic> toJson() => _$GeofenceZoneModelToJson(this);

  GeofenceZone toEntity() => GeofenceZone(
        id: id,
        name: name,
        latitude: latitude,
        longitude: longitude,
        radiusMeters: radiusMeters,
      );
}
