import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../constants/api_constants.dart';
import '../constants/app_constants.dart';
import '../utils/session_manager.dart';

/// Cliente HTTP configurado con Dio
class DioClient {
  late final Dio _dio;
  final FlutterSecureStorage _secureStorage;
  static bool _isHandlingExpiredToken = false;

  DioClient(this._secureStorage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        sendTimeout: ApiConstants.sendTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Agregar interceptor para logging en desarrollo
    _dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
      ),
    );

    // Agregar interceptor para agregar token JWT automáticamente
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _secureStorage.read(key: AppConstants.jwtTokenKey);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          // SOLUCIÓN PROFESIONAL: Manejo de JWT expirado
          if (error.response?.statusCode == 401 || error.response?.statusCode == 403) {
            // Prevenir múltiples ejecuciones simultáneas
            if (_isHandlingExpiredToken) {
              return handler.reject(error);
            }
            
            _isHandlingExpiredToken = true;
            print('🔴 JWT expirado - Sesión terminada');
            
            try {
              // Limpiar sesión local
              await _secureStorage.deleteAll();
              
              // Navegar al login con mensaje amigable (una sola vez)
              await SessionManager.handleSessionExpired(
                message: 'Tu sesión ha expirado. Por favor, inicia sesión nuevamente.',
              );
            } finally {
              // Esperar un poco antes de permitir otro manejo
              Future.delayed(const Duration(seconds: 2), () {
                _isHandlingExpiredToken = false;
              });
            }
            
            // Crear excepción personalizada
            final sessionExpiredException = DioException(
              requestOptions: error.requestOptions,
              response: error.response,
              type: DioExceptionType.badResponse,
              error: 'SESSION_EXPIRED',
              message: 'Tu sesión ha expirado',
            );
            
            return handler.reject(sessionExpiredException);
          }
          return handler.next(error);
        },
      ),
    );
  }

  Dio get dio => _dio;

  // GET
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.get(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // POST
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // PUT
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // DELETE
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // PATCH
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.patch(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
}
