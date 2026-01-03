import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../domain/entities/attendance_entity.dart';

part '../attendance_state.freezed.dart';

@freezed
class AttendanceState with _$AttendanceState {
  const factory AttendanceState.initial() = InitialAttendanceState;
  const factory AttendanceState.loading() = LoadingAttendanceState;
  const factory AttendanceState.loaded(List<AttendanceEntity> attendances) = LoadedAttendanceState;
  const factory AttendanceState.registering() = RegisteringAttendanceState;
  const factory AttendanceState.registered(AttendanceEntity attendance) = RegisteredAttendanceState;
  const factory AttendanceState.error(String message) = ErrorAttendanceState;
}

@freezed
class SessionsState with _$SessionsState {
  const factory SessionsState.initial() = InitialSessionsState;
  const factory SessionsState.loading() = LoadingSessionsState;
  const factory SessionsState.loaded(List<SessionEntity> sessions) = LoadedSessionsState;
  const factory SessionsState.error(String message) = ErrorSessionsState;
}