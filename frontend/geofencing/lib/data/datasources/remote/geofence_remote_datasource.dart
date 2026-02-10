import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/error/exceptions.dart';
import '../../../core/network/dio_client.dart';
import '../../models/api_response_model.dart';
import '../../models/geofence_zone_model.dart';

/// Remote DataSource para geofencing
abstract class GeofenceRemoteDataSource {
  Future<List<GeofenceZoneModel>> getZones();

  Future<GeofenceZoneModel> createZone({
    required String name,
    required double latitude,
    required double longitude,
    required double radiusMeters,
  });

  Future<GeofenceZoneModel> updateZone({
    required String zoneId,
    String? name,
    double? radiusMeters,
  });

  Future<void> deleteZone(String zoneId);

  Future<Map<String, dynamic>> validateLocation({
    required double latitude,
    required double longitude,
  });
}

class GeofenceRemoteDataSourceImpl implements GeofenceRemoteDataSource {
  final DioClient _client;

  GeofenceRemoteDataSourceImpl(this._client);

  @override
  Future<List<GeofenceZoneModel>> getZones() async {
    try {
      final response = await _client.get(ApiConstants.geofenceZones);

      final apiResponse = ApiResponseModel<List>.fromJson(
        response.data,
        (json) => json as List,
      );

      if (!apiResponse.success || apiResponse.data == null) {
        throw ServerException(
          apiResponse.message ?? 'Error al obtener zonas',
          apiResponse.errorCode,
        );
      }

      return (apiResponse.data as List)
          .map((e) => GeofenceZoneModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  @override
  Future<GeofenceZoneModel> createZone({
    required String name,
    required double latitude,
    required double longitude,
    required double radiusMeters,
  }) async {
    try {
      final response = await _client.post(
        ApiConstants.createGeofenceZone,
        data: {
          'name': name,
          'latitude': latitude,
          'longitude': longitude,
          'radiusMeters': radiusMeters,
        },
      );

      final apiResponse = ApiResponseModel<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.success || apiResponse.data == null) {
        throw ServerException(
          apiResponse.message ?? 'Error al crear zona',
          apiResponse.errorCode,
        );
      }

      return GeofenceZoneModel.fromJson(apiResponse.data!);
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  @override
  Future<GeofenceZoneModel> updateZone({
    required String zoneId,
    String? name,
    double? radiusMeters,
  }) async {
    try {
      final Map<String, dynamic> data = {};
      if (name != null) data['name'] = name;
      if (radiusMeters != null) data['radiusMeters'] = radiusMeters;

      final response = await _client.put(
        '${ApiConstants.geofenceZones}/$zoneId',
        data: data,
      );

      final apiResponse = ApiResponseModel<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.success || apiResponse.data == null) {
        throw ServerException(
          apiResponse.message ?? 'Error al actualizar zona',
          apiResponse.errorCode,
        );
      }

      return GeofenceZoneModel.fromJson(apiResponse.data!);
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  @override
  Future<void> deleteZone(String zoneId) async {
    try {
      final response = await _client.delete(
        '${ApiConstants.geofenceZones}/$zoneId',
      );

      final apiResponse = ApiResponseModel<void>.fromJson(
        response.data,
        (json) => null,
      );

      if (!apiResponse.success) {
        throw ServerException(
          apiResponse.message ?? 'Error al eliminar zona',
          apiResponse.errorCode,
        );
      }
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> validateLocation({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await _client.post(
        ApiConstants.validateLocation,
        data: {
          'latitude': latitude,
          'longitude': longitude,
        },
      );

      final apiResponse = ApiResponseModel<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.success || apiResponse.data == null) {
        throw ServerException(
          apiResponse.message ?? 'Error al validar ubicación',
          apiResponse.errorCode,
        );
      }

      return apiResponse.data!;
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
