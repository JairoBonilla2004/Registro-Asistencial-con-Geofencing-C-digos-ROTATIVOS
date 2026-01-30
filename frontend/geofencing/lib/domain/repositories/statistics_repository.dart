import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/session_statistics.dart';
import '../entities/student_dashboard.dart';
import '../entities/teacher_dashboard.dart';

abstract class StatisticsRepository {
  Future<Either<Failure, dynamic>> getDashboard(); // Retorna StudentDashboard o TeacherDashboard
  Future<Either<Failure, StudentDashboard>> getStudentDashboard();
  Future<Either<Failure, TeacherDashboard>> getTeacherDashboard();
  Future<Either<Failure, SessionStatistics>> getSessionStatistics(String sessionId);
}
