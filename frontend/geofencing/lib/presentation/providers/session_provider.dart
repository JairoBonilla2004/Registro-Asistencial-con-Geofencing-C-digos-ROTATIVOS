import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/attendance_session.dart';
import '../../domain/entities/qr_token.dart';
import '../../domain/usecases/session/create_session_usecase.dart';
import '../../domain/usecases/session/end_session_usecase.dart';
import '../../domain/usecases/session/generate_qr_usecase.dart';
import '../../domain/usecases/session/get_active_sessions_usecase.dart';
import '../../domain/usecases/session/get_teacher_sessions_usecase.dart';
import 'dependency_providers.dart';

// ============= STATE =============

class SessionState {
  final List<AttendanceSession> activeSessions;
  final AttendanceSession? currentSession;
  final QRToken? currentQR;
  final bool isLoading;
  final String? error;
  final String? successMessage;

  const SessionState({
    this.activeSessions = const [],
    this.currentSession,
    this.currentQR,
    this.isLoading = false,
    this.error,
    this.successMessage,
  });

  SessionState copyWith({
    List<AttendanceSession>? activeSessions,
    AttendanceSession? currentSession,
    QRToken? currentQR,
    bool? isLoading,
    String? error,
    String? successMessage,
  }) {
    return SessionState(
      activeSessions: activeSessions ?? this.activeSessions,
      currentSession: currentSession ?? this.currentSession,
      currentQR: currentQR ?? this.currentQR,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      successMessage: successMessage,
    );
  }

  SessionState clearMessages() {
    return copyWith(error: null, successMessage: null);
  }
}

// ============= NOTIFIER =============

class SessionNotifier extends StateNotifier<SessionState> {
  final GetActiveSessionsUseCase _getActiveSessionsUseCase;
  final GetTeacherSessionsUseCase _getTeacherSessionsUseCase;
  final CreateSessionUseCase _createSessionUseCase;
  final GenerateQRUseCase _generateQRUseCase;
  final EndSessionUseCase _endSessionUseCase;

  SessionNotifier({
    required GetActiveSessionsUseCase getActiveSessionsUseCase,
    required GetTeacherSessionsUseCase getTeacherSessionsUseCase,
    required CreateSessionUseCase createSessionUseCase,
    required GenerateQRUseCase generateQRUseCase,
    required EndSessionUseCase endSessionUseCase,
  })  : _getActiveSessionsUseCase = getActiveSessionsUseCase,
        _getTeacherSessionsUseCase = getTeacherSessionsUseCase,
        _createSessionUseCase = createSessionUseCase,
        _generateQRUseCase = generateQRUseCase,
        _endSessionUseCase = endSessionUseCase,
        super(const SessionState());

  Future<void> loadActiveSessions() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _getActiveSessionsUseCase();

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      (sessions) {
        state = state.copyWith(
          isLoading: false,
          activeSessions: sessions,
          error: null,
        );
      },
    );
  }

  /// Para DOCENTES: Cargar mis sesiones creadas
  Future<void> loadMySessions() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _getTeacherSessionsUseCase();

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      (sessions) {
        state = state.copyWith(
          isLoading: false,
          activeSessions: sessions,
          error: null,
        );
      },
    );
  }

  Future<void> createSession({
    required String name,
    required String zoneId,
    required int qrRotationMinutes,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _createSessionUseCase(
      name: name,
      zoneId: zoneId,
      qrRotationMinutes: qrRotationMinutes,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      (session) {
        state = state.copyWith(
          isLoading: false,
          currentSession: session,
          successMessage: 'Sesión creada exitosamente',
          error: null,
        );
        // Recargar mis sesiones (para docentes)
        loadMySessions();
      },
    );
  }

  Future<void> generateQR(String sessionId) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _generateQRUseCase(sessionId);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      (qrToken) {
        state = state.copyWith(
          isLoading: false,
          currentQR: qrToken,
          error: null,
        );
      },
    );
  }

  Future<void> endSession(String sessionId) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _endSessionUseCase(sessionId);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      (_) {
        state = state.copyWith(
          isLoading: false,
          currentSession: null,
          currentQR: null,
          successMessage: 'Sesión finalizada exitosamente',
          error: null,
        );
        // Recargar mis sesiones (para docentes)
        loadMySessions();
      },
    );
  }

  void setCurrentSession(AttendanceSession session) {
    state = state.copyWith(currentSession: session);
  }

  void clearCurrentSession() {
    state = state.copyWith(
      currentSession: null,
      currentQR: null,
    );
  }
}

// ============= PROVIDER =============

final sessionProvider = StateNotifierProvider<SessionNotifier, SessionState>((ref) {
  return SessionNotifier(
    getActiveSessionsUseCase: ref.watch(getActiveSessionsUseCaseProvider),
    getTeacherSessionsUseCase: ref.watch(getTeacherSessionsUseCaseProvider),
    createSessionUseCase: ref.watch(createSessionUseCaseProvider),
    generateQRUseCase: ref.watch(generateQRUseCaseProvider),
    endSessionUseCase: ref.watch(endSessionUseCaseProvider),
  );
});
