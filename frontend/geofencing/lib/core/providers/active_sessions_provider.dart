import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart';
import '../../data/models/api_response_model.dart';
import '../../data/models/session_with_distance_model.dart';
import '../constants/api_constants.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../presentation/providers/dependency_providers.dart';

class ActiveSessionsState {
  final bool isLoading;
  final List<SessionWithDistanceModel> sessions;
  final String? error;
  final Position? lastPosition;

  const ActiveSessionsState({
    this.isLoading = false,
    this.sessions = const [],
    this.error,
    this.lastPosition,
  });

  ActiveSessionsState copyWith({
    bool? isLoading,
    List<SessionWithDistanceModel>? sessions,
    String? error,
    Position? lastPosition,
  }) {
    return ActiveSessionsState(
      isLoading: isLoading ?? this.isLoading,
      sessions: sessions ?? this.sessions,
      error: error,
      lastPosition: lastPosition ?? this.lastPosition,
    );
  }
}

class ActiveSessionsNotifier extends StateNotifier<ActiveSessionsState> {
  final Ref ref;
  Timer? _locationTimer;
  final Dio _dio;
  bool _isDisposed = false;

  ActiveSessionsNotifier(this.ref, this._dio)
      : super(const ActiveSessionsState());

  Future<void> startTracking() async {
    // Solo cargar una vez al inicio, no hacer polling automático
    // El usuario puede refrescar manualmente con el botón
    await _fetchSessionsWithCurrentLocation();
  }

  // Método público para refrescar manualmente desde el UI
  Future<void> refresh() async {
    print('🔄 DEBUG - refresh() llamado');
    await _fetchSessionsWithCurrentLocation();
  }

  Future<void> _fetchSessionsWithCurrentLocation() async {
    try {
      // Verificar si aún está activo
      if (_isDisposed) return;
      
      // Obtener ubicación actual con LA MEJOR PRECISIÓN posible
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation, // Máxima precisión para validación de radio pequeño
      );

      if (_isDisposed) return;
      state = state.copyWith(lastPosition: position);

      // Llamar al endpoint con la ubicación
      await _fetchSessions(position.latitude, position.longitude);
    } catch (e) {
      if (_isDisposed) return;
      state = state.copyWith(error: 'Error obteniendo ubicación: $e');
    }
  }

  Future<void> _fetchSessions(double latitude, double longitude) async {
    try {
      if (_isDisposed) return;
      state = state.copyWith(isLoading: true, error: null);

      // Verificar que el usuario esté autenticado
      final authState = ref.read(authProvider);
      if (!authState.isAuthenticated) {
        if (_isDisposed) return;
        state = state.copyWith(
          isLoading: false,
          error: 'No estás autenticado. Por favor, inicia sesión.',
        );
        return;
      }

      // El DioClient ya maneja el token automáticamente desde secure storage
      final response = await _dio.get(
        ApiConstants.activeSessionsWithDistances,
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
        },
      );

      if (response.statusCode == 200) {
        if (_isDisposed) return;
        
        final apiResponse = ApiResponseModel.fromJson(
          response.data,
          (json) => json, // Mantener como dynamic para procesar manualmente
        );
        
        print('🔍 DEBUG - API Response success: ${apiResponse.success}');
        print('🔍 DEBUG - API Response data type: ${apiResponse.data.runtimeType}');
        print('🔍 DEBUG - API Response data: ${apiResponse.data}');
        
        if (apiResponse.success) {
          final List<dynamic> sessionsJson = apiResponse.data as List<dynamic>;
          final sessions = sessionsJson
              .map((json) => SessionWithDistanceModel.fromJson(json))
              .toList();

          // Ordenar por distancia (más cerca primero)
          sessions.sort((a, b) => a.distanceInMeters.compareTo(b.distanceInMeters));

          print('🔍 DEBUG - Sessions fetched: ${sessions.length}');
          sessions.forEach((s) => print('  - ${s.name}: ${s.distanceInMeters}m'));

          if (_isDisposed) return;
          state = state.copyWith(
            isLoading: false,
            sessions: sessions,
          );
          print('🔍 DEBUG - State updated with ${state.sessions.length} sessions');
        } else {
          if (_isDisposed) return;
          state = state.copyWith(
            isLoading: false,
            error: apiResponse.message ?? 'Error desconocido',
          );
        }
      } else {
        if (_isDisposed) return;
        state = state.copyWith(
          isLoading: false,
          error: 'Error del servidor: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (_isDisposed) return;
      state = state.copyWith(
        isLoading: false,
        error: 'Error de conexión: ${e.message}',
      );
    } catch (e) {
      if (_isDisposed) return;
      state = state.copyWith(
        isLoading: false,
        error: 'Error inesperado: $e',
      );
    }
  }

  void stopTracking() {
    _locationTimer?.cancel();
    _locationTimer = null;
  }

  @override
  void dispose() {
    _isDisposed = true;
    stopTracking();
    super.dispose();
  }
}

final activeSessionsProvider =
    StateNotifierProvider<ActiveSessionsNotifier, ActiveSessionsState>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ActiveSessionsNotifier(ref, dioClient.dio);
});
