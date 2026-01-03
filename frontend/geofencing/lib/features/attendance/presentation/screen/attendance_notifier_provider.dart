import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geofencing/features/attendance/data/repository/attendance_repository.dart';
import 'package:geolocator/geolocator.dart';
import 'attendance_state.dart';

final attendanceNotifierProvider = StateNotifierProvider<AttendanceNotifier, AttendanceState>((ref) {
  return AttendanceNotifier(ref);
});

final sessionsNotifierProvider = StateNotifierProvider<SessionsNotifier, SessionsState>((ref) {
  return SessionsNotifier(ref);
});

class AttendanceNotifier extends StateNotifier<AttendanceState> {
  final Ref _ref;

  AttendanceNotifier(this._ref) : super(const AttendanceState.initial());

  Future<void> loadMyAttendances() async {
    state = const AttendanceState.loading();

    final repository = _ref.read(attendanceRepositoryProvider);
    final result = await repository.getMyAttendances();

    result.fold(
          (failure) => state = AttendanceState.error(failure.message),
          (attendances) => state = AttendanceState.loaded(attendances),
    );
  }

  Future<void> registerAttendance({
    required String sessionId,
    required String qrToken,
  }) async {
    state = const AttendanceState.registering();

    try {
      // Obtener ubicación actual
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final repository = _ref.read(attendanceRepositoryProvider);
      final result = await repository.registerAttendance(
        sessionId: sessionId,
        qrToken: qrToken,
        deviceTime: DateTime.now(),
        latitude: position.latitude,
        longitude: position.longitude,
      );

      result.fold(
            (failure) => state = AttendanceState.error(failure.message),
            (attendance) => state = AttendanceState.registered(attendance),
      );
    } catch (e) {
      state = AttendanceState.error('Error al obtener ubicación: $e');
    }
  }
}

class SessionsNotifier extends StateNotifier<SessionsState> {
  final Ref _ref;

  SessionsNotifier(this._ref) : super(const SessionsState.initial());

  Future<void> loadActiveSessions() async {
    state = const SessionsState.loading();

    final repository = _ref.read(attendanceRepositoryProvider);
    final result = await repository.getActiveSessions();

    result.fold(
          (failure) => state = SessionsState.error(failure.message),
          (sessions) => state = SessionsState.loaded(sessions),
    );
  }
}