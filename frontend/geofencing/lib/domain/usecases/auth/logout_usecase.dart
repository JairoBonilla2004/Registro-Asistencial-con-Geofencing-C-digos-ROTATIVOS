import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../core/services/device_info_service.dart';
import '../../repositories/auth_repository.dart';

class LogoutUseCase {
  final AuthRepository repository;
  final DeviceInfoService _deviceInfoService = DeviceInfoService();

  LogoutUseCase(this.repository);

  Future<Either<Failure, void>> call() async {
    // SOLUCIÓN PROFESIONAL: Obtener deviceIdentifier para desactivar el dispositivo
    String deviceIdentifier;
    try {
      deviceIdentifier = await _deviceInfoService.getDeviceIdentifier();
      print('Logout - Device ID: $deviceIdentifier');
    } catch (e) {
      print('Error obteniendo device ID en logout: $e');
      // Usar un fallback si falla
      deviceIdentifier = 'unknown_device_${DateTime.now().millisecondsSinceEpoch}';
    }
    
    return await repository.logout(deviceIdentifier);
  }
}
