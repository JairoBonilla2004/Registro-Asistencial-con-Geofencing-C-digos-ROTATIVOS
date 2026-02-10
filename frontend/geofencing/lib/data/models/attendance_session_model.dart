import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/attendance_session.dart';

part 'attendance_session_model.g.dart';

@JsonSerializable()
class AttendanceSessionModel extends AttendanceSession {
  const AttendanceSessionModel({
    required super.sessionId,
    required super.name,
    required super.teacherId,
    required super.teacherName,
    required super.geofenceId,
    required super.zoneName,
    required super.zoneLatitude,
    required super.zoneLongitude,
    required super.radiusMeters,
    required super.startTime,
    super.endTime,
    required super.active,
    required super.hasActiveQR,
    super.totalAttendances,
  });

  // Factory con manejo de null para evitar errores de cast
  factory AttendanceSessionModel.fromJsonSafe(Map<String, dynamic> json) {
    return AttendanceSessionModel(
      sessionId: json['sessionId'] as String,
      name: json['name'] as String? ?? 'Sin nombre',
      teacherId: json['teacherId'] as String,
      teacherName: json['teacherName'] as String,
      geofenceId: json['geofenceId'] as String,
      zoneName: json['zoneName'] as String,
      zoneLatitude: (json['zoneLatitude'] as num?)?.toDouble() ?? 0.0,
      zoneLongitude: (json['zoneLongitude'] as num?)?.toDouble() ?? 0.0,
      radiusMeters: (json['radiusMeters'] as num?)?.toDouble() ?? 0.0,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime'] as String) : null,
      active: json['active'] as bool? ?? false,
      hasActiveQR: json['hasActiveQR'] as bool? ?? false,
      totalAttendances: json['totalAttendances'] as int?,
    );
  }

  // Usar fromJsonSafe en lugar del generado automáticamente
  factory AttendanceSessionModel.fromJson(Map<String, dynamic> json) =>
      AttendanceSessionModel.fromJsonSafe(json);

  Map<String, dynamic> toJson() => _$AttendanceSessionModelToJson(this);

  AttendanceSession toEntity() => AttendanceSession(
        sessionId: sessionId,
        name: name,
        teacherId: teacherId,
        teacherName: teacherName,
        geofenceId: geofenceId,
        zoneName: zoneName,
        zoneLatitude: zoneLatitude,
        zoneLongitude: zoneLongitude,
        radiusMeters: radiusMeters,
        startTime: startTime,
        endTime: endTime,
        active: active,
        hasActiveQR: hasActiveQR,
        totalAttendances: totalAttendances,
      );
}
