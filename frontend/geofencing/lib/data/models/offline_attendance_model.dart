import 'dart:convert';
import 'package:hive/hive.dart';
import 'sensor_data_model.dart';

part 'offline_attendance_model.g.dart';

/// Modelo para Asistencia Offline en Hive
@HiveType(typeId: 0)
class OfflineAttendanceModel extends HiveObject {
  @HiveField(0)
  String tempId;

  @HiveField(1)
  String token;

  @HiveField(2)
  String? sessionId;

  @HiveField(3)
  double latitude;

  @HiveField(4)
  double longitude;

  @HiveField(5)
  DateTime deviceTime;

  @HiveField(6)
  String sensorDataJson; // Almacenar como JSON string para Hive

  @HiveField(7)
  bool isSynced;

  @HiveField(8)
  String? serverId;

  @HiveField(9)
  DateTime createdAt;

  OfflineAttendanceModel({
    required this.tempId,
    required this.token,
    this.sessionId,
    required this.latitude,
    required this.longitude,
    required this.deviceTime,
    required this.sensorDataJson,
    this.isSynced = false,
    this.serverId,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'tempId': tempId,
        'token': token,
        'sessionId': sessionId,
        'latitude': latitude,
        'longitude': longitude,
        'deviceTime': deviceTime.toIso8601String(),
        'sensorData': _parseSensorDataToList(),
      };

  /// Convierte el JSON string a lista de SensorDataModel
  List<Map<String, dynamic>> _parseSensorDataToList() {
    try {
      if (sensorDataJson.isEmpty) return [];
      
      final decoded = jsonDecode(sensorDataJson);
      if (decoded is List) {
        return List<Map<String, dynamic>>.from(decoded);
      }
      return [];
    } catch (e) {
      print('Error parsing sensor data: $e');
      return [];
    }
  }

  /// Crea JSON string desde lista de SensorData
  static String encodeSensorData(List<dynamic> sensorDataList) {
    try {
      if (sensorDataList.isEmpty) return '[]';
      
      final jsonList = sensorDataList.map((data) {
        if (data is Map<String, dynamic>) {
          return data;
        } else if (data is SensorDataModel) {
          return data.toJson();
        }
        return null;
      }).where((item) => item != null).toList();
      
      return jsonEncode(jsonList);
    } catch (e) {
      print('Error encoding sensor data: $e');
      return '[]';
    }
  }
}
