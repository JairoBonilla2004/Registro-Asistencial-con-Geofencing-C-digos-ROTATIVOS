import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/session_statistics.dart';

part 'session_statistics_model.g.dart';

@JsonSerializable()
class SessionStatisticsModel {
  final String sessionId;
  final String teacherName;
  final String zoneName;
  final DateTime startTime;
  final DateTime? endTime;
  final String? duration;
  final int totalAttendances;
  final Map<String, dynamic> statistics;
  final Map<String, dynamic> sensorData;

  const SessionStatisticsModel({
    required this.sessionId,
    required this.teacherName,
    required this.zoneName,
    required this.startTime,
    this.endTime,
    this.duration,
    required this.totalAttendances,
    required this.statistics,
    required this.sensorData,
  });

  factory SessionStatisticsModel.fromJson(Map<String, dynamic> json) =>
      _$SessionStatisticsModelFromJson(json);

  Map<String, dynamic> toJson() => _$SessionStatisticsModelToJson(this);

  SessionStatistics toEntity() {
    final stats = statistics;
    final attendanceStats = AttendanceStats(
      onTimeRegistrations: stats['onTimeRegistrations'] as int? ?? 0,
      lateRegistrations: stats['lateRegistrations'] as int? ?? 0,
      averageSyncDelay: stats['averageSyncDelay'] as String? ?? '0ms',
      offlineSyncs: stats['offlineSyncs'] as int? ?? 0,
      withinGeofence: stats['withinGeofence'] as int? ?? 0,
      outsideGeofence: stats['outsideGeofence'] as int? ?? 0,
    );

    final sensorStats = SensorDataStats(
      compassReadings: sensorData['compassReadings'] as int? ?? 0,
      proximityReadings: sensorData['proximityReadings'] as int? ?? 0,
    );

    return SessionStatistics(
      sessionId: sessionId,
      teacherName: teacherName,
      zoneName: zoneName,
      startTime: startTime,
      endTime: endTime,
      duration: duration,
      totalAttendances: totalAttendances,
      statistics: attendanceStats,
      sensorData: sensorStats,
    );
  }
}
