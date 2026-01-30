import 'package:equatable/equatable.dart';

/// Entidad de Sesión de Asistencia
class AttendanceSession extends Equatable {
  final String sessionId;
  final String name;
  final String teacherId;
  final String teacherName;
  final String geofenceId;
  final String zoneName;
  final double zoneLatitude;
  final double zoneLongitude;
  final double radiusMeters;
  final DateTime startTime;
  final DateTime? endTime;
  final bool active;
  final bool hasActiveQR;
  final int? totalAttendances;

  const AttendanceSession({
    required this.sessionId,
    required this.name,
    required this.teacherId,
    required this.teacherName,
    required this.geofenceId,
    required this.zoneName,
    required this.zoneLatitude,
    required this.zoneLongitude,
    required this.radiusMeters,
    required this.startTime,
    this.endTime,
    required this.active,
    required this.hasActiveQR,
    this.totalAttendances,
  });

  @override
  List<Object?> get props => [
        sessionId,
        name,
        teacherId,
        teacherName,
        geofenceId,
        zoneName,
        zoneLatitude,
        zoneLongitude,
        radiusMeters,
        startTime,
        endTime,
        active,
        hasActiveQR,
        totalAttendances,
      ];
}
