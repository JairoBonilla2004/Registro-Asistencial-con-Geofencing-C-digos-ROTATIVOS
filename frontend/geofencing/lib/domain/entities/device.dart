import 'package:equatable/equatable.dart';

/// Entidad de Dispositivo
class Device extends Equatable {
  final String deviceId;
  final String deviceIdentifier;
  final String platform;
  final String? fcmToken;
  final bool active;
  final DateTime registeredAt;

  const Device({
    required this.deviceId,
    required this.deviceIdentifier,
    required this.platform,
    this.fcmToken,
    required this.active,
    required this.registeredAt,
  });

  @override
  List<Object?> get props => [deviceId, deviceIdentifier, platform, fcmToken, active, registeredAt];
}
