// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_history_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AttendanceHistoryModel _$AttendanceHistoryModelFromJson(
        Map<String, dynamic> json) =>
    AttendanceHistoryModel(
      summary: json['summary'] as Map<String, dynamic>,
      attendances: (json['attendances'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
      totalPages: (json['totalPages'] as num).toInt(),
      currentPage: (json['currentPage'] as num).toInt(),
    );

Map<String, dynamic> _$AttendanceHistoryModelToJson(
        AttendanceHistoryModel instance) =>
    <String, dynamic>{
      'summary': instance.summary,
      'attendances': instance.attendances,
      'totalPages': instance.totalPages,
      'currentPage': instance.currentPage,
    };
