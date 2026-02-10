import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../../../core/constants/app_constants.dart';
import '../../models/user_model.dart';

/// Local DataSource para almacenamiento seguro (JWT, tokens, etc.)
abstract class SecureStorageDataSource {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> saveRefreshToken(String refreshToken);
  Future<String?> getRefreshToken();
  Future<void> saveUserId(String userId);
  Future<String?> getUserId();
  Future<void> saveUserRole(String role);
  Future<String?> getUserRole();
  Future<void> saveDeviceId(String deviceId);
  Future<String?> getDeviceId();
  Future<void> saveUser(UserModel user);
  Future<UserModel?> getUser();
  Future<void> clearAll();
  Future<bool> hasValidSession();
}

class SecureStorageDataSourceImpl implements SecureStorageDataSource {
  final FlutterSecureStorage _storage;

  SecureStorageDataSourceImpl(this._storage);

  @override
  Future<void> saveToken(String token) async {
    await _storage.write(key: AppConstants.jwtTokenKey, value: token);
  }

  @override
  Future<String?> getToken() async {
    return await _storage.read(key: AppConstants.jwtTokenKey);
  }

  @override
  Future<void> saveRefreshToken(String refreshToken) async {
    await _storage.write(key: AppConstants.refreshTokenKey, value: refreshToken);
  }

  @override
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: AppConstants.refreshTokenKey);
  }

  @override
  Future<void> saveUserId(String userId) async {
    await _storage.write(key: AppConstants.userIdKey, value: userId);
  }

  @override
  Future<String?> getUserId() async {
    return await _storage.read(key: AppConstants.userIdKey);
  }

  @override
  Future<void> saveUserRole(String role) async {
    await _storage.write(key: AppConstants.userRoleKey, value: role);
  }

  @override
  Future<String?> getUserRole() async {
    return await _storage.read(key: AppConstants.userRoleKey);
  }

  @override
  Future<void> saveDeviceId(String deviceId) async {
    await _storage.write(key: AppConstants.deviceIdKey, value: deviceId);
  }

  @override
  Future<String?> getDeviceId() async {
    return await _storage.read(key: AppConstants.deviceIdKey);
  }

  @override
  Future<void> saveUser(UserModel user) async {
    final userJson = jsonEncode(user.toJson());
    await _storage.write(key: 'user_data', value: userJson);
  }

  @override
  Future<UserModel?> getUser() async {
    final userJson = await _storage.read(key: 'user_data');
    if (userJson == null) return null;
    return UserModel.fromJson(jsonDecode(userJson));
  }

  @override
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  @override
  Future<bool> hasValidSession() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
