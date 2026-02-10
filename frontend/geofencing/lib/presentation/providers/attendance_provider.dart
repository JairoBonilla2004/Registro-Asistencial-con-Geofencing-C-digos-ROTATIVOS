import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/attendance.dart';
import '../../domain/entities/attendance_history.dart';
import '../../domain/entities/sync_result.dart';
import '../../domain/entities/sensor_data.dart';
import '../../domain/usecases/attendance/get_my_history_usecase.dart';
import '../../domain/usecases/attendance/get_session_attendances_usecase.dart';
import '../../domain/usecases/attendance/scan_qr_usecase.dart';
import '../../domain/usecases/attendance/sync_offline_attendances_usecase.dart';
import 'dependency_providers.dart';

// ============= STATE =============

class AttendanceState {
  final List<AttendanceHistory> myHistory;
  final List<Attendance> sessionAttendances;
  final Attendance? lastAttendance;
  final SyncResult? lastSyncResult;
  final bool isLoading;
  final bool isSyncing;
  final String? error;
  final String? successMessage;

  const AttendanceState({
    this.myHistory = const [],
    this.sessionAttendances = const [],
    this.lastAttendance,
    this.lastSyncResult,
    this.isLoading = false,
    this.isSyncing = false,
    this.error,
    this.successMessage,
  });

  AttendanceState copyWith({
    List<AttendanceHistory>? myHistory,
    List<Attendance>? sessionAttendances,
    Attendance? lastAttendance,
    SyncResult? lastSyncResult,
    bool? isLoading,
    bool? isSyncing,
    String? error,
    String? successMessage,
  }) {
    return AttendanceState(
      myHistory: myHistory ?? this.myHistory,
      sessionAttendances: sessionAttendances ?? this.sessionAttendances,
      lastAttendance: lastAttendance ?? this.lastAttendance,
      lastSyncResult: lastSyncResult ?? this.lastSyncResult,
      isLoading: isLoading ?? this.isLoading,
      isSyncing: isSyncing ?? this.isSyncing,
      error: error,
      successMessage: successMessage,
    );
  }

  AttendanceState clearMessages() {
    return copyWith(error: null, successMessage: null);
  }
}

// ============= NOTIFIER =============

class AttendanceNotifier extends StateNotifier<AttendanceState> {
  final ScanQRUseCase _scanQRUseCase;
  final SyncOfflineAttendancesUseCase _syncOfflineAttendancesUseCase;
  final GetMyHistoryUseCase _getMyHistoryUseCase;
  final GetSessionAttendancesUseCase _getSessionAttendancesUseCase;

  AttendanceNotifier({
    required ScanQRUseCase scanQRUseCase,
    required SyncOfflineAttendancesUseCase syncOfflineAttendancesUseCase,
    required GetMyHistoryUseCase getMyHistoryUseCase,
    required GetSessionAttendancesUseCase getSessionAttendancesUseCase,
  })  : _scanQRUseCase = scanQRUseCase,
        _syncOfflineAttendancesUseCase = syncOfflineAttendancesUseCase,
        _getMyHistoryUseCase = getMyHistoryUseCase,
        _getSessionAttendancesUseCase = getSessionAttendancesUseCase,
        super(const AttendanceState());

  Future<void> scanQR({
    required String token,
    required double latitude,
    required double longitude,
    String? deviceId,
    List<SensorData>? sensorData,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _scanQRUseCase(
      token: token,
      latitude: latitude,
      longitude: longitude,
      deviceId: deviceId,
      sensorData: sensorData,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      (attendance) {
        state = state.copyWith(
          isLoading: false,
          lastAttendance: attendance,
          successMessage: '¡Asistencia registrada exitosamente!',
          error: null,
        );
      },
    );
  }

  Future<void> syncOfflineAttendances() async {
    state = state.copyWith(isSyncing: true, error: null);

    final result = await _syncOfflineAttendancesUseCase();

    result.fold(
      (failure) {
        state = state.copyWith(
          isSyncing: false,
          error: failure.message,
        );
      },
      (syncResult) {
        final message = syncResult.failedCount == 0
            ? '${syncResult.syncedCount} asistencias sincronizadas'
            : '${syncResult.syncedCount} sincronizadas, ${syncResult.failedCount} fallidas';
        
        state = state.copyWith(
          isSyncing: false,
          lastSyncResult: syncResult,
          successMessage: message,
          error: null,
        );
      },
    );
  }

  Future<void> loadMyHistory({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _getMyHistoryUseCase(
      startDate: startDate,
      endDate: endDate,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      (history) {
        state = state.copyWith(
          isLoading: false,
          myHistory: history,
          error: null,
        );
      },
    );
  }

  Future<void> loadSessionAttendances(String sessionId) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _getSessionAttendancesUseCase(sessionId);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      (attendances) {
        state = state.copyWith(
          isLoading: false,
          sessionAttendances: attendances,
          error: null,
        );
      },
    );
  }
}

// ============= PROVIDER =============

final attendanceProvider = StateNotifierProvider<AttendanceNotifier, AttendanceState>((ref) {
  return AttendanceNotifier(
    scanQRUseCase: ref.watch(scanQRUseCaseProvider),
    syncOfflineAttendancesUseCase: ref.watch(syncOfflineAttendancesUseCaseProvider),
    getMyHistoryUseCase: ref.watch(getMyHistoryUseCaseProvider),
    getSessionAttendancesUseCase: ref.watch(getSessionAttendancesUseCaseProvider),
  );
});
