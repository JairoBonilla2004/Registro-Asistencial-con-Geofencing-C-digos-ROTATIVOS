import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/error/exceptions.dart';
import '../../../core/network/dio_client.dart';
import '../../models/api_response_model.dart';
import '../../models/sensor_data_model.dart';

/// Remote DataSource para asistencias (Estudiante)
abstract class AttendanceRemoteDataSource {
  Future<Map<String, dynamic>> validateQR({
    required String token,
    required double latitude,
    required double longitude,
    required DateTime deviceTime,
    required List<SensorDataModel> sensorData,
    String? deviceId,
  });

  Future<Map<String, dynamic>> syncOfflineAttendances({
    required String deviceId,
    required List<Map<String, dynamic>> attendances,
  });

  Future<Map<String, dynamic>> getMyHistory({
    DateTime? startDate,
    DateTime? endDate,
    int page = 0,
    int size = 20,
  });

  Future<List<Map<String, dynamic>>> getSessionAttendances(String sessionId);
}

class AttendanceRemoteDataSourceImpl implements AttendanceRemoteDataSource {
  final DioClient _client;

  AttendanceRemoteDataSourceImpl(this._client);

  @override
  Future<Map<String, dynamic>> validateQR({
    required String token,
    required double latitude,
    required double longitude,
    required DateTime deviceTime,
    required List<SensorDataModel> sensorData,
    String? deviceId,
  }) async {
    try {
      final data = {
        'token': token,
        'latitude': latitude,
        'longitude': longitude,
        'deviceTime': deviceTime.toIso8601String(),
        'sensorData': sensorData.map((s) => s.toJson()).toList(),
      };
      
      if (deviceId != null) {
        data['deviceId'] = deviceId;
      }
      
      final response = await _client.post(
        ApiConstants.validateQr,
        data: data,
      );

      final apiResponse = ApiResponseModel<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.success) {
        // Lanzar excepciones específicas según el error
        if (apiResponse.errorCode == 'TOKEN_EXPIRED') {
          throw ServerException(
            apiResponse.message ?? 'El código QR ha expirado',
            'TOKEN_EXPIRED',
          );
        } else if (apiResponse.errorCode == 'OUTSIDE_GEOFENCE') {
          throw ServerException(
            apiResponse.message ?? 'Fuera del geofence',
            'OUTSIDE_GEOFENCE',
          );
        } else if (apiResponse.errorCode == 'ALREADY_REGISTERED') {
          throw ServerException(
            apiResponse.message ?? 'Ya registrado',
            'ALREADY_REGISTERED',
          );
        } else {
          throw ServerException(
            apiResponse.message ?? 'Error al validar QR',
            apiResponse.errorCode,
          );
        }
      }

      return apiResponse.data ?? {};
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> syncOfflineAttendances({
    required String deviceId,
    required List<Map<String, dynamic>> attendances,
  }) async {
    try {
      final response = await _client.post(
        ApiConstants.syncAttendances,
        data: {
          'deviceId': deviceId,
          'attendances': attendances,
        },
      );

      final apiResponse = ApiResponseModel<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      // La sincronización puede ser parcial y aún así tener success=true
      return apiResponse.data ?? {};
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getMyHistory({
    DateTime? startDate,
    DateTime? endDate,
    int page = 0,
    int size = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'size': size,
      };

      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String().split('T')[0];
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String().split('T')[0];
      }

      final response = await _client.get(
        ApiConstants.myHistory,
        queryParameters: queryParams,
      );

      final apiResponse = ApiResponseModel<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.success || apiResponse.data == null) {
        throw ServerException(
          apiResponse.message ?? 'Error al obtener historial',
          apiResponse.errorCode,
        );
      }

      return apiResponse.data!;
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getSessionAttendances(String sessionId) async {
    try {
      final response = await _client.get(
        ApiConstants.sessionAttendances.replaceAll('{id}', sessionId),
      );

      final apiResponse = ApiResponseModel<List>.fromJson(
        response.data,
        (json) => json as List,
      );

      if (!apiResponse.success || apiResponse.data == null) {
        throw ServerException(
          apiResponse.message ?? 'Error al obtener asistencias',
          apiResponse.errorCode,
        );
      }

      return (apiResponse.data as List)
          .map((e) => e as Map<String, dynamic>)
          .toList();
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
