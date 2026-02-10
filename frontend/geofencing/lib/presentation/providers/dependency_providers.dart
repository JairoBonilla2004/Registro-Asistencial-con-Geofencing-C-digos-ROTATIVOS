import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';

import '../../core/network/dio_client.dart';
import '../../core/network/network_info.dart';
import '../../data/datasources/local/offline_attendance_datasource.dart';
import '../../data/datasources/local/secure_storage_datasource.dart';
import '../../data/datasources/remote/attendance_remote_datasource.dart';
import '../../data/datasources/remote/auth_remote_datasource.dart';
import '../../data/datasources/remote/device_remote_datasource.dart';
import '../../data/datasources/remote/geofence_remote_datasource.dart';
import '../../data/datasources/remote/notification_remote_datasource.dart';
import '../../data/datasources/remote/report_remote_datasource.dart';
import '../../data/datasources/remote/session_remote_datasource.dart';
import '../../data/datasources/remote/statistics_remote_datasource.dart';
import '../../data/datasources/remote/user_remote_datasource.dart';
import '../../data/models/offline_attendance_model.dart';
import '../../data/repositories/attendance_repository_impl.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/device_repository_impl.dart';
import '../../data/repositories/geofence_repository_impl.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../data/repositories/report_repository_impl.dart';
import '../../data/repositories/session_repository_impl.dart';
import '../../data/repositories/statistics_repository_impl.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/device_repository.dart';
import '../../domain/repositories/geofence_repository.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../domain/repositories/report_repository.dart';
import '../../domain/repositories/session_repository.dart';
import '../../domain/repositories/statistics_repository.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/usecases/attendance/get_my_history_usecase.dart';
import '../../domain/usecases/attendance/get_session_attendances_usecase.dart';
import '../../domain/usecases/attendance/scan_qr_usecase.dart';
import '../../domain/usecases/attendance/sync_offline_attendances_usecase.dart';
import '../../domain/usecases/auth/check_auth_status_usecase.dart';
import '../../domain/usecases/auth/login_usecase.dart';
import '../../domain/usecases/auth/login_with_facebook_usecase.dart';
import '../../domain/usecases/auth/login_with_google_usecase.dart';
import '../../domain/usecases/auth/logout_usecase.dart';
import '../../domain/usecases/auth/register_usecase.dart';
import '../../domain/usecases/geofence/create_zone_usecase.dart';
import '../../domain/usecases/geofence/get_all_zones_usecase.dart';
import '../../domain/usecases/geofence/get_geofence_zones_usecase.dart';
import '../../domain/usecases/session/create_session_usecase.dart';
import '../../domain/usecases/session/end_session_usecase.dart';
import '../../domain/usecases/session/generate_qr_usecase.dart';
import '../../domain/usecases/session/get_active_sessions_usecase.dart';
import '../../domain/usecases/session/get_teacher_sessions_usecase.dart';
import '../../domain/usecases/statistics/get_dashboard_usecase.dart';

// ============= CORE PROVIDERS =============

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );
});

final connectivityProvider = Provider<Connectivity>((ref) {
  return Connectivity();
});

final dioClientProvider = Provider<DioClient>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return DioClient(storage);
});

final networkInfoProvider = Provider<NetworkInfo>((ref) {
  final connectivity = ref.watch(connectivityProvider);
  return NetworkInfo(connectivity);
});

// ============= LOCAL DATASOURCES =============

final secureStorageDataSourceProvider = Provider<SecureStorageDataSource>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return SecureStorageDataSourceImpl(storage);
});

final offlineAttendanceDataSourceProvider = Provider<OfflineAttendanceDataSource>((ref) {
  // Obtenemos la box de Hive de forma síncrona (ya debe estar abierta en main.dart)
  final box = Hive.box<OfflineAttendanceModel>('offline_attendances');
  return OfflineAttendanceDataSourceImpl(box);
});

// ============= REMOTE DATASOURCES =============

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final client = ref.watch(dioClientProvider);
  return AuthRemoteDataSourceImpl(client);
});

