import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/device.dart';

part 'device_model.g.dart';

@JsonSerializable()
class DeviceModel {
  final String deviceId;
  final String deviceIdentifier;
  final String platform;
  final String? fcmToken;
  final bool active;
  final DateTime registeredAt;

  const DeviceModel({
    required this.deviceId,
    required this.deviceIdentifier,
    required this.platform,
    this.fcmToken,
    required this.active,
    required this.registeredAt,
  });

  factory DeviceModel.fromJson(Map<String, dynamic> json) =>
      _$DeviceModelFromJson(json);

  Map<String, dynamic> toJson() => _$DeviceModelToJson(this);

  Device toEntity() {
    return Device(
      deviceId: deviceId,
      deviceIdentifier: deviceIdentifier,
      platform: platform,
      fcmToken: fcmToken,
      active: active,
      registeredAt: registeredAt,
    );
  }
}
