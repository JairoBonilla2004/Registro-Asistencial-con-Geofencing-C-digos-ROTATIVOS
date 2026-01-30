import 'package:equatable/equatable.dart';
import 'attendance.dart';

/// Entidad de Dashboard del Estudiante
class StudentDashboard extends Equatable {
  final DashboardOverview overview;
  final List<Attendance> recentAttendances;
  final SyncStatus syncStatus;
  final NotificationStatus notificationStatus;

  const StudentDashboard({
    required this.overview,
    required this.recentAttendances,
    required this.syncStatus,
    required this.notificationStatus,
  });

  @override
  List<Object?> get props => [overview, recentAttendances, syncStatus, notificationStatus];
}

/// Entidad de Vista General del Dashboard
class DashboardOverview extends Equatable {
  final int totalSessions;
  final int attendedSessions;
  final double attendanceRate;

  const DashboardOverview({
    required this.totalSessions,
    required this.attendedSessions,
    required this.attendanceRate,
  });

  @override
  List<Object?> get props => [totalSessions, attendedSessions, attendanceRate];
}

/// Entidad de Estado de Sincronización
class SyncStatus extends Equatable {
  final int pendingSync;
  final DateTime? lastSyncAt;

  const SyncStatus({
    required this.pendingSync,
    this.lastSyncAt,
  });

  bool get hasPendingSync => pendingSync > 0;

  @override
  List<Object?> get props => [pendingSync, lastSyncAt];
}

/// Entidad de Estado de Notificaciones
class NotificationStatus extends Equatable {
  final int unreadCount;

  const NotificationStatus({
    required this.unreadCount,
  });

  bool get hasUnread => unreadCount > 0;

  @override
  List<Object?> get props => [unreadCount];
}
