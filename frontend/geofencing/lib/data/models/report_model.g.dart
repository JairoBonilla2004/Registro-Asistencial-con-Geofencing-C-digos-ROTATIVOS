// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReportModel _$ReportModelFromJson(Map<String, dynamic> json) => ReportModel(
      id: json['id'] as String,
      reportType: json['reportType'] as String,
      requestedAt: DateTime.parse(json['requestedAt'] as String),
      status: json['status'] as String,
      filePath: json['filePath'] as String?,
    );

Map<String, dynamic> _$ReportModelToJson(ReportModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'reportType': instance.reportType,
      'requestedAt': instance.requestedAt.toIso8601String(),
      'status': instance.status,
      'filePath': instance.filePath,
    };
