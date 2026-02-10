import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/error/exceptions.dart';
import '../../../core/network/dio_client.dart';
import '../../models/api_response_model.dart';
import '../../models/user_model.dart';

abstract class UserRemoteDataSource {
  Future<UserModel> getProfile();
  Future<UserModel> updateProfile(String fullName);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final DioClient client;

  UserRemoteDataSourceImpl(this.client);

  @override
  Future<UserModel> getProfile() async {
    try {
      final response = await client.dio.get(ApiConstants.profile);
      final apiResponse = ApiResponseModel<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );
      
      if (apiResponse.success && apiResponse.data != null) {
        return UserModel.fromJson(apiResponse.data!);
      } else {
        throw ServerException(
          apiResponse.message ?? 'Error al obtener perfil',
          apiResponse.errorCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<UserModel> updateProfile(String fullName) async {
    try {
      final response = await client.dio.put(
        ApiConstants.profile,
        data: {'fullName': fullName},
      );
      
      final apiResponse = ApiResponseModel<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );
      
      if (apiResponse.success && apiResponse.data != null) {
        return UserModel.fromJson(apiResponse.data!);
      } else {
        throw ServerException(
          apiResponse.message ?? 'Error al actualizar perfil',
          apiResponse.errorCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  AppException _handleDioError(DioException e) {
    if (e.response != null) {
      final statusCode = e.response!.statusCode ?? 0;
      final message = e.response!.data?['message'] ?? 'Error del servidor';
      final errorCode = e.response!.data?['error'];

      if (statusCode == 401) {
        return AuthException('Sesión expirada', 'UNAUTHORIZED');
      } else if (statusCode == 400) {
        return ValidationException(message, errorCode);
      } else {
        return ServerException(message, errorCode);
      }
    } else if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return NetworkException();
    } else {
      return NetworkException();
    }
  }
}
