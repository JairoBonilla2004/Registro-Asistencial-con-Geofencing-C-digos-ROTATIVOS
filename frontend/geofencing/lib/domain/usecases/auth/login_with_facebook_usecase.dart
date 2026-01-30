import 'package:dartz/dartz.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../../core/error/failures.dart';
import '../../../core/services/device_info_service.dart';
import '../../entities/auth_response.dart';
import '../../repositories/auth_repository.dart';

class LoginWithFacebookUseCase {
  final AuthRepository repository;
  final DeviceInfoService _deviceInfoService = DeviceInfoService();

  LoginWithFacebookUseCase(this.repository);

  Future<Either<Failure, AuthResponse>> call({
    required String accessToken,
  }) async {
    if (accessToken.isEmpty) {
      return Left(const ValidationFailure('Token de Facebook requerido'));
    }

    // Obtener FCM token y deviceIdentifier
    String? fcmToken;
    String? deviceIdentifier;
    try {
      fcmToken = await FirebaseMessaging.instance.getToken();
      deviceIdentifier = await _deviceInfoService.getDeviceIdentifier();
    } catch (e) {
      print('Advertencia: No se pudo obtener FCM token o device ID: $e');
    }

    return await repository.authenticate(
      provider: 'FACEBOOK',
      accessToken: accessToken,
      fcmToken: fcmToken,
      deviceIdentifier: deviceIdentifier,
    );
  }
}
