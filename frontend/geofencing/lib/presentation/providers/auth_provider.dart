import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/auth_response.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/auth/check_auth_status_usecase.dart';
import '../../domain/usecases/auth/login_usecase.dart';
import '../../domain/usecases/auth/login_with_facebook_usecase.dart';
import '../../domain/usecases/auth/login_with_google_usecase.dart';
import '../../domain/usecases/auth/logout_usecase.dart';
import '../../domain/usecases/auth/register_usecase.dart';
import 'dependency_providers.dart';

// ============= STATE =============

class AuthState {
  final bool isAuthenticated;
  final User? user;
  final bool isLoading;
  final String? error;
  final AuthResponse? lastAuthResponse;

  const AuthState({
    this.isAuthenticated = false,
    this.user,
    this.isLoading = false,
    this.error,
    this.lastAuthResponse,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    User? user,
    bool? isLoading,
    String? error,
    AuthResponse? lastAuthResponse,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      lastAuthResponse: lastAuthResponse ?? this.lastAuthResponse,
    );
  }

  bool get isStudent => user?.roles.contains('STUDENT') ?? false;
  bool get isTeacher => user?.roles.contains('TEACHER') ?? false;
}

// ============= NOTIFIER =============

class AuthNotifier extends StateNotifier<AuthState> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final LoginWithGoogleUseCase _loginWithGoogleUseCase;
  final LoginWithFacebookUseCase _loginWithFacebookUseCase;
  final LogoutUseCase _logoutUseCase;
  final CheckAuthStatusUseCase _checkAuthStatusUseCase;
  final AuthRepository _authRepository;

  AuthNotifier({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required LoginWithGoogleUseCase loginWithGoogleUseCase,
    required LoginWithFacebookUseCase loginWithFacebookUseCase,
    required LogoutUseCase logoutUseCase,
    required CheckAuthStatusUseCase checkAuthStatusUseCase,
    required AuthRepository authRepository,
  })  : _loginUseCase = loginUseCase,
        _registerUseCase = registerUseCase,
        _loginWithGoogleUseCase = loginWithGoogleUseCase,
        _loginWithFacebookUseCase = loginWithFacebookUseCase,
        _logoutUseCase = logoutUseCase,
        _checkAuthStatusUseCase = checkAuthStatusUseCase,
        _authRepository = authRepository,
        super(const AuthState());

  /// Verifica si hay una sesión válida al iniciar la app
  /// SOLUCIÓN PROFESIONAL (estilo WhatsApp/Gmail):
  /// - Si existe sesión válida, recupera el usuario
  /// - Re-registra el dispositivo para recibir notificaciones push
  /// - Mantiene la sesión activa mientras el JWT sea válido
  Future<void> checkAuthStatus() async {
    try {
      state = state.copyWith(isLoading: true);
      
      final hasSession = await _checkAuthStatusUseCase();
      
      if (hasSession) {
        // Hay sesión válida, obtener usuario
        final userResult = await _authRepository.getCurrentUser();
        
        await userResult.fold(
          (failure) async {
            // Token expirado o inválido, limpiar sesión completamente
            print('⚠️ Token inválido o expirado - Limpiando estado');
            await logout(); // Usar logout para limpiar todo correctamente
          },
          (user) async {
            // Sesión válida, restaurar estado
            state = state.copyWith(
              isAuthenticated: true,
              user: user,
              isLoading: false,
            );
            
            // RE-REGISTRAR DISPOSITIVO automáticamente para notificaciones
            // Esto asegura que el usuario reciba notificaciones al abrir la app
            try {
              await _authRepository.reRegisterDevice();
            } catch (e) {
              print('⚠️ Error re-registrando dispositivo: $e');
              // No fallar si falla el registro del dispositivo
            }
          },
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      print('❌ Error en checkAuthStatus: $e');
      state = const AuthState(); // Limpiar estado en caso de error
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _loginUseCase(email: email, password: password);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      (authResponse) {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          user: authResponse.user,
          error: null,
          lastAuthResponse: authResponse,
        );
      },
    );
  }

  Future<void> register(String email, String password, String fullName) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _registerUseCase(
      email: email,
      password: password,
      fullName: fullName,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      (authResponse) {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          user: authResponse.user,
          error: null,
          lastAuthResponse: authResponse,
        );
      },
    );
  }

  Future<void> loginWithGoogle(String idToken) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _loginWithGoogleUseCase(idToken: idToken);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      (authResponse) {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          user: authResponse.user,
          error: null,
          lastAuthResponse: authResponse,
        );
      },
    );
  }

  Future<void> loginWithFacebook(String accessToken) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _loginWithFacebookUseCase(accessToken: accessToken);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      (authResponse) {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          user: authResponse.user,
          error: null,
          lastAuthResponse: authResponse,
        );
      },
    );
  }

  Future<void> logout() async {
    try {
      await _logoutUseCase();
    } catch (e) {
      print('⚠️ Error en logout: $e');
    } finally {
      // SIEMPRE limpiar el estado local
      state = const AuthState(
        isAuthenticated: false,
        user: null,
        isLoading: false,
        error: null,
        lastAuthResponse: null,
      );
    }
  }
}

// ============= PROVIDER =============

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    loginUseCase: ref.watch(loginUseCaseProvider),
    registerUseCase: ref.watch(registerUseCaseProvider),
    loginWithGoogleUseCase: ref.watch(loginWithGoogleUseCaseProvider),
    loginWithFacebookUseCase: ref.watch(loginWithFacebookUseCaseProvider),
    logoutUseCase: ref.watch(logoutUseCaseProvider),
    checkAuthStatusUseCase: ref.watch(checkAuthStatusUseCaseProvider),
    authRepository: ref.watch(authRepositoryProvider),
  );
});
