// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_session_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AttendanceSessionModel _$AttendanceSessionModelFromJson(
        Map<String, dynamic> json) =>
    AttendanceSessionModel(
      sessionId: json['sessionId'] as String,
      name: json['name'] as String,
      teacherId: json['teacherId'] as String,
      teacherName: json['teacherName'] as String,
      geofenceId: json['geofenceId'] as String,
      zoneName: json['zoneName'] as String,
      zoneLatitude: (json['zoneLatitude'] as num).toDouble(),
      zoneLongitude: (json['zoneLongitude'] as num).toDouble(),
      radiusMeters: (json['radiusMeters'] as num).toDouble(),
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] == null
          ? null
          : DateTime.parse(json['endTime'] as String),
      active: json['active'] as bool,
      hasActiveQR: json['hasActiveQR'] as bool,
      totalAttendances: (json['totalAttendances'] as num?)?.toInt(),
    );

Map<String, dynamic> _$AttendanceSessionModelToJson(
        AttendanceSessionModel instance) =>
    <String, dynamic>{
      'sessionId': instance.sessionId,
      'name': instance.name,
      'teacherId': instance.teacherId,
      'teacherName': instance.teacherName,
      'geofenceId': instance.geofenceId,
      'zoneName': instance.zoneName,
      'zoneLatitude': instance.zoneLatitude,
      'zoneLongitude': instance.zoneLongitude,
      'radiusMeters': instance.radiusMeters,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime?.toIso8601String(),
      'active': instance.active,
      'hasActiveQR': instance.hasActiveQR,
      'totalAttendances': instance.totalAttendances,
    };
