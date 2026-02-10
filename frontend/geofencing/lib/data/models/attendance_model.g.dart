// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AttendanceModel _$AttendanceModelFromJson(Map<String, dynamic> json) =>
    AttendanceModel(
      attendanceId: json['attendanceId'] as String,
      sessionId: json['sessionId'] as String,
      studentId: json['studentId'] as String,
      studentName: json['studentName'] as String?,
      teacherName: json['teacherName'] as String?,
      zoneName: json['zoneName'] as String?,
      deviceTime: AttendanceModel._dateTimeFromJson(json['deviceTime']),
      serverTime: AttendanceModel._dateTimeFromJson(json['serverTime']),
      withinGeofence: json['withinGeofence'] as bool,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      sensorStatus: json['sensorStatus'] as String?,
      trustScore: (json['trustScore'] as num?)?.toInt(),
      isSynced: json['isSynced'] as bool,
      syncDelay: json['syncDelay'] as String?,
      note: json['note'] as String?,
    );

Map<String, dynamic> _$AttendanceModelToJson(AttendanceModel instance) =>
    <String, dynamic>{
      'attendanceId': instance.attendanceId,
      'sessionId': instance.sessionId,
      'studentId': instance.studentId,
      'studentName': instance.studentName,
      'teacherName': instance.teacherName,
      'zoneName': instance.zoneName,
      'deviceTime': instance.deviceTime.toIso8601String(),
      'serverTime': instance.serverTime.toIso8601String(),
      'withinGeofence': instance.withinGeofence,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'sensorStatus': instance.sensorStatus,
      'trustScore': instance.trustScore,
      'isSynced': instance.isSynced,
      'syncDelay': instance.syncDelay,
      'note': instance.note,
    };
