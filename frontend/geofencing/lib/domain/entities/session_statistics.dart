import 'package:equatable/equatable.dart';

/// Entidad de Estadísticas de Sesión (para docente)
class SessionStatistics extends Equatable {
  final String sessionId;
  final String teacherName;
  final String zoneName;
  final DateTime startTime;
  final DateTime? endTime;
  final String? duration;
  final int totalAttendances;
  final AttendanceStats statistics;
  final SensorDataStats sensorData;

  const SessionStatistics({
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

  @override
  List<Object?> get props => [
        sessionId,
        teacherName,
        zoneName,
        startTime,
        endTime,
        duration,
        totalAttendances,
        statistics,
        sensorData,
      ];
}

/// Entidad de Estadísticas de Asistencia
class AttendanceStats extends Equatable {
  final int onTimeRegistrations;
  final int lateRegistrations;
  final String averageSyncDelay;
  final int offlineSyncs;
  final int withinGeofence;
  final int outsideGeofence;

  const AttendanceStats({
    required this.onTimeRegistrations,
    required this.lateRegistrations,
    required this.averageSyncDelay,
    required this.offlineSyncs,
    required this.withinGeofence,
    required this.outsideGeofence,
  });

  @override
  List<Object?> get props => [
        onTimeRegistrations,
        lateRegistrations,
        averageSyncDelay,
        offlineSyncs,
        withinGeofence,
        outsideGeofence,
      ];
}

/// Entidad de Estadísticas de Datos de Sensores
class SensorDataStats extends Equatable {
  final int compassReadings;
  final int proximityReadings;

  const SensorDataStats({
    required this.compassReadings,
    required this.proximityReadings,
  });

  @override
  List<Object?> get props => [compassReadings, proximityReadings];
}
