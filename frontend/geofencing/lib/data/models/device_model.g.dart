// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeviceModel _$DeviceModelFromJson(Map<String, dynamic> json) => DeviceModel(
      deviceId: json['deviceId'] as String,
      deviceIdentifier: json['deviceIdentifier'] as String,
      platform: json['platform'] as String,
      fcmToken: json['fcmToken'] as String?,
      active: json['active'] as bool,
      registeredAt: DateTime.parse(json['registeredAt'] as String),
    );

Map<String, dynamic> _$DeviceModelToJson(DeviceModel instance) =>
    <String, dynamic>{
      'deviceId': instance.deviceId,
      'deviceIdentifier': instance.deviceIdentifier,
      'platform': instance.platform,
      'fcmToken': instance.fcmToken,
      'active': instance.active,
      'registeredAt': instance.registeredAt.toIso8601String(),
    };
