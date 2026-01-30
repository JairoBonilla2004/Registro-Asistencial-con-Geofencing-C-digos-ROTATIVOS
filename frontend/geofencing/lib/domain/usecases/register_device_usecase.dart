import '../../data/models/device_model.dart';
import '../entities/device.dart';
import '../repositories/device_repository.dart';

class RegisterDeviceUseCase {
  final DeviceRepository repository;

  RegisterDeviceUseCase(this.repository);

  Future<Device> call({
    required String deviceIdentifier,
    required String platform,
    required String fcmToken,
  }) async {
    final result = await repository.registerDevice(
      deviceIdentifier: deviceIdentifier,
      platform: platform,
      fcmToken: fcmToken,
    );
    return result.fold(
      (failure) => throw Exception(failure.toString()),
      (device) => device,
    );
  }
}
