import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'dart:math' as math;

/// Estado de la proximidad
class ProximityState {
  final double? distanceInMeters;
  final bool isCalculating;
  final Position? currentPosition;
  final String? error;
  final double? targetLatitude;
  final double? targetLongitude;
  final String? zoneName;

  const ProximityState({
    this.distanceInMeters,
    this.isCalculating = false,
    this.currentPosition,
    this.error,
    this.targetLatitude,
    this.targetLongitude,
    this.zoneName,
  });

  ProximityState copyWith({
    double? distanceInMeters,
    bool? isCalculating,
    Position? currentPosition,
    String? error,
    double? targetLatitude,
    double? targetLongitude,
    String? zoneName,
  }) {
    return ProximityState(
      distanceInMeters: distanceInMeters ?? this.distanceInMeters,
      isCalculating: isCalculating ?? this.isCalculating,
      currentPosition: currentPosition ?? this.currentPosition,
      error: error,
      targetLatitude: targetLatitude ?? this.targetLatitude,
      targetLongitude: targetLongitude ?? this.targetLongitude,
      zoneName: zoneName ?? this.zoneName,
    );
  }

  /// Indica si el estudiante está dentro de la zona permitida (ej: < 50m)
  bool get isWithinZone {
    if (distanceInMeters == null) return false;
    return distanceInMeters! <= 50.0;
  }

  /// Indica si está lo suficientemente cerca para escanear (ej: < 100m)
  bool get canScan {
    if (distanceInMeters == null) return false;
    return distanceInMeters! <= 100.0;
  }
}

/// Notifier para manejar el seguimiento de proximidad en tiempo real
class ProximityNotifier extends StateNotifier<ProximityState> {
  Timer? _locationTimer;
  StreamSubscription<Position>? _positionStream;

  ProximityNotifier() : super(const ProximityState());

  @override
  void dispose() {
    stopTracking();
    super.dispose();
  }

  /// Inicia el seguimiento de ubicación en tiempo real
  Future<void> startTracking({
    required double targetLatitude,
    required double targetLongitude,
    String? zoneName,
  }) async {
    // Guardar objetivo
    state = state.copyWith(
      targetLatitude: targetLatitude,
      targetLongitude: targetLongitude,
      zoneName: zoneName,
      isCalculating: true,
      error: null,
    );

    try {
      // Verificar permisos
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        state = state.copyWith(
          isCalculating: false,
          error: 'El servicio de ubicación está deshabilitado',
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          state = state.copyWith(
            isCalculating: false,
            error: 'Permisos de ubicación denegados',
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        state = state.copyWith(
          isCalculating: false,
          error: 'Permisos de ubicación denegados permanentemente',
        );
        return;
      }

      // Obtener ubicación inicial
      await _updateLocation();

      // Iniciar stream de ubicación (actualización cada 2 segundos)
      _positionStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 5, // Actualizar cada 5 metros de movimiento
        ),
      ).listen(
        (Position position) {
          _calculateDistance(position);
        },
        onError: (error) {
          state = state.copyWith(
            isCalculating: false,
            error: 'Error al obtener ubicación: $error',
          );
        },
      );

      // También actualizar con timer como backup (cada 3 segundos)
      _locationTimer = Timer.periodic(const Duration(seconds: 3), (_) {
        _updateLocation();
      });

    } catch (e) {
      state = state.copyWith(
        isCalculating: false,
        error: 'Error: $e',
      );
    }
  }

  /// Actualiza la ubicación actual
  Future<void> _updateLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _calculateDistance(position);
    } catch (e) {
      print('Error updating location: $e');
    }
  }

  /// Calcula la distancia al objetivo
  void _calculateDistance(Position position) {
    if (state.targetLatitude == null || state.targetLongitude == null) {
      return;
    }

    // Calcular distancia usando fórmula de Haversine
    final distance = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      state.targetLatitude!,
      state.targetLongitude!,
    );

    state = state.copyWith(
      currentPosition: position,
      distanceInMeters: distance,
      isCalculating: false,
    );
  }

  /// Detiene el seguimiento
  void stopTracking() {
    _locationTimer?.cancel();
    _locationTimer = null;
    _positionStream?.cancel();
    _positionStream = null;
    
    state = const ProximityState();
  }

  /// Obtiene una única actualización de ubicación
  Future<Position?> getSingleLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }

      if (permission == LocationPermission.deniedForever) return null;

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }
}

/// Provider del estado de proximidad
final proximityProvider = StateNotifierProvider<ProximityNotifier, ProximityState>((ref) {
  return ProximityNotifier();
});
