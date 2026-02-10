import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/report.dart';

part 'report_model.g.dart';

@JsonSerializable()
class ReportModel {
  final String id;
  final String reportType;
  final DateTime requestedAt;
  final String status;
  final String? filePath;

  const ReportModel({
    required this.id,
    required this.reportType,
    required this.requestedAt,
    required this.status,
    this.filePath,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) =>
      _$ReportModelFromJson(json);

  // Factory con manejo de null para evitar errores de cast
  factory ReportModel.fromJsonSafe(Map<String, dynamic> json) {
    // El backend envía 'reportId', no 'id'
    final id = json['reportId']?.toString() ?? json['id']?.toString() ?? '';
    
    return ReportModel(
      id: id,
      reportType: json['reportType']?.toString() ?? 'UNKNOWN',
      requestedAt: json['requestedAt'] != null 
          ? DateTime.parse(json['requestedAt'] as String)
          : DateTime.now(),
      status: json['status']?.toString() ?? 'PENDING',
      filePath: json['filePath']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => _$ReportModelToJson(this);

  Report toEntity() {
    return Report(
      id: id,
      reportType: reportType,
      requestedAt: requestedAt,
      status: status,
      filePath: filePath,
    );
  }
}
