import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/sync_result.dart';

part 'sync_result_model.g.dart';

@JsonSerializable()
class SyncResultModel {
  final String? batchId;
  final int syncedCount;
  final int failedCount;
  final List<Map<String, dynamic>> results;

  const SyncResultModel({
    this.batchId,
    required this.syncedCount,
    required this.failedCount,
    required this.results,
  });

  factory SyncResultModel.fromJson(Map<String, dynamic> json) =>
      _$SyncResultModelFromJson(json);

  Map<String, dynamic> toJson() => _$SyncResultModelToJson(this);

  SyncResult toEntity() {
    final itemResults = results.map((json) {
      return SyncItemResult(
        tempId: json['tempId'] as String,
        serverId: json['serverId'] as String?,
        status: json['status'] as String,
        message: json['message'] as String,
        errorCode: json['errorCode'] as String?,
      );
    }).toList();

    return SyncResult(
      batchId: batchId,
      syncedCount: syncedCount,
      failedCount: failedCount,
      results: itemResults,
    );
  }
}
