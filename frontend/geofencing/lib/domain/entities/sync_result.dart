import 'package:equatable/equatable.dart';

/// Entidad de Resultado de Sincronización
class SyncResult extends Equatable {
  final String? batchId;
  final int syncedCount;
  final int failedCount;
  final List<SyncItemResult> results;

  const SyncResult({
    this.batchId,
    required this.syncedCount,
    required this.failedCount,
    required this.results,
  });

  bool get hasFailures => failedCount > 0;
  bool get isCompleteSuccess => failedCount == 0;

  @override
  List<Object?> get props => [batchId, syncedCount, failedCount, results];
}

/// Entidad de Resultado Individual de Sincronización
class SyncItemResult extends Equatable {
  final String tempId;
  final String? serverId;
  final String status; // 'SYNCED' o 'FAILED'
  final String message;
  final String? errorCode;

  const SyncItemResult({
    required this.tempId,
    this.serverId,
    required this.status,
    required this.message,
    this.errorCode,
  });

  bool get isSynced => status == 'SYNCED';
  bool get isFailed => status == 'FAILED';

  @override
  List<Object?> get props => [tempId, serverId, status, message, errorCode];
}
