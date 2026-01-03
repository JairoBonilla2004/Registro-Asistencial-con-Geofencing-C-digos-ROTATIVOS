import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geofencing/core/error/failure_exception.dart';
import 'package:geofencing/core/error/mapper_exception.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
    localDataSource: ref.watch(authLocalDataSourceProvider),
  );
});

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, AuthResult>> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await remoteDataSource.loginWithEmail(email, password);

      // Guardar token y usuario
      await localDataSource.saveToken(response.token);
      await localDataSource.saveUser(response.user);

      return Right(AuthResult(token: response.token, user: response.user));
    } on Exception catch (e) {
      return Left(ErrorMapper.mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, AuthResult>> loginWithGoogle(String idToken) async {
    try {
      final response = await remoteDataSource.loginWithGoogle(idToken);

      await localDataSource.saveToken(response.token);
      await localDataSource.saveUser(response.user);

      return Right(AuthResult(token: response.token, user: response.user));
    } on Exception catch (e) {
      return Left(ErrorMapper.mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, AuthResult>> loginWithFacebook(String accessToken) async {
    try {
      final response = await remoteDataSource.loginWithFacebook(accessToken);

      await localDataSource.saveToken(response.token);
      await localDataSource.saveUser(response.user);

      return Right(AuthResult(token: response.token, user: response.user));
    } on Exception catch (e) {
      return Left(ErrorMapper.mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getProfile() async {
    try {
      final user = await remoteDataSource.getProfile();
      await localDataSource.saveUser(user);
      return Right(user);
    } on Exception catch (e) {
      return Left(ErrorMapper.mapExceptionToFailure(e));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      await localDataSource.clearAll();
      return const Right(null);
    } on Exception catch (e) {
      return Left(ErrorMapper.mapExceptionToFailure(e));
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    final token = await localDataSource.getToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<String?> getAccessToken() async {
    return await localDataSource.getToken();
  }
}