// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offline_attendance_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OfflineAttendanceModelAdapter
    extends TypeAdapter<OfflineAttendanceModel> {
  @override
  final int typeId = 0;

  @override
  OfflineAttendanceModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OfflineAttendanceModel(
      tempId: fields[0] as String,
      token: fields[1] as String,
      sessionId: fields[2] as String?,
      latitude: fields[3] as double,
      longitude: fields[4] as double,
      deviceTime: fields[5] as DateTime,
      sensorDataJson: fields[6] as String,
      isSynced: fields[7] as bool,
      serverId: fields[8] as String?,
      createdAt: fields[9] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, OfflineAttendanceModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.tempId)
      ..writeByte(1)
      ..write(obj.token)
      ..writeByte(2)
      ..write(obj.sessionId)
      ..writeByte(3)
      ..write(obj.latitude)
      ..writeByte(4)
      ..write(obj.longitude)
      ..writeByte(5)
      ..write(obj.deviceTime)
      ..writeByte(6)
      ..write(obj.sensorDataJson)
      ..writeByte(7)
      ..write(obj.isSynced)
      ..writeByte(8)
      ..write(obj.serverId)
      ..writeByte(9)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OfflineAttendanceModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
