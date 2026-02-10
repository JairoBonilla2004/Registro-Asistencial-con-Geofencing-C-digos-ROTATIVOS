import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/network_info.dart';
import '../../data/datasources/remote/device_remote_datasource.dart';
import '../../data/repositories/device_repository_impl.dart';
import '../../domain/usecases/register_device_usecase.dart';
import '../../domain/usecases/update_fcm_token_usecase.dart';
import 'dependency_providers.dart';

// Storage provider
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

// Remote data source provider
final deviceRemoteDataSourceProvider = Provider<DeviceRemoteDataSource>((ref) {
  final client = ref.watch(dioClientProvider);
  return DeviceRemoteDataSourceImpl(client);
});

// Repository provider
final deviceRepositoryProvider = Provider<DeviceRepositoryImpl>((ref) {
  final remoteDataSource = ref.watch(deviceRemoteDataSourceProvider);
  final networkInfo = ref.watch(networkInfoProvider);
  return DeviceRepositoryImpl(remoteDataSource, networkInfo);
});

// Use cases providers
final registerDeviceUseCaseProvider = Provider<RegisterDeviceUseCase>((ref) {
  final repository = ref.watch(deviceRepositoryProvider);
  return RegisterDeviceUseCase(repository);
});

final updateFcmTokenUseCaseProvider = Provider<UpdateFcmTokenUseCase>((ref) {
  final repository = ref.watch(deviceRepositoryProvider);
  return UpdateFcmTokenUseCase(repository);
});

// Device state
class DeviceState {
  final String? deviceId;
  final String? fcmToken;
  final bool isRegistered;
  final bool isLoading;
  final String? error;

  DeviceState({
    this.deviceId,
    this.fcmToken,
    this.isRegistered = false,
    this.isLoading = false,
    this.error,
  });

  DeviceState copyWith({
    String? deviceId,
    String? fcmToken,
    bool? isRegistered,
    bool? isLoading,
    String? error,
  }) {
    return DeviceState(
      deviceId: deviceId ?? this.deviceId,
      fcmToken: fcmToken ?? this.fcmToken,
      isRegistered: isRegistered ?? this.isRegistered,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Device notifier
class DeviceNotifier extends StateNotifier<DeviceState> {
  final RegisterDeviceUseCase registerDeviceUseCase;
  final UpdateFcmTokenUseCase updateFcmTokenUseCase;
  final FlutterSecureStorage secureStorage;

  DeviceNotifier({
    required this.registerDeviceUseCase,
    required this.updateFcmTokenUseCase,
    required this.secureStorage,
  }) : super(DeviceState());

  // Cargar información del dispositivo desde storage
  Future<void> loadDeviceInfo() async {
    final deviceId = await secureStorage.read(key: 'device_id');
    final fcmToken = await secureStorage.read(key: 'fcm_token');

    if (deviceId != null) {
      state = state.copyWith(
        deviceId: deviceId,
        fcmToken: fcmToken,
        isRegistered: true,
      );
    }
  }

  // Registrar dispositivo
  Future<void> registerDevice({
    required String deviceIdentifier,
    required String platform,
    required String fcmToken,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final device = await registerDeviceUseCase(
        deviceIdentifier: deviceIdentifier,
        platform: platform,
        fcmToken: fcmToken,
      );

      // Guardar en storage
      await secureStorage.write(key: 'device_id', value: device.deviceId);
      await secureStorage.write(key: 'fcm_token', value: fcmToken);

      state = state.copyWith(
        deviceId: device.deviceId,
        fcmToken: fcmToken,
        isRegistered: true,
        isLoading: false,
      );

      print('✅ Dispositivo registrado: ${device.deviceId}');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      print('❌ Error registrando dispositivo: $e');
    }
  }

  // Actualizar FCM token
  Future<void> updateFcmToken(String newToken) async {
    if (state.deviceId == null) {
      print('⚠️ No hay deviceId, no se puede actualizar token');
      return;
    }

    try {
      await updateFcmTokenUseCase(
        deviceId: state.deviceId!,
        fcmToken: newToken,
      );

      await secureStorage.write(key: 'fcm_token', value: newToken);

      state = state.copyWith(fcmToken: newToken);

      print('✅ Token FCM actualizado');
    } catch (e) {
      print('❌ Error actualizando token: $e');
    }
  }
}

// Device provider
final deviceProvider = StateNotifierProvider<DeviceNotifier, DeviceState>((ref) {
  final registerUseCase = ref.watch(registerDeviceUseCaseProvider);
  final updateTokenUseCase = ref.watch(updateFcmTokenUseCaseProvider);
  final storage = ref.watch(secureStorageProvider);

  return DeviceNotifier(
    registerDeviceUseCase: registerUseCase,
    updateFcmTokenUseCase: updateTokenUseCase,
    secureStorage: storage,
  );
});
