import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/attendance_history.dart';
import 'attendance_model.dart';

part 'attendance_history_model.g.dart';

@JsonSerializable()
class AttendanceHistoryModel {
  final Map<String, dynamic> summary;
  final List<Map<String, dynamic>> attendances;
  final int totalPages;
  final int currentPage;

  const AttendanceHistoryModel({
    required this.summary,
    required this.attendances,
    required this.totalPages,
    required this.currentPage,
  });

  factory AttendanceHistoryModel.fromJson(Map<String, dynamic> json) =>
      _$AttendanceHistoryModelFromJson(json);

  Map<String, dynamic> toJson() => _$AttendanceHistoryModelToJson(this);

  AttendanceHistory toEntity() {
    final attendanceSummary = AttendanceSummary(
      totalSessions: summary['totalSessions'] as int? ?? 0,
      attendedSessions: summary['attendedSessions'] as int? ?? 0,
      attendanceRate: (summary['attendanceRate'] as num?)?.toDouble() ?? 0.0,
    );

    final attendanceList = attendances.map((json) {
      return AttendanceModel.fromJson(json).toEntity();
    }).toList();

    return AttendanceHistory(
      summary: attendanceSummary,
      attendances: attendanceList,
      totalPages: totalPages,
      currentPage: currentPage,
    );
  }
}
