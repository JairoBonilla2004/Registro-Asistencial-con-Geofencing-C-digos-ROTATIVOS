// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_dashboard_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StudentDashboardModel _$StudentDashboardModelFromJson(
        Map<String, dynamic> json) =>
    StudentDashboardModel(
      overview: json['overview'] as Map<String, dynamic>,
      recentAttendances: (json['recentAttendances'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
      syncStatus: json['syncStatus'] as Map<String, dynamic>,
      notificationStatus: json['notificationStatus'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$StudentDashboardModelToJson(
        StudentDashboardModel instance) =>
    <String, dynamic>{
      'overview': instance.overview,
      'recentAttendances': instance.recentAttendances,
      'syncStatus': instance.syncStatus,
      'notificationStatus': instance.notificationStatus,
    };
