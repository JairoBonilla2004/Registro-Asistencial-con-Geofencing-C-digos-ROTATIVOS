import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/error/exceptions.dart';
import '../../../core/network/dio_client.dart';
import '../../models/api_response_model.dart';
import '../../models/student_dashboard_model.dart';
import '../../models/teacher_dashboard_model.dart';
import '../../models/session_statistics_model.dart';

abstract class StatisticsRemoteDataSource {
  Future<dynamic> getDashboard(); // Retorna StudentDashboard o TeacherDashboard según rol
  Future<StudentDashboardModel> getStudentDashboard();
  Future<TeacherDashboardModel> getTeacherDashboard();
  Future<SessionStatisticsModel> getSessionStatistics(String sessionId);
}

class StatisticsRemoteDataSourceImpl implements StatisticsRemoteDataSource {
  final DioClient client;
  final FlutterSecureStorage secureStorage;

  StatisticsRemoteDataSourceImpl(this.client, this.secureStorage);

  @override
  Future<dynamic> getDashboard() async {
    try {
      // Obtener el token y decodificarlo para conocer el rol
      final token = await secureStorage.read(key: AppConstants.jwtTokenKey);
      
      if (token == null) {
        throw AuthException('No token found', 'NO_TOKEN');
      }

      // Decodificar el token JWT
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      List<dynamic> roles = decodedToken['roles'] ?? [];
      
      // Determinar si es teacher o student
      bool isTeacher = roles.any((role) => role.toString().contains('TEACHER'));
      
      if (isTeacher) {
        return await getTeacherDashboard();
      } else {
        return await getStudentDashboard();
      }
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw ServerException('Error obteniendo dashboard: ${e.toString()}');
    }
  }

  @override
  Future<StudentDashboardModel> getStudentDashboard() async {
    try {
      final response = await client.dio.get(ApiConstants.dashboard);

      final apiResponse = ApiResponseModel<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        return StudentDashboardModel.fromJson(apiResponse.data!);
      } else {
        throw ServerException(
          apiResponse.message ?? 'Error al obtener dashboard',
          apiResponse.errorCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<TeacherDashboardModel> getTeacherDashboard() async {
    try {
      final response = await client.dio.get(ApiConstants.teacherDashboard);

      final apiResponse = ApiResponseModel<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        return TeacherDashboardModel.fromJson(apiResponse.data!);
      } else {
        throw ServerException(
          apiResponse.message ?? 'Error al obtener dashboard del docente',
          apiResponse.errorCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<SessionStatisticsModel> getSessionStatistics(String sessionId) async {
    try {
      final response = await client.dio.get(
        '${ApiConstants.sessions}/$sessionId/statistics',
      );

      final apiResponse = ApiResponseModel<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        return SessionStatisticsModel.fromJson(apiResponse.data!);
      } else {
        throw ServerException(
          apiResponse.message ?? 'Error al obtener estadísticas',
          apiResponse.errorCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  AppException _handleDioError(DioException e) {
    if (e.response != null) {
      final statusCode = e.response!.statusCode ?? 0;
      final message = e.response!.data?['message'] ?? 'Error del servidor';
      final errorCode = e.response!.data?['error'];

      if (statusCode == 401) {
        return AuthException('Sesión expirada', 'UNAUTHORIZED');
      } else if (statusCode == 400) {
        return ValidationException(message, errorCode);
      } else {
        return ServerException(message, errorCode);
      }
    } else if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return NetworkException();
    } else {
      return NetworkException();
    }
  }
}
