import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/error/exceptions.dart';
import '../../../core/network/dio_client.dart';
import '../../models/api_response_model.dart';
import '../../models/attendance_session_model.dart';
import '../../models/qr_token_model.dart';

/// Remote DataSource para sesiones (Docente)
abstract class SessionRemoteDataSource {
  Future<AttendanceSessionModel> createSession({
    required String name,
    required String geofenceId,
    required DateTime startTime,
  });

  Future<List<AttendanceSessionModel>> getActiveSessions();

  Future<List<AttendanceSessionModel>> getMySessions({
    int page = 0,
    int size = 20,
  });

  Future<List<AttendanceSessionModel>> getTeacherSessions({
    int page = 0,
    int size = 20,
  });

  Future<QRTokenModel> generateQR({
    required String sessionId,
    int expiresInMinutes = 10,
  });

  Future<QRTokenModel> generateQRCode(String sessionId);

  Future<AttendanceSessionModel> endSession(String sessionId);
}

class SessionRemoteDataSourceImpl implements SessionRemoteDataSource {
  final DioClient _client;

  SessionRemoteDataSourceImpl(this._client);

  @override
  Future<AttendanceSessionModel> createSession({
    required String name,
    required String geofenceId,
    required DateTime startTime,
  }) async {
    try {
      final response = await _client.post(
        ApiConstants.createSession,
        data: {
          'name': name,
          'geofenceId': geofenceId,
          'startTime': startTime.toIso8601String(),
        },
      );

      final apiResponse = ApiResponseModel<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.success || apiResponse.data == null) {
        throw ServerException(
          apiResponse.message ?? 'Error al crear sesión',
          apiResponse.errorCode,
        );
      }

      return AttendanceSessionModel.fromJsonSafe(apiResponse.data!);
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  @override
  Future<List<AttendanceSessionModel>> getActiveSessions() async {
    try {
      final response = await _client.get(ApiConstants.activeSessions);

      final apiResponse = ApiResponseModel<List>.fromJson(
        response.data,
        (json) => json as List,
      );

      if (!apiResponse.success || apiResponse.data == null) {
        throw ServerException(
          apiResponse.message ?? 'Error al obtener sesiones',
          apiResponse.errorCode,
        );
      }

      return (apiResponse.data as List)
          .map((e) => AttendanceSessionModel.fromJsonSafe(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  @override
  Future<List<AttendanceSessionModel>> getMySessions({
    int page = 0,
    int size = 20,
  }) async {
    try {
      final response = await _client.get(
        ApiConstants.mySessions,
        queryParameters: {
          'page': page,
          'size': size,
        },
      );

      final apiResponse = ApiResponseModel<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.success || apiResponse.data == null) {
        throw ServerException(
          apiResponse.message ?? 'Error al obtener sesiones',
          apiResponse.errorCode,
        );
      }

      // El backend ahora devuelve { sessions: [...], totalPages: x, currentPage: y }
      final sessions = apiResponse.data!['sessions'] as List;
      return sessions
          .map((e) => AttendanceSessionModel.fromJsonSafe(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  @override
  Future<List<AttendanceSessionModel>> getTeacherSessions({
    int page = 0,
    int size = 20,
  }) async {
    // Alias for getMySessions - for teacher context
    return getMySessions(page: page, size: size);
  }

  @override
  Future<QRTokenModel> generateQR({
    required String sessionId,
    int expiresInMinutes = 10,
  }) async {
    try {
      final response = await _client.post(
        ApiConstants.generateQr,
        data: {
          'sessionId': sessionId,
          'expiresInMinutes': expiresInMinutes,
        },
      );

      final apiResponse = ApiResponseModel<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.success || apiResponse.data == null) {
        throw ServerException(
          apiResponse.message ?? 'Error al generar QR',
          apiResponse.errorCode,
        );
      }

      return QRTokenModel.fromJson(apiResponse.data!);
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  @override
  Future<QRTokenModel> generateQRCode(String sessionId) async {
    // Alias for generateQR with default expiration
    return generateQR(sessionId: sessionId);
  }

  @override
  Future<AttendanceSessionModel> endSession(String sessionId) async {
    try {
      final response = await _client.post(
        ApiConstants.endSession.replaceAll('{id}', sessionId),
      );

      final apiResponse = ApiResponseModel<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.success || apiResponse.data == null) {
        throw ServerException(
          apiResponse.message ?? 'Error al finalizar sesión',
          apiResponse.errorCode,
        );
      }

      return AttendanceSessionModel.fromJson(apiResponse.data!);
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  void _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      throw NetworkException();
    } else if (e.response != null) {
      final statusCode = e.response!.statusCode;
      final data = e.response!.data;

      if (statusCode == 401 || statusCode == 403) {
        throw AuthException(
          data['message'] ?? 'No autorizado',
          data['errorCode'],
        );
      } else if (statusCode == 400) {
        throw ValidationException(
          data['message'] ?? 'Datos inválidos',
          data['errorCode'],
        );
      } else if (statusCode == 404) {
        throw NotFoundException(data['message'] ?? 'Recurso no encontrado');
      } else {
        throw ServerException(
          data['message'] ?? 'Error del servidor',
          data['errorCode'],
        );
      }
    } else {
      throw NetworkException();
    }
  }
}
