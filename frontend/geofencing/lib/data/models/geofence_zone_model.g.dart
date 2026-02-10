// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'geofence_zone_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GeofenceZoneModel _$GeofenceZoneModelFromJson(Map<String, dynamic> json) =>
    GeofenceZoneModel(
      id: json['id'] as String,
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      radiusMeters: (json['radiusMeters'] as num).toDouble(),
    );

Map<String, dynamic> _$GeofenceZoneModelToJson(GeofenceZoneModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'radiusMeters': instance.radiusMeters,
    };
