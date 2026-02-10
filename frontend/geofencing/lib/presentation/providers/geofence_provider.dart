import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/geofence_zone.dart';
import '../../domain/usecases/geofence/create_zone_usecase.dart';
import '../../domain/usecases/geofence/get_all_zones_usecase.dart';
import 'dependency_providers.dart';

// ============= STATE =============

class GeofenceState {
  final List<GeofenceZone> zones;
  final bool isLoading;
  final String? error;
  final String? successMessage;

  const GeofenceState({
    this.zones = const [],
    this.isLoading = false,
    this.error,
    this.successMessage,
  });

  GeofenceState copyWith({
    List<GeofenceZone>? zones,
    bool? isLoading,
    String? error,
    String? successMessage,
  }) {
    return GeofenceState(
      zones: zones ?? this.zones,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      successMessage: successMessage,
    );
  }

  GeofenceState clearMessages() {
    return copyWith(error: null, successMessage: null);
  }
}

// ============= NOTIFIER =============

class GeofenceNotifier extends StateNotifier<GeofenceState> {
  final GetAllZonesUseCase _getAllZonesUseCase;
  final CreateZoneUseCase _createZoneUseCase;

  GeofenceNotifier({
    required GetAllZonesUseCase getAllZonesUseCase,
    required CreateZoneUseCase createZoneUseCase,
  })  : _getAllZonesUseCase = getAllZonesUseCase,
        _createZoneUseCase = createZoneUseCase,
        super(const GeofenceState());

  Future<void> loadZones() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _getAllZonesUseCase();

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      (zones) {
        state = state.copyWith(
          isLoading: false,
          zones: zones,
        );
      },
    );
  }

  Future<void> createZone({
    required String name,
    required double latitude,
    required double longitude,
    required double radiusMeters,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _createZoneUseCase(
      name: name,
      latitude: latitude,
      longitude: longitude,
      radiusMeters: radiusMeters,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      (zone) {
        state = state.copyWith(
          isLoading: false,
          zones: [...state.zones, zone],
          successMessage: 'Zona creada exitosamente',
        );
      },
    );
  }

  void clearMessages() {
    state = state.clearMessages();
  }
}

// ============= PROVIDER =============

final geofenceProvider = StateNotifierProvider<GeofenceNotifier, GeofenceState>(
  (ref) {
    return GeofenceNotifier(
      getAllZonesUseCase: ref.read(getAllZonesUseCaseProvider),
      createZoneUseCase: ref.read(createZoneUseCaseProvider),
    );
  },
);
