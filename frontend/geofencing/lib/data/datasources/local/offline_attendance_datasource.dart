import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import '../../models/offline_attendance_model.dart';

/// Local DataSource para asistencias offline
abstract class OfflineAttendanceDataSource {
  Future<void> saveAttendance(OfflineAttendanceModel attendance);
  Future<List<OfflineAttendanceModel>> getAllPendingAttendances();
  Future<void> markAsSynced(String tempId, String serverId);
  Future<void> deleteAttendance(String tempId);
  Future<void> deleteAllSynced();
  Future<int> getPendingCount();
}

class OfflineAttendanceDataSourceImpl implements OfflineAttendanceDataSource {
  static const String boxName = 'offline_attendances';
  final Box<OfflineAttendanceModel> _box;

  OfflineAttendanceDataSourceImpl(this._box);

  static Future<OfflineAttendanceDataSourceImpl> create() async {
    final box = await Hive.openBox<OfflineAttendanceModel>(boxName);
    return OfflineAttendanceDataSourceImpl(box);
  }

  @override
  Future<void> saveAttendance(OfflineAttendanceModel attendance) async {
    await _box.put(attendance.tempId, attendance);
  }

  @override
  Future<List<OfflineAttendanceModel>> getAllPendingAttendances() async {
    return _box.values.where((a) => !a.isSynced).toList();
  }

  @override
  Future<void> markAsSynced(String tempId, String serverId) async {
    final attendance = _box.get(tempId);
    if (attendance != null) {
      attendance.isSynced = true;
      attendance.serverId = serverId;
      await attendance.save();
    }
  }

  @override
  Future<void> deleteAttendance(String tempId) async {
    await _box.delete(tempId);
  }

  @override
  Future<void> deleteAllSynced() async {
    final syncedKeys = _box.values
        .where((a) => a.isSynced)
        .map((a) => a.tempId)
        .toList();
    
    for (final key in syncedKeys) {
      await _box.delete(key);
    }
  }

  @override
  Future<int> getPendingCount() async {
    return _box.values.where((a) => !a.isSynced).length;
  }
}

/// Factory para crear asistencias offline
class OfflineAttendanceFactory {
  static final _uuid = Uuid();

  static OfflineAttendanceModel create({
    required String token,
    String? sessionId,
    required double latitude,
    required double longitude,
    required Map<String, String> sensorData,
  }) {
    return OfflineAttendanceModel(
      tempId: _uuid.v4(),
      token: token,
      sessionId: sessionId,
      latitude: latitude,
      longitude: longitude,
      deviceTime: DateTime.now(),
      sensorDataJson: jsonEncode(sensorData),
      createdAt: DateTime.now(),
    );
  }
}
