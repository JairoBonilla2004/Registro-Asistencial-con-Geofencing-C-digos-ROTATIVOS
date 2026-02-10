import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/location_validation.dart';

part 'location_validation_model.g.dart';

@JsonSerializable()
class LocationValidationModel {
  final bool withinCampus;
  final Map<String, dynamic>? nearestZone;
  final List<Map<String, dynamic>>? allZones;

  const LocationValidationModel({
    required this.withinCampus,
    this.nearestZone,
    this.allZones,
  });

  factory LocationValidationModel.fromJson(Map<String, dynamic> json) =>
      _$LocationValidationModelFromJson(json);

  Map<String, dynamic> toJson() => _$LocationValidationModelToJson(this);

  LocationValidation toEntity() {
    NearestZone? nearest;
    if (nearestZone != null) {
      nearest = NearestZone(
        id: nearestZone!['id'] as String,
        name: nearestZone!['name'] as String,
        distance: (nearestZone!['distance'] as num).toDouble(),
        withinZone: nearestZone!['withinZone'] as bool,
      );
    }

    List<ZoneDistance>? zones;
    if (allZones != null) {
      zones = allZones!.map((z) => ZoneDistance(
        id: z['id'] as String,
        name: z['name'] as String,
        distance: (z['distance'] as num).toDouble(),
        withinZone: z['withinZone'] as bool,
      )).toList();
    }

    return LocationValidation(
      withinCampus: withinCampus,
      nearestZone: nearest,
      allZones: zones,
    );
  }
}
