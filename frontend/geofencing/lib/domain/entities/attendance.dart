import 'package:equatable/equatable.dart';

/// Entidad de Asistencia
class Attendance extends Equatable {
  final String attendanceId;
  final String sessionId;
  final String studentId;
  final String? studentName;
  final String? teacherName;
  final String? zoneName;
  final DateTime deviceTime;
  final DateTime serverTime;
  final bool withinGeofence;
  final double latitude;
  final double longitude;
  final String? sensorStatus;
  final int? trustScore;
  final bool isSynced;
  final String? syncDelay;
  final String? note;

  const Attendance({
    required this.attendanceId,
    required this.sessionId,
    required this.studentId,
    this.studentName,
    this.teacherName,
    this.zoneName,
    required this.deviceTime,
    required this.serverTime,
    required this.withinGeofence,
    required this.latitude,
    required this.longitude,
    this.sensorStatus,
    this.trustScore,
    required this.isSynced,
    this.syncDelay,
    this.note,
  });

  @override
  List<Object?> get props => [
        attendanceId,
        sessionId,
        studentId,
        studentName,
        teacherName,
        zoneName,
        deviceTime,
        serverTime,
        withinGeofence,
        latitude,
        longitude,
        sensorStatus,
        trustScore,
        isSynced,
        syncDelay,
        note,
      ];
}
