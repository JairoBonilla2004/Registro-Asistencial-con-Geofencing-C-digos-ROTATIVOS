import 'package:dartz/dartz.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../../core/error/failures.dart';
import '../../../core/services/device_info_service.dart';
import '../../entities/auth_response.dart';
import '../../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;
  final DeviceInfoService _deviceInfoService = DeviceInfoService();

  LoginUseCase(this.repository);

  Future<Either<Failure, AuthResponse>> call({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      return Left(const ValidationFailure('Email y contraseña son requeridos'));
    }

    if (!_isValidEmail(email)) {
      return Left(const ValidationFailure('Email inválido'));
    }

    if (password.length < 6) {
      return Left(const ValidationFailure('La contraseña debe tener al menos 6 caracteres'));
    }

    // SOLUCIÓN PROFESIONAL: Obtener FCM token y deviceIdentifier automáticamente
    String? fcmToken;
    String? deviceIdentifier;
    
    try {
      fcmToken = await FirebaseMessaging.instance.getToken();
      deviceIdentifier = await _deviceInfoService.getDeviceIdentifier();
      print('Login - FCM Token obtenido: ${fcmToken?.substring(0, 20)}...');
      print('Login - Device ID: $deviceIdentifier');
    } catch (e) {
      print('Advertencia: No se pudo obtener FCM token o device ID: $e');
      // Continuar sin estos datos - el backend es retrocompatible
    }

    return await repository.authenticate(
      provider: 'LOCAL',
      email: email,
      password: password,
      fcmToken: fcmToken,
      deviceIdentifier: deviceIdentifier,
    );
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}
