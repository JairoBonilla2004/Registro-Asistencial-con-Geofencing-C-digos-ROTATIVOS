import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/student_dashboard.dart';
import '../../domain/entities/teacher_dashboard.dart';
import 'dependency_providers.dart';

/// Estado del Dashboard
class DashboardState {
  final dynamic dashboard; // Puede ser StudentDashboard o TeacherDashboard
  final bool isLoading;
  final String? error;

  DashboardState({
    this.dashboard,
    this.isLoading = false,
    this.error,
  });

  // Helper para saber el tipo de dashboard
  bool get isStudentDashboard => dashboard is StudentDashboard;
  bool get isTeacherDashboard => dashboard is TeacherDashboard;
  
  StudentDashboard? get studentDashboard => 
      dashboard is StudentDashboard ? dashboard as StudentDashboard : null;
  
  TeacherDashboard? get teacherDashboard => 
      dashboard is TeacherDashboard ? dashboard as TeacherDashboard : null;

  DashboardState copyWith({
    dynamic dashboard,
    bool? isLoading,
    String? error,
  }) {
    return DashboardState(
      dashboard: dashboard ?? this.dashboard,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Notifier del Dashboard
class DashboardNotifier extends StateNotifier<DashboardState> {
  final Ref ref;

  DashboardNotifier(this.ref) : super(DashboardState());

  Future<void> loadDashboard() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final useCase = ref.read(getDashboardUseCaseProvider);
      final result = await useCase();

      result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            error: failure.message,
          );
        },
        (dashboard) {
          state = state.copyWith(
            dashboard: dashboard,
            isLoading: false,
            error: null,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error inesperado: $e',
      );
    }
  }
}

/// Provider del Dashboard
final dashboardNotifierProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  return DashboardNotifier(ref);
});
