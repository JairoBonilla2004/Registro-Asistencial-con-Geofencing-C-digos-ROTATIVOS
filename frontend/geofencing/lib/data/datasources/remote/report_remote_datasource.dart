import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/error/exceptions.dart';
import '../../../core/network/dio_client.dart';
import '../../models/api_response_model.dart';
import '../../models/report_model.dart';

abstract class ReportRemoteDataSource {
  Future<ReportModel> generateReport({
    required String reportType,
    DateTime? startDate,
    DateTime? endDate,
    String? sessionId,
  });
  Future<List<ReportModel>> getReports();
  Future<List<int>> downloadReport(String reportId);
  Future<void> deleteReport(String reportId);
}

class ReportRemoteDataSourceImpl implements ReportRemoteDataSource {
  final DioClient client;

  ReportRemoteDataSourceImpl(this.client);

  @override
  Future<ReportModel> generateReport({
    required String reportType,
    DateTime? startDate,
    DateTime? endDate,
    String? sessionId,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'reportType': reportType,
      };

      if (startDate != null) {
        data['startDate'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        data['endDate'] = endDate.toIso8601String();
      }
      if (sessionId != null) {
        data['sessionId'] = sessionId;
      }

      final response = await client.dio.post(
        ApiConstants.generateReport,
        data: data,
      );

      final apiResponse = ApiResponseModel<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        return ReportModel.fromJsonSafe(apiResponse.data!);
      } else {
        throw ServerException(
          apiResponse.message ?? 'Error al generar reporte',
          apiResponse.errorCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<ReportModel>> getReports() async {
    try {
      final response = await client.dio.get(ApiConstants.reports);

      final apiResponse = ApiResponseModel<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        // El backend devuelve un Page<ReportResponse>, extraemos el content
        final content = apiResponse.data!['content'] as List<dynamic>;
        return content
            .map((json) => ReportModel.fromJsonSafe(json as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerException(
          apiResponse.message ?? 'Error al obtener reportes',
          apiResponse.errorCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<int>> downloadReport(String reportId) async {
    try {
      final url = ApiConstants.downloadReport.replaceAll('{id}', reportId);
      print('🔽 Downloading report from URL: $url');
      print('🔽 Report ID: $reportId');
      
      final response = await client.dio.get(
        url,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: false,
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200) {
        // Dio devuelve Uint8List cuando se usa ResponseType.bytes
        final data = response.data;
        if (data is List<int>) {
          return data;
        } else {
          return List<int>.from(data);
        }
      } else {
        throw ServerException(
          'Error al descargar el reporte',
          'DOWNLOAD_ERROR',
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  AppException _handleDioError(DioException e) {
    if (e.response != null) {
      final statusCode = e.response!.statusCode ?? 0;
      
      // Para respuestas de error, pueden venir como JSON o bytes
      String message = 'Error del servidor';
      String? errorCode;
      
      try {
        if (e.response!.data is Map) {
          message = e.response!.data['message'] ?? 'Error del servidor';
          errorCode = e.response!.data['error'];
        } else if (e.response!.data is List<int>) {
          // Si es una lista de bytes (respuesta de error convertida a bytes)
          final jsonString = String.fromCharCodes(e.response!.data);
          final jsonData = json.decode(jsonString);
          message = jsonData['message'] ?? 'Error del servidor';
          errorCode = jsonData['errorCode'] ?? jsonData['error'];
        }
      } catch (_) {
        // Si falla el parseo, usar mensaje por defecto
        message = 'Error del servidor';
      }

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

  @override
  Future<void> deleteReport(String reportId) async {
    try {
      final url = ApiConstants.deleteReport.replaceAll('{id}', reportId);
      final response = await client.dio.delete(url);

      final apiResponse = ApiResponseModel<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.success) {
        throw ServerException(
          apiResponse.message ?? 'Error al eliminar reporte',
          apiResponse.errorCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }
}
