import 'package:dartz/dartz.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/auth_response.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local/secure_storage_datasource.dart';
import '../datasources/remote/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final SecureStorageDataSource localDataSource;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl(
    this.remoteDataSource,
    this.localDataSource,
    this.networkInfo,
  );

  @override
  Future<Either<Failure, AuthResponse>> authenticate({
    required String provider,
    String? email,
    String? password,
    String? idToken,
    String? accessToken,
    String? fcmToken,
    String? deviceIdentifier,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.authenticate(
          provider: provider,
          email: email,
          password: password,
          idToken: idToken,
          accessToken: accessToken,
          fcmToken: fcmToken,
          deviceIdentifier: deviceIdentifier,
        );
        
        // Guardar token y usuario localmente
        await localDataSource.saveToken(result.token);
        final userModel = UserModel(
          id: result.user.id,
          email: result.user.email,
          fullName: result.user.fullName,
          provider: result.user.provider,
          roles: result.user.roles,
          enabled: result.user.enabled,
          createdAt: result.user.createdAt,
        );
        await localDataSource.saveUser(userModel);
        
        return Right(result.toEntity());
      } on AuthException catch (e) {
        return Left(AuthFailure(e.message, e.code));
      } on ValidationException catch (e) {
        return Left(ValidationFailure(e.message, e.code));
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message, e.code));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(e.message));
      } catch (e) {
        return Left(UnknownFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, AuthResponse>> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.register(
          email: email,
          password: password,
          fullName: fullName,
          role: 'STUDENT', // Rol por defecto para registro
        );
        
        // Guardar token y usuario localmente
        await localDataSource.saveToken(result.token);
        final userModel = UserModel(
          id: result.user.id,
          email: result.user.email,
          fullName: result.user.fullName,
          provider: result.user.provider,
          roles: result.user.roles,
          enabled: result.user.enabled,
          createdAt: result.user.createdAt,
        );
        await localDataSource.saveUser(userModel);
        
        return Right(result.toEntity());
      } on ValidationException catch (e) {
        return Left(ValidationFailure(e.message, e.code));
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message, e.code));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(e.message));
      } catch (e) {
        return Left(UnknownFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, void>> logout(String deviceIdentifier) async {
    try {
      if (await networkInfo.isConnected) {
        await remoteDataSource.logout(deviceIdentifier);
      }
      // Limpiar datos locales siempre
      await localDataSource.clearAll();
      return const Right(null);
    } catch (e) {
      // Incluso si falla la llamada al servidor, limpiamos localmente
      await localDataSource.clearAll();
      return const Right(null);
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      final user = await localDataSource.getUser();
      if (user != null) {
        return Right(user);
      } else {
        return Left(const CacheFailure('No hay usuario en sesión'));
      }
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<bool> hasValidSession() async {
    return await localDataSource.hasValidSession();
  }

  @override
  Future<Either<Failure, void>> reRegisterDevice() async {
    if (await networkInfo.isConnected) {
      try {
        // Obtener usuario actual
        final user = await localDataSource.getUser();
        if (user == null) {
          return Left(CacheFailure('No hay usuario en sesión'));
        }

        // Registrar dispositivo con FCM token y deviceIdentifier actuales
        await remoteDataSource.registerDevice(
          userId: user.id,
        );
        
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message, e.code));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(e.message));
      } catch (e) {
        return Left(UnknownFailure(e.toString()));
      }
    } else {
      return Left(NetworkFailure());
    }
  }
}
