import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/report.dart';
import '../../domain/usecases/report/generate_report_usecase.dart';
import '../../domain/usecases/report/get_reports_usecase.dart';
import '../../domain/usecases/report/download_report_usecase.dart';
import '../../domain/usecases/report/delete_report_usecase.dart';
import 'dependency_providers.dart';

// Use Cases Providers
final generateReportUseCaseProvider = Provider<GenerateReportUseCase>((ref) {
  final repository = ref.watch(reportRepositoryProvider);
  return GenerateReportUseCase(repository);
});

final getReportsUseCaseProvider = Provider<GetReportsUseCase>((ref) {
  final repository = ref.watch(reportRepositoryProvider);
  return GetReportsUseCase(repository);
});

final downloadReportUseCaseProvider = Provider<DownloadReportUseCase>((ref) {
  final repository = ref.watch(reportRepositoryProvider);
  return DownloadReportUseCase(repository);
});

final deleteReportUseCaseProvider = Provider<DeleteReportUseCase>((ref) {
  final repository = ref.watch(reportRepositoryProvider);
  return DeleteReportUseCase(repository);
});

// State
class ReportState {
  final List<Report> reports;
  final bool isLoading;
  final String? error;
  final bool isGenerating;

  const ReportState({
    this.reports = const [],
    this.isLoading = false,
    this.error,
    this.isGenerating = false,
  });

  ReportState copyWith({
    List<Report>? reports,
    bool? isLoading,
    String? error,
    bool? isGenerating,
  }) {
    return ReportState(
      reports: reports ?? this.reports,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isGenerating: isGenerating ?? this.isGenerating,
    );
  }
}

// Notifier
class ReportNotifier extends StateNotifier<ReportState> {
  final GenerateReportUseCase _generateReportUseCase;
  final GetReportsUseCase _getReportsUseCase;

  ReportNotifier(this._generateReportUseCase, this._getReportsUseCase)
      : super(const ReportState());

  Future<void> loadReports() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _getReportsUseCase();

    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (reports) => state =
          state.copyWith(isLoading: false, reports: reports, error: null),
    );
  }

  Future<bool> generateReport({
    required String reportType,
    DateTime? startDate,
    DateTime? endDate,
    String? sessionId,
  }) async {
    state = state.copyWith(isGenerating: true, error: null);

    final result = await _generateReportUseCase(
      reportType: reportType,
      startDate: startDate,
      endDate: endDate,
      sessionId: sessionId,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(isGenerating: false, error: failure.message);
        return false;
      },
      (report) {
        state = state.copyWith(
          isGenerating: false,
          reports: [...state.reports, report],
          error: null,
        );
        return true;
      },
    );
  }
}

// Provider
final reportNotifierProvider =
    StateNotifierProvider<ReportNotifier, ReportState>((ref) {
  final generateUseCase = ref.watch(generateReportUseCaseProvider);
  final getReportsUseCase = ref.watch(getReportsUseCaseProvider);
  return ReportNotifier(generateUseCase, getReportsUseCase);
});
