// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_result_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SyncResultModel _$SyncResultModelFromJson(Map<String, dynamic> json) =>
    SyncResultModel(
      batchId: json['batchId'] as String?,
      syncedCount: (json['syncedCount'] as num).toInt(),
      failedCount: (json['failedCount'] as num).toInt(),
      results: (json['results'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
    );

Map<String, dynamic> _$SyncResultModelToJson(SyncResultModel instance) =>
    <String, dynamic>{
      'batchId': instance.batchId,
      'syncedCount': instance.syncedCount,
      'failedCount': instance.failedCount,
      'results': instance.results,
    };
