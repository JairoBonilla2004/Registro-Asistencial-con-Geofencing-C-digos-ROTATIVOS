// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_statistics_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SessionStatisticsModel _$SessionStatisticsModelFromJson(
        Map<String, dynamic> json) =>
    SessionStatisticsModel(
      sessionId: json['sessionId'] as String,
      teacherName: json['teacherName'] as String,
      zoneName: json['zoneName'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] == null
          ? null
          : DateTime.parse(json['endTime'] as String),
      duration: json['duration'] as String?,
      totalAttendances: (json['totalAttendances'] as num).toInt(),
      statistics: json['statistics'] as Map<String, dynamic>,
      sensorData: json['sensorData'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$SessionStatisticsModelToJson(
        SessionStatisticsModel instance) =>
    <String, dynamic>{
      'sessionId': instance.sessionId,
      'teacherName': instance.teacherName,
      'zoneName': instance.zoneName,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime?.toIso8601String(),
      'duration': instance.duration,
      'totalAttendances': instance.totalAttendances,
      'statistics': instance.statistics,
      'sensorData': instance.sensorData,
    };
