import 'package:dartz/dartz.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/remote/user_remote_datasource.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  UserRepositoryImpl(this.remoteDataSource, this.networkInfo);

  @override
  Future<Either<Failure, User>> getProfile() async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getProfile();
        return Right(result.toEntity());
      } on AuthException catch (e) {
        return Left(AuthFailure(e.message, e.code));
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
  Future<Either<Failure, User>> updateProfile(String fullName) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.updateProfile(fullName);
        return Right(result.toEntity());
      } on ValidationException catch (e) {
        return Left(ValidationFailure(e.message, e.code));
      } on AuthException catch (e) {
        return Left(AuthFailure(e.message, e.code));
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