final sessionRemoteDataSourceProvider = Provider<SessionRemoteDataSource>((ref) {
  final client = ref.watch(dioClientProvider);
  return SessionRemoteDataSourceImpl(client);
});

final attendanceRemoteDataSourceProvider = Provider<AttendanceRemoteDataSource>((ref) {
  final client = ref.watch(dioClientProvider);
  return AttendanceRemoteDataSourceImpl(client);
});

final geofenceRemoteDataSourceProvider = Provider<GeofenceRemoteDataSource>((ref) {
  final client = ref.watch(dioClientProvider);
  return GeofenceRemoteDataSourceImpl(client);
});

final userRemoteDataSourceProvider = Provider<UserRemoteDataSource>((ref) {
  final client = ref.watch(dioClientProvider);
  return UserRemoteDataSourceImpl(client);
});

final deviceRemoteDataSourceProvider = Provider<DeviceRemoteDataSource>((ref) {
  final client = ref.watch(dioClientProvider);
  return DeviceRemoteDataSourceImpl(client);
});

final notificationRemoteDataSourceProvider = Provider<NotificationRemoteDataSource>((ref) {
  final client = ref.watch(dioClientProvider);
  return NotificationRemoteDataSourceImpl(client);
});

final statisticsRemoteDataSourceProvider = Provider<StatisticsRemoteDataSource>((ref) {
  final client = ref.watch(dioClientProvider);
  final secureStorage = ref.watch(secureStorageProvider);
  return StatisticsRemoteDataSourceImpl(client, secureStorage);
});

final reportRemoteDataSourceProvider = Provider<ReportRemoteDataSource>((ref) {
  final client = ref.watch(dioClientProvider);
  return ReportRemoteDataSourceImpl(client);
});

// ============= REPOSITORIES =============

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
  final localDataSource = ref.watch(secureStorageDataSourceProvider);
  final networkInfo = ref.watch(networkInfoProvider);
  return AuthRepositoryImpl(remoteDataSource, localDataSource, networkInfo);
});

final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  final remoteDataSource = ref.watch(sessionRemoteDataSourceProvider);
  final statisticsDataSource = ref.watch(statisticsRemoteDataSourceProvider);
  final networkInfo = ref.watch(networkInfoProvider);
  return SessionRepositoryImpl(remoteDataSource, statisticsDataSource, networkInfo);
});

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  final remoteDataSource = ref.watch(attendanceRemoteDataSourceProvider);
  final geofenceDataSource = ref.watch(geofenceRemoteDataSourceProvider);
  final localDataSource = ref.watch(offlineAttendanceDataSourceProvider);
  final networkInfo = ref.watch(networkInfoProvider);
  return AttendanceRepositoryImpl(remoteDataSource, geofenceDataSource, localDataSource, networkInfo);
});

final geofenceRepositoryProvider = Provider<GeofenceRepository>((ref) {
  final remoteDataSource = ref.watch(geofenceRemoteDataSourceProvider);
  final networkInfo = ref.watch(networkInfoProvider);
  return GeofenceRepositoryImpl(remoteDataSource, networkInfo);
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final remoteDataSource = ref.watch(userRemoteDataSourceProvider);
  final networkInfo = ref.watch(networkInfoProvider);
  return UserRepositoryImpl(remoteDataSource, networkInfo);
});

final deviceRepositoryProvider = Provider<DeviceRepository>((ref) {
  final remoteDataSource = ref.watch(deviceRemoteDataSourceProvider);
  final networkInfo = ref.watch(networkInfoProvider);
  return DeviceRepositoryImpl(remoteDataSource, networkInfo);
});

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final remoteDataSource = ref.watch(notificationRemoteDataSourceProvider);
  final networkInfo = ref.watch(networkInfoProvider);
  return NotificationRepositoryImpl(remoteDataSource, networkInfo);
});

