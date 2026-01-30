import '../repositories/device_repository.dart';

class UpdateFcmTokenUseCase {
  final DeviceRepository repository;

  UpdateFcmTokenUseCase(this.repository);

  Future<void> call({
    required String deviceId,
    required String fcmToken,
  }) async {
    final result = await repository.updateFCMToken(
      deviceId: deviceId,
      fcmToken: fcmToken,
    );
    result.fold(
      (failure) => throw Exception(failure.toString()),
      (_) => null,
    );
  }
}
