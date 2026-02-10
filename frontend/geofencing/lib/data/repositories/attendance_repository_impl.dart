import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/attendance.dart';
import '../../domain/entities/attendance_history.dart';
import '../../domain/entities/location_validation.dart';
import '../../domain/entities/sync_result.dart';
import '../../domain/entities/sensor_data.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../datasources/local/offline_attendance_datasource.dart';
import '../datasources/remote/attendance_remote_datasource.dart';
import '../datasources/remote/geofence_remote_datasource.dart';
import '../models/attendance_model.dart';
import '../models/location_validation_model.dart';
import '../models/attendance_history_model.dart';
import '../models/sync_result_model.dart';
import '../models/offline_attendance_model.dart';
import '../models/sensor_data_model.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final AttendanceRemoteDataSource remoteDataSource;
  final GeofenceRemoteDataSource geofenceRemoteDataSource;
  final OfflineAttendanceDataSource localDataSource;
  final NetworkInfo networkInfo;

  AttendanceRepositoryImpl(
    this.remoteDataSource,
    this.geofenceRemoteDataSource,
    this.localDataSource,
    this.networkInfo,
  );

  @override
  Future<Either<Failure, LocationValidation>> validateLocation({
    required String sessionId,
    required double latitude,
    required double longitude,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await geofenceRemoteDataSource.validateLocation(
          latitude: latitude,
          longitude: longitude,
        );
        return Right(LocationValidationModel.fromJson(result).toEntity());
      } on ValidationException catch (e) {
        return Left(ValidationFailure(e.message, e.code));
      } on GeofenceException catch (e) {
        return Left(GeofenceFailure(e.message));
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
  Future<Either<Failure, Attendance>> validateQR({
    required String token,
    required double latitude,
    required double longitude,
    String? deviceId,
    List<SensorData>? sensorData,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        // Convertir sensor data a modelos
        final sensorDataModels = sensorData
            ?.map((sensor) => SensorDataModel.fromEntity(sensor))
            .toList();
        
        final result = await remoteDataSource.validateQR(
          token: token,
          latitude: latitude,
          longitude: longitude,
          deviceTime: DateTime.now(),
          sensorData: sensorDataModels ?? [],
          deviceId: deviceId,
        );
        return Right(AttendanceModel.fromJson(result).toEntity());
      } on ValidationException catch (e) {
        return Left(ValidationFailure(e.message, e.code));
      } on GeofenceException catch (e) {
        return Left(GeofenceFailure(e.message));
      } on QRException catch (e) {
        return Left(QRFailure(e.message, e.code));
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message, e.code));
      } on NetworkException catch (e) {
        return Left(NetworkFailure(e.message));
      } catch (e) {
        return Left(UnknownFailure(e.toString()));
      }
    } else {
      // Modo offline: guardar asistencia localmente
      return await saveOfflineAttendance(
        sessionId: 'offline',
        token: token,
        latitude: latitude,
        longitude: longitude,
        timestamp: DateTime.now(),
      ).then((_) => Left(NetworkFailure('Asistencia guardada offline')));
    }
  }

  @override
  Future<Either<Failure, List<Attendance>>> getSessionAttendances(String sessionId) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getSessionAttendances(sessionId);
        return Right(result.map((json) => AttendanceModel.fromJson(json).toEntity()).toList());
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
  Future<Either<Failure, List<AttendanceHistory>>> getMyHistory({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getMyHistory(
          startDate: startDate,
          endDate: endDate,
        );
        return Right([AttendanceHistoryModel.fromJson(result).toEntity()]);
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
  Future<Either<Failure, SyncResult>> syncOfflineAttendances() async {
    if (await networkInfo.isConnected) {
      try {
        final pendingAttendances = await localDataSource.getAllPendingAttendances();
        
        if (pendingAttendances.isEmpty) {
          return const Right(SyncResult(
            batchId: null,
            syncedCount: 0,
            failedCount: 0,
            results: [],
          ));
        }

        // Obtener el deviceId de alguna manera
        final deviceId = pendingAttendances.first.tempId.split('-')[0];
        
        final result = await remoteDataSource.syncOfflineAttendances(
          deviceId: deviceId,
          attendances: pendingAttendances.map((a) => a.toJson()).toList(),
        );
        
        final syncResultModel = SyncResultModel.fromJson(result);
        final syncResult = syncResultModel.toEntity();
        
        // Marcar como sincronizadas las exitosas
        for (final itemResult in syncResult.results) {
          if (itemResult.isSynced) {
            await localDataSource.markAsSynced(itemResult.tempId, itemResult.serverId ?? '');
          }
        }
        
        return Right(syncResult);
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
  Future<Either<Failure, void>> saveOfflineAttendance({
    required String sessionId,
    required String token,
    required double latitude,
    required double longitude,
    required DateTime timestamp,
  }) async {
    try {
      final tempId = const Uuid().v4();
      final offlineAttendance = OfflineAttendanceModel(
        tempId: tempId,
        token: token,
        sessionId: sessionId,
        latitude: latitude,
        longitude: longitude,
        deviceTime: timestamp,
        sensorDataJson: '{}',
        createdAt: DateTime.now(),
      );
      await localDataSource.saveAttendance(offlineAttendance);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<List<Attendance>> getPendingAttendances() async {
    final offlineAttendances = await localDataSource.getAllPendingAttendances();
    return offlineAttendances.map((model) {
      return Attendance(
        attendanceId: model.tempId,
        sessionId: model.sessionId ?? '',
        studentId: '',
        studentName: '',
        deviceTime: model.deviceTime,
        serverTime: DateTime.now(), // Usar fecha actual temporalmente
        withinGeofence: false,
        latitude: model.latitude,
        longitude: model.longitude,
        sensorStatus: null,
        isSynced: model.isSynced,
        syncDelay: null,
        note: null,
      );
    }).toList();
  }
}
