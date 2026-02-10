import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/student_dashboard.dart';
import 'attendance_model.dart';

part 'student_dashboard_model.g.dart';

@JsonSerializable()
class StudentDashboardModel {
  final Map<String, dynamic> overview;
  final List<Map<String, dynamic>> recentAttendances;
  final Map<String, dynamic> syncStatus;
  final Map<String, dynamic> notificationStatus;

  const StudentDashboardModel({
    required this.overview,
    required this.recentAttendances,
    required this.syncStatus,
    required this.notificationStatus,
  });

  factory StudentDashboardModel.fromJson(Map<String, dynamic> json) =>
      _$StudentDashboardModelFromJson(json);

  Map<String, dynamic> toJson() => _$StudentDashboardModelToJson(this);

  StudentDashboard toEntity() {
    final dashboardOverview = DashboardOverview(
      totalSessions: overview['totalSessions'] as int? ?? 0,
      attendedSessions: overview['attendedSessions'] as int? ?? 0,
      attendanceRate: (overview['attendanceRate'] as num?)?.toDouble() ?? 0.0,
    );

    final attendances = recentAttendances.map((json) {
      return AttendanceModel.fromJson(json).toEntity();
    }).toList();

    final sync = SyncStatus(
      pendingSync: syncStatus['pendingSync'] as int? ?? 0,
      lastSyncAt: syncStatus['lastSyncAt'] != null
          ? DateTime.parse(syncStatus['lastSyncAt'] as String)
          : null,
    );

    final notification = NotificationStatus(
      unreadCount: notificationStatus['unreadCount'] as int? ?? 0,
    );

    return StudentDashboard(
      overview: dashboardOverview,
      recentAttendances: attendances,
      syncStatus: sync,
      notificationStatus: notification,
    );
  }
}
