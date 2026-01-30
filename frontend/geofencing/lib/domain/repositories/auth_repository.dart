import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/auth_response.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthResponse>> authenticate({
    required String provider,
    String? email,
    String? password,
    String? idToken,
    String? accessToken,
    String? fcmToken,
    String? deviceIdentifier,
  });

  Future<Either<Failure, AuthResponse>> register({
    required String email,
    required String password,
    required String fullName,
  });

  Future<Either<Failure, void>> logout(String deviceIdentifier);

  Future<Either<Failure, User>> getCurrentUser();

  Future<bool> hasValidSession();
  
  /// Re-registra el dispositivo actual para recibir notificaciones
  /// Útil cuando la app se abre con una sesión válida existente
  Future<Either<Failure, void>> reRegisterDevice();
}
