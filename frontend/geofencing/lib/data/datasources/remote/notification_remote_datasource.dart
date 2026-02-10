import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/error/exceptions.dart';
import '../../../core/network/dio_client.dart';
import '../../models/api_response_model.dart';
import '../../models/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Future<List<NotificationModel>> getUnreadNotifications();
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead();
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final DioClient client;

  NotificationRemoteDataSourceImpl(this.client);

  @override
  Future<List<NotificationModel>> getUnreadNotifications() async {
    try {
      final response = await client.dio.get(ApiConstants.unreadNotifications);

      final apiResponse = ApiResponseModel<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (apiResponse.success && apiResponse.data != null) {
        // Backend devuelve: { count: 5, notifications: [...] }
        final notificationsList = apiResponse.data!['notifications'] as List<dynamic>;
        return notificationsList
            .map((json) => NotificationModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerException(
          apiResponse.message ?? 'Error al obtener notificaciones',
          apiResponse.errorCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      final response = await client.dio.put(
        '${ApiConstants.notifications}/$notificationId/read',
      );

      final apiResponse = ApiResponseModel<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.success) {
        throw ServerException(
          apiResponse.message ?? 'Error al marcar notificación como leída',
          apiResponse.errorCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      final response = await client.dio.put(
        '${ApiConstants.notifications}/read-all',
      );

      final apiResponse = ApiResponseModel<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.success) {
        throw ServerException(
          apiResponse.message ?? 'Error al marcar todas las notificaciones',
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
