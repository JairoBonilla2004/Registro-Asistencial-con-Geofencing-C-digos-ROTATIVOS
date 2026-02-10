import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/sensor_capture_service.dart';
import '../../domain/entities/sensor_data.dart';
import 'dart:async';

/// Estado de los sensores
class SensorState {
  final bool isCapturing;
  final List<SensorData> capturedData;
  final bool hasMagnetometer;
  final bool hasProximity;
  final int? remainingSeconds;
  final String? error;

  const SensorState({
    this.isCapturing = false,
    this.capturedData = const [],
    this.hasMagnetometer = false,
    this.hasProximity = false,
    this.remainingSeconds,
    this.error,
  });

  SensorState copyWith({
    bool? isCapturing,
    List<SensorData>? capturedData,
    bool? hasMagnetometer,
    bool? hasProximity,
    int? remainingSeconds,
    String? error,
  }) {
    return SensorState(
      isCapturing: isCapturing ?? this.isCapturing,
      capturedData: capturedData ?? this.capturedData,
      hasMagnetometer: hasMagnetometer ?? this.hasMagnetometer,
      hasProximity: hasProximity ?? this.hasProximity,
      remainingSeconds: remainingSeconds,
      error: error,
    );
  }

  int get compassReadings =>
      capturedData.where((d) => d.type == SensorType.COMPASS).length;

  int get proximityReadings =>
      capturedData.where((d) => d.type == SensorType.PROXIMITY).length;
}

/// Notifier para manejar el estado de los sensores
class SensorNotifier extends StateNotifier<SensorState> {
  final SensorCaptureService _sensorService;
  Timer? _countdownTimer;

  SensorNotifier(this._sensorService) : super(const SensorState()) {
    _checkSensorsAvailability();
  }

  /// Verifica qué sensores están disponibles
  Future<void> _checkSensorsAvailability() async {
    try {
      final availability = await _sensorService.checkSensorsAvailability();
      state = state.copyWith(
        hasMagnetometer: availability['magnetometer'] ?? false,
        hasProximity: availability['proximity'] ?? false,
      );
    } catch (e) {
      print('Error checking sensors: $e');
    }
  }

  /// Inicia la captura de sensores
  Future<void> startCapture() async {
    if (state.isCapturing) return;

    // IMPORTANTE: Limpiar datos anteriores
    state = state.copyWith(capturedData: [], error: null, remainingSeconds: 2);

    try {
      state = state.copyWith(isCapturing: true);
      
      // Iniciar countdown
      _countdownTimer?.cancel();
      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        final remaining = 2 - timer.tick;
        if (remaining >= 0) {
          state = state.copyWith(remainingSeconds: remaining);
        } else {
          timer.cancel();
        }
      });
      
      await _sensorService.startCapture();
    } catch (e) {
      _countdownTimer?.cancel();
      state = state.copyWith(
        isCapturing: false,
        remainingSeconds: null,
        error: 'Error al iniciar sensores: $e',
      );
    }
  }

  /// Detiene la captura y obtiene los datos
  Future<List<SensorData>> stopCaptureAndGetData() async {
    _countdownTimer?.cancel();
    try {
      final data = await _sensorService.stopCaptureAndGetData();
      state = state.copyWith(
        isCapturing: false,
        remainingSeconds: null,
        capturedData: data,
      );
      return data;
    } catch (e) {
      state = state.copyWith(
        isCapturing: false,
        error: 'Error al obtener datos: $e',
      );
      return [];
    }
  }

  /// Cancela la captura
  Future<void> cancelCapture() async {
    _countdownTimer?.cancel();
    await _sensorService.cancelCapture();
    state = state.copyWith(
      isCapturing: false,
      remainingSeconds: null,
      capturedData: [],
    );
  }

  /// Limpia los datos capturados
  void clearCapturedData() {
    _countdownTimer?.cancel();
    state = state.copyWith(
      capturedData: [],
      remainingSeconds: null,
    );
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _sensorService.dispose();
    super.dispose();
  }
}

/// Provider del servicio de sensores
final sensorCaptureServiceProvider = Provider<SensorCaptureService>((ref) {
  return SensorCaptureService();
});

/// Provider del estado de sensores
final sensorProvider = StateNotifierProvider<SensorNotifier, SensorState>((ref) {
  final service = ref.watch(sensorCaptureServiceProvider);
  return SensorNotifier(service);
});
