import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/storage_keys.dart';
import '../error/exceptions.dart';

/// 🔐 Interceptor de autenticación
class AuthInterceptor extends Interceptor {
  final Ref _ref;
  final _storage = const FlutterSecureStorage();

  AuthInterceptor(this._ref);

  @override
  Future<void> onRequest(
      RequestOptions options,
      RequestInterceptorHandler handler,
      ) async {
    final token = await _storage.read(key: StorageKeys.accessToken);

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }
}

/// ❌ Interceptor de errores
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    Exception exception;

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        exception = TimeoutException('Tiempo de espera agotado');
        break;

      case DioExceptionType.connectionError:
        exception = NetworkException('Sin conexión a internet');
        break;

      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode;
        final message = _extractErrorMessage(err.response?.data);

        switch (statusCode) {
          case 400:
            exception = ValidationException(message);
            break;
          case 401:
            exception = UnauthorizedException(message);
            break;
          case 403:
            exception = ForbiddenException(message);
            break;
          case 404:
            exception = NotFoundException(message);
            break;
          case 422:
            final errors = _extractValidationErrors(err.response?.data);
            exception = ValidationException(message, errors);
            break;
          case 500:
          case 502:
          case 503:
            exception = ServerException(message, statusCode);
            break;
          default:
            exception = ServerException(message, statusCode);
        }
        break;

      case DioExceptionType.cancel:
        exception = ServerException('Petición cancelada');
        break;

      default:
        exception = ServerException('Error desconocido');
    }

    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: exception,
        type: err.type,
      ),
    );
  }

  String _extractErrorMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['message'] ?? 'Error desconocido';
    }
    return 'Error desconocido';
  }

  Map<String, dynamic>? _extractValidationErrors(dynamic data) {
    if (data is Map<String, dynamic> && data.containsKey('errors')) {
      return data['errors'] as Map<String, dynamic>?;
    }
    return null;
  }
}

/// 📝 Interceptor de logging (solo en debug)
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('🌐 REQUEST[${options.method}] => ${options.uri}');
      debugPrint('Headers: ${options.headers}');
      debugPrint('Data: ${options.data}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('✅ RESPONSE[${response.statusCode}] => ${response.requestOptions.uri}');
      debugPrint('Data: ${response.data}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('❌ ERROR[${err.response?.statusCode}] => ${err.requestOptions.uri}');
      debugPrint('Message: ${err.message}');
      debugPrint('Error: ${err.error}');
    }
    handler.next(err);
  }
}