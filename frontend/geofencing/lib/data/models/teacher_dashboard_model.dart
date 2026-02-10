import '../../domain/entities/teacher_dashboard.dart';

/// Modelo de Dashboard del Docente
class TeacherDashboardModel {
  final int totalSessions;
  final int activeSessions;
  final int totalStudentsEnrolled;
  final double averageAttendanceRate;
  final List<SessionSummaryModel> recentSessions;
  final Map<String, int> attendanceByMonth;
  final Map<String, double> attendanceRateBySession;
  final int totalAttendances;
  final DateTime? lastSessionDate;
  final String mostActiveSession;

  TeacherDashboardModel({
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

  factory TeacherDashboardModel.fromJson(Map<String, dynamic> json) {
    return TeacherDashboardModel(
      totalSessions: json['totalSessions'] as int,
      activeSessions: json['activeSessions'] as int,
      totalStudentsEnrolled: json['totalStudentsEnrolled'] as int,
      averageAttendanceRate: (json['averageAttendanceRate'] as num).toDouble(),
      recentSessions: (json['recentSessions'] as List<dynamic>)
          .map((e) => SessionSummaryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      attendanceByMonth: (json['attendanceByMonth'] as Map<String, dynamic>)
          .map((k, v) => MapEntry(k, v as int)),
      attendanceRateBySession:
          (json['attendanceRateBySession'] as Map<String, dynamic>)
              .map((k, v) => MapEntry(k, (v as num).toDouble())),
      totalAttendances: json['totalAttendances'] as int,
      lastSessionDate: json['lastSessionDate'] != null
          ? DateTime.parse(json['lastSessionDate'] as String)
          : null,
      mostActiveSession: json['mostActiveSession'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalSessions': totalSessions,
      'activeSessions': activeSessions,
      'totalStudentsEnrolled': totalStudentsEnrolled,
      'averageAttendanceRate': averageAttendanceRate,
      'recentSessions': recentSessions.map((e) => e.toJson()).toList(),
      'attendanceByMonth': attendanceByMonth,
      'attendanceRateBySession': attendanceRateBySession,
      'totalAttendances': totalAttendances,
      'lastSessionDate': lastSessionDate?.toIso8601String(),
      'mostActiveSession': mostActiveSession,
    };
  }

  TeacherDashboard toEntity() {
    return TeacherDashboard(
      totalSessions: totalSessions,
      activeSessions: activeSessions,
      totalStudentsEnrolled: totalStudentsEnrolled,
      averageAttendanceRate: averageAttendanceRate,
      recentSessions: recentSessions.map((e) => e.toEntity()).toList(),
      attendanceByMonth: attendanceByMonth,
      attendanceRateBySession: attendanceRateBySession,
      totalAttendances: totalAttendances,
      lastSessionDate: lastSessionDate,
      mostActiveSession: mostActiveSession,
    );
  }
}

/// Modelo de Resumen de Sesión
class SessionSummaryModel {
  final String sessionId;
  final String sessionName;
  final String zoneName;
  final DateTime date;
  final int totalAttendances;
  final double attendanceRate;
  final bool isActive;

  SessionSummaryModel({
    required this.sessionId,
    required this.sessionName,
    required this.zoneName,
    required this.date,
    required this.totalAttendances,
    required this.attendanceRate,
    required this.isActive,
  });

  factory SessionSummaryModel.fromJson(Map<String, dynamic> json) {
    return SessionSummaryModel(
      sessionId: json['sessionId'] as String,
      sessionName: json['sessionName'] as String,
      zoneName: json['zoneName'] as String,
      date: DateTime.parse(json['date'] as String),
      totalAttendances: json['totalAttendances'] as int,
      attendanceRate: (json['attendanceRate'] as num).toDouble(),
      isActive: json['isActive'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'sessionName': sessionName,
      'zoneName': zoneName,
      'date': date.toIso8601String().split('T')[0],
      'totalAttendances': totalAttendances,
      'attendanceRate': attendanceRate,
      'isActive': isActive,
    };
  }

  SessionSummary toEntity() {
    return SessionSummary(
      sessionId: sessionId,
      sessionName: sessionName,
      zoneName: zoneName,
      date: date,
      totalAttendances: totalAttendances,
      attendanceRate: attendanceRate,
      isActive: isActive,
    );
  }
}
