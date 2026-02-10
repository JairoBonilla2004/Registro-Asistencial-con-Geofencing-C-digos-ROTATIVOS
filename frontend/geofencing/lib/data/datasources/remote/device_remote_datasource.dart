import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/error/exceptions.dart';
import '../../../core/network/dio_client.dart';
import '../../models/api_response_model.dart';
import '../../models/device_model.dart';

abstract class DeviceRemoteDataSource {
  Future<DeviceModel> registerDevice({
    required String deviceIdentifier,
    required String platform,
    required String fcmToken,
  });
  
  Future<void> updateFCMToken({
    required String deviceId,
    required String fcmToken,
  });
  
  Future<void> deactivateDevice({
    required String deviceId,
  });
}

class DeviceRemoteDataSourceImpl implements DeviceRemoteDataSource {
  final DioClient client;

  DeviceRemoteDataSourceImpl(this.client);

  @override
  Future<DeviceModel> registerDevice({
    required String deviceIdentifier,
    required String platform,
    required String fcmToken,
  }) async {
    try {
      final response = await client.dio.post(
        ApiConstants.registerDevice,
        data: {
          'deviceIdentifier': deviceIdentifier,
          'platform': platform,
          'fcmToken': fcmToken,
        },
      );

      final apiResponse = ApiResponseModel<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        // El backend devuelve {deviceId, registered}, adaptarlo al modelo completo
        final deviceId = apiResponse.data!['deviceId'] as String;
        
        // Crear DeviceModel con los datos que tenemos
        return DeviceModel(
          deviceId: deviceId,
          deviceIdentifier: deviceIdentifier,
          platform: platform,
          fcmToken: fcmToken,
          active: true,
          registeredAt: DateTime.now(),
        );
      } else {
        throw ServerException(
          apiResponse.message ?? 'Error al registrar dispositivo',
          apiResponse.errorCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> updateFCMToken({
    required String deviceId,
    required String fcmToken,
  }) async {
    try {
      final url = '/devices/$deviceId/fcm';
      final response = await client.dio.put(
        url,
        data: {'fcmToken': fcmToken},
      );

      final apiResponse = ApiResponseModel<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.success) {
        throw ServerException(
          apiResponse.message ?? 'Error al actualizar token FCM',
          apiResponse.errorCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> deactivateDevice({
    required String deviceId,
  }) async {
    try {
      final url = '/devices/$deviceId/deactivate';
      final response = await client.dio.post(url);

      final apiResponse = ApiResponseModel<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.success) {
        throw ServerException(
          apiResponse.message ?? 'Error al desactivar dispositivo',
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
