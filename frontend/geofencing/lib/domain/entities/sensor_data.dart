import 'package:equatable/equatable.dart';

/// Tipos de sensores soportados
enum SensorType {
  COMPASS,
  PROXIMITY,
  ACCELEROMETER,
  GYROSCOPE,
}

/// Entity para datos de sensores
class SensorData extends Equatable {
  final SensorType type;
  final String value; // JSON string con los valores del sensor
  final DateTime deviceTime;

  const SensorData({
    required this.type,
    required this.value,
    required this.deviceTime,
  });

  @override
  List<Object?> get props => [type, value, deviceTime];

  @override
  String toString() => 'SensorData(type: $type, deviceTime: $deviceTime)';
}
