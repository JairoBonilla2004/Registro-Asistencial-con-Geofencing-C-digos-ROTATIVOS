import 'package:equatable/equatable.dart';

/// Entidad de Dashboard del Docente
class TeacherDashboard extends Equatable {
  final int totalSessions;
  final int activeSessions;
  final int totalStudentsEnrolled;
  final double averageAttendanceRate;
  final List<SessionSummary> recentSessions;
  final Map<String, int> attendanceByMonth;
  final Map<String, double> attendanceRateBySession;
  final int totalAttendances;
  final DateTime? lastSessionDate;
  final String mostActiveSession;

  const TeacherDashboard({
    required this.totalSessions,
    required this.activeSessions,
    required this.totalStudentsEnrolled,
    required this.averageAttendanceRate,
    required this.recentSessions,
    required this.attendanceByMonth,
    required this.attendanceRateBySession,
    required this.totalAttendances,
    this.lastSessionDate,
    required this.mostActiveSession,
  });

  @override
  List<Object?> get props => [
        totalSessions,
        activeSessions,
        totalStudentsEnrolled,
        averageAttendanceRate,
        recentSessions,
        attendanceByMonth,
        attendanceRateBySession,
        totalAttendances,
        lastSessionDate,
        mostActiveSession,
      ];
}

/// Entidad de Resumen de Sesión
class SessionSummary extends Equatable {
  final String sessionId;
  final String sessionName;
  final String zoneName;
  final DateTime date;
  final int totalAttendances;
  final double attendanceRate;
  final bool isActive;

  const SessionSummary({
    required this.sessionId,
    required this.sessionName,
    required this.zoneName,
    required this.date,
    required this.totalAttendances,
    required this.attendanceRate,
    required this.isActive,
  });

  @override
  List<Object?> get props => [
        sessionId,
        sessionName,
        zoneName,
        date,
        totalAttendances,
        attendanceRate,
        isActive,
      ];
}
