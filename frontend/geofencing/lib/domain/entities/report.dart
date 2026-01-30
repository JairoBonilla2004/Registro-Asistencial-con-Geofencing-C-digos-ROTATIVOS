import 'package:equatable/equatable.dart';

/// Entidad de Reporte
class Report extends Equatable {
  final String id;
  final String reportType;
  final DateTime requestedAt;
  final String status;
  final String? filePath;

  const Report({
    required this.id,
    required this.reportType,
    required this.requestedAt,
    required this.status,
    this.filePath,
  });

  bool get isCompleted => status == 'COMPLETED';
  bool get isProcessing => status == 'PROCESSING';
  bool get isFailed => status == 'FAILED';

  @override
  List<Object?> get props => [id, reportType, requestedAt, status, filePath];
}
