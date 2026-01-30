import 'package:equatable/equatable.dart';
import 'attendance.dart';

/// Entidad de Historial de Asistencia
class AttendanceHistory extends Equatable {
  final AttendanceSummary summary;
  final List<Attendance> attendances;
  final int totalPages;
  final int currentPage;

  const AttendanceHistory({
    required this.summary,
    required this.attendances,
    required this.totalPages,
    required this.currentPage,
  });

  @override
  List<Object?> get props => [summary, attendances, totalPages, currentPage];
}

/// Entidad de Resumen de Asistencia
class AttendanceSummary extends Equatable {
  final int totalSessions;
  final int attendedSessions;
  final double attendanceRate;

  const AttendanceSummary({
    required this.totalSessions,
    required this.attendedSessions,
    required this.attendanceRate,
  });

  @override
  List<Object?> get props => [totalSessions, attendedSessions, attendanceRate];
}