final statisticsRepositoryProvider = Provider<StatisticsRepository>((ref) {
  final remoteDataSource = ref.watch(statisticsRemoteDataSourceProvider);
  final networkInfo = ref.watch(networkInfoProvider);
  return StatisticsRepositoryImpl(remoteDataSource, networkInfo);
});

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  final remoteDataSource = ref.watch(reportRemoteDataSourceProvider);
  final networkInfo = ref.watch(networkInfoProvider);
  return ReportRepositoryImpl(remoteDataSource, networkInfo);
});

// ============= USE CASES - AUTH =============

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LoginUseCase(repository);
});

final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return RegisterUseCase(repository);
});

final loginWithGoogleUseCaseProvider = Provider<LoginWithGoogleUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LoginWithGoogleUseCase(repository);
});

final loginWithFacebookUseCaseProvider = Provider<LoginWithFacebookUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LoginWithFacebookUseCase(repository);
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LogoutUseCase(repository);
});

final checkAuthStatusUseCaseProvider = Provider<CheckAuthStatusUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return CheckAuthStatusUseCase(repository);
});

// ============= USE CASES - SESSION =============

final getActiveSessionsUseCaseProvider = Provider<GetActiveSessionsUseCase>((ref) {
  final repository = ref.watch(sessionRepositoryProvider);
  return GetActiveSessionsUseCase(repository);
});

final getTeacherSessionsUseCaseProvider = Provider<GetTeacherSessionsUseCase>((ref) {
  final repository = ref.watch(sessionRepositoryProvider);
  return GetTeacherSessionsUseCase(repository);
});

final createSessionUseCaseProvider = Provider<CreateSessionUseCase>((ref) {
  final repository = ref.watch(sessionRepositoryProvider);
  return CreateSessionUseCase(repository);
});

final generateQRUseCaseProvider = Provider<GenerateQRUseCase>((ref) {
  final repository = ref.watch(sessionRepositoryProvider);
  return GenerateQRUseCase(repository);
});

final endSessionUseCaseProvider = Provider<EndSessionUseCase>((ref) {
  final repository = ref.watch(sessionRepositoryProvider);
  return EndSessionUseCase(repository);
});

// ============= USE CASES - ATTENDANCE =============

final scanQRUseCaseProvider = Provider<ScanQRUseCase>((ref) {
  final repository = ref.watch(attendanceRepositoryProvider);
  return ScanQRUseCase(repository);
});

final syncOfflineAttendancesUseCaseProvider = Provider<SyncOfflineAttendancesUseCase>((ref) {
  final repository = ref.watch(attendanceRepositoryProvider);
  return SyncOfflineAttendancesUseCase(repository);
});

final getMyHistoryUseCaseProvider = Provider<GetMyHistoryUseCase>((ref) {
  final repository = ref.watch(attendanceRepositoryProvider);
  return GetMyHistoryUseCase(repository);
});

final getSessionAttendancesUseCaseProvider = Provider<GetSessionAttendancesUseCase>((ref) {
  final repository = ref.watch(attendanceRepositoryProvider);
  return GetSessionAttendancesUseCase(repository);
});

// ============= USE CASES - OTHER =============

final getGeofenceZonesUseCaseProvider = Provider<GetGeofenceZonesUseCase>((ref) {
  final repository = ref.watch(geofenceRepositoryProvider);
  return GetGeofenceZonesUseCase(repository);
});

final getAllZonesUseCaseProvider = Provider<GetAllZonesUseCase>((ref) {
  final repository = ref.watch(geofenceRepositoryProvider);
  return GetAllZonesUseCase(repository);
});

final createZoneUseCaseProvider = Provider<CreateZoneUseCase>((ref) {
  final repository = ref.watch(geofenceRepositoryProvider);
  return CreateZoneUseCase(repository);
});

final getDashboardUseCaseProvider = Provider<GetDashboardUseCase>((ref) {
  final repository = ref.watch(statisticsRepositoryProvider);
  return GetDashboardUseCase(repository);
});
