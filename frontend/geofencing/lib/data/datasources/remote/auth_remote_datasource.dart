import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/error/exceptions.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/services/device_info_service.dart';
import '../../models/api_response_model.dart';
import '../../models/auth_response_model.dart';

/// Remote DataSource para autenticación
abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> register({
    required String email,
    required String password,
    required String fullName,
    required String role,
  });

  Future<AuthResponseModel> authenticate({
    required String provider,
    String? email,
    String? password,
    String? idToken,
    String? accessToken,
    String? fcmToken,          // NUEVO: para notificaciones push
    String? deviceIdentifier,  // NUEVO: para solución de dispositivos prestados
  });

  Future<void> logout(String deviceIdentifier); // MODIFICADO: requiere deviceIdentifier
  
  /// Registra el dispositivo actual para recibir notificaciones push
  Future<void> registerDevice({required String userId});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient _client;

  AuthRemoteDataSourceImpl(this._client);

  @override
  Future<AuthResponseModel> register({
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) async {
    try {
      final response = await _client.post(
        ApiConstants.register,
        data: {
          'email': email,
          'password': password,
          'fullName': fullName,
          'role': role,
        },
      );

      final apiResponse = ApiResponseModel<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.success || apiResponse.data == null) {
        throw ServerException(
          apiResponse.message ?? 'Error al registrar usuario',
          apiResponse.errorCode,
        );
      }

      return AuthResponseModel.fromJson(apiResponse.data!);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException();
      } else if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final data = e.response!.data;

        if (statusCode == 400) {
          throw ValidationException(
            data['message'] ?? 'Datos inválidos',
            data['errorCode'],
          );
        } else if (statusCode == 401 || statusCode == 403) {
          throw AuthException(
            data['message'] ?? 'No autorizado',
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
    } catch (e) {
      throw ServerException('Error inesperado: $e');
    }
  }

  @override
  Future<AuthResponseModel> authenticate({
    required String provider,
    String? email,
    String? password,
    String? idToken,
    String? accessToken,
    String? fcmToken,
    String? deviceIdentifier,
  }) async {
    try {
      String token;
      
      // Generar token según el provider
      if (provider == 'LOCAL') {
        // Para LOCAL, el backend espera base64(email:password)
        final credentials = '$email:$password';
        final bytes = utf8.encode(credentials);
        token = base64.encode(bytes);
      } else if (provider == 'GOOGLE') {
        // Para GOOGLE, el token es el idToken
        token = idToken!;
      } else if (provider == 'FACEBOOK') {
        // Para FACEBOOK, el token es el accessToken
        token = accessToken!;
      } else {
        throw ValidationException('Provider no soportado: $provider');
      }

      final Map<String, dynamic> requestData = {
        'provider': provider,
        'token': token,
      };
      
      // SOLUCIÓN PROFESIONAL: Enviar FCM token y device identifier
      // Backend registrará automáticamente el dispositivo
      if (fcmToken != null && fcmToken.isNotEmpty) {
        requestData['fcmToken'] = fcmToken;
      }
      if (deviceIdentifier != null && deviceIdentifier.isNotEmpty) {
        requestData['deviceIdentifier'] = deviceIdentifier;
      }

      final response = await _client.post(
        ApiConstants.authenticate,
        data: requestData,
      );

      final apiResponse = ApiResponseModel<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      if (!apiResponse.success || apiResponse.data == null) {
        throw AuthException(
          apiResponse.message ?? 'Error al autenticar',
          apiResponse.errorCode,
        );
      }

      return AuthResponseModel.fromJson(apiResponse.data!);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException();
      } else if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final data = e.response!.data;

        if (statusCode == 401) {
          throw AuthException(
            data['message'] ?? 'Credenciales inválidas',
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
    } catch (e) {
      throw ServerException('Error inesperado: $e');
    }
  }

  @override
  Future<void> logout(String deviceIdentifier) async {
    try {
      // SOLUCIÓN PROFESIONAL: Enviar deviceIdentifier para desactivar dispositivo
      // El backend desactivará el token FCM asociado a este dispositivo
      await _client.post(
        ApiConstants.logout,
        data: {
          'deviceIdentifier': deviceIdentifier,
        },
      );
    } on DioException catch (e) {
      // Ignorar errores de logout, igual se limpiará localmente
      print('Error en logout (ignorado): $e');
    }
  }

  @override
  Future<void> registerDevice({required String userId}) async {
    try {
      // Importar servicios necesarios
      final deviceInfoService = DeviceInfoService();
      final firebaseMessaging = FirebaseMessaging.instance;
      
      // Obtener FCM token y deviceIdentifier
      String? fcmToken = await firebaseMessaging.getToken();
      String? deviceIdentifier = await deviceInfoService.getDeviceIdentifier();
      
      if (fcmToken == null || deviceIdentifier == null) {
        print('No se pudo obtener FCM token o deviceIdentifier para re-registro');
        return;
      }

      await _client.post(
        ApiConstants.registerDevice,
        data: {
          'deviceIdentifier': deviceIdentifier,
          'fcmToken': fcmToken,
        },
      );
      
      print('Dispositivo re-registrado exitosamente');
    } on DioException catch (e) {
      // No lanzar excepción, solo log
      print('Error al re-registrar dispositivo (no crítico): $e');
    }
  }
}
