import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/attendance.dart';

part 'attendance_model.g.dart';

@JsonSerializable()
class AttendanceModel {
  final String attendanceId;
  final String sessionId;
  final String studentId;
  final String? studentName;
  final String? teacherName;
  final String? zoneName;
  
  @JsonKey(fromJson: _dateTimeFromJson)
  final DateTime deviceTime;
  
  @JsonKey(fromJson: _dateTimeFromJson)
  final DateTime serverTime;
  
  final bool withinGeofence;
  final double latitude;
  final double longitude;
  final String? sensorStatus;
  final int? trustScore;
  final bool isSynced;
  final String? syncDelay;
  final String? note;

  const AttendanceModel({
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

  static DateTime _dateTimeFromJson(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is String) return DateTime.parse(value);
    if (value is DateTime) return value;
    return DateTime.now();
  }

  factory AttendanceModel.fromJson(Map<String, dynamic> json) =>
      _$AttendanceModelFromJson(json);

  Map<String, dynamic> toJson() => _$AttendanceModelToJson(this);

  Attendance toEntity() {
    return Attendance(
      attendanceId: attendanceId,
      sessionId: sessionId,
      studentId: studentId,
      studentName: studentName,
      teacherName: teacherName,
      zoneName: zoneName,
      deviceTime: deviceTime,
      serverTime: serverTime,
      withinGeofence: withinGeofence,
      latitude: latitude,
      longitude: longitude,
      sensorStatus: sensorStatus,
      trustScore: trustScore,
      isSynced: isSynced,
      syncDelay: syncDelay,
      note: note,
    );
  }

  factory AttendanceModel.fromEntity(Attendance entity) {
    return AttendanceModel(
      attendanceId: entity.attendanceId,
      sessionId: entity.sessionId,
      studentId: entity.studentId,
      studentName: entity.studentName,
      deviceTime: entity.deviceTime,
      serverTime: entity.serverTime,
      withinGeofence: entity.withinGeofence,
      latitude: entity.latitude,
      longitude: entity.longitude,
      sensorStatus: entity.sensorStatus,
      trustScore: entity.trustScore,
      isSynced: entity.isSynced,
      syncDelay: entity.syncDelay,
      note: entity.note,
    );
  }
}
