// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_validation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LocationValidationModel _$LocationValidationModelFromJson(
        Map<String, dynamic> json) =>
    LocationValidationModel(
      withinCampus: json['withinCampus'] as bool,
      nearestZone: json['nearestZone'] as Map<String, dynamic>?,
      allZones: (json['allZones'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
    );

Map<String, dynamic> _$LocationValidationModelToJson(
        LocationValidationModel instance) =>
    <String, dynamic>{
      'withinCampus': instance.withinCampus,
      'nearestZone': instance.nearestZone,
      'allZones': instance.allZones,
    };
