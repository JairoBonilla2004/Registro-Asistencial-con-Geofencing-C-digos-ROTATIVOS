import 'dart:convert';
import '../../domain/entities/sensor_data.dart';

/// Model para datos de sensores
class SensorDataModel {
  final String type;
  final String value;
  final String deviceTime;

  const SensorDataModel({
    required this.type,
    required this.value,
    required this.deviceTime,
  });

  /// Convierte de Entity a Model
  factory SensorDataModel.fromEntity(SensorData entity) {
    return SensorDataModel(
      type: entity.type.name,
      value: entity.value,
      deviceTime: entity.deviceTime.toIso8601String(),
    );
  }

  /// Convierte a Entity
  SensorData toEntity() {
    return SensorData(
      type: SensorType.values.firstWhere((e) => e.name == type),
      value: value,
      deviceTime: DateTime.parse(deviceTime),
    );
  }

  /// Convierte a JSON para enviar al backend
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'value': value,
      'deviceTime': deviceTime,
    };
  }

  /// Crea desde JSON
  factory SensorDataModel.fromJson(Map<String, dynamic> json) {
    return SensorDataModel(
      type: json['type'] as String,
      value: json['value'] as String,
      deviceTime: json['deviceTime'] as String,
    );
  }

  @override
  String toString() => 'SensorDataModel(type: $type, deviceTime: $deviceTime)';
}
