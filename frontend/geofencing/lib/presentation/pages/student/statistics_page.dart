import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/student_dashboard.dart';
import '../../../domain/entities/teacher_dashboard.dart';
import '../../providers/dashboard_provider.dart';

class StatisticsPage extends ConsumerStatefulWidget {
  const StatisticsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends ConsumerState<StatisticsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(dashboardNotifierProvider.notifier).loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardNotifierProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estadísticas Generales'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(dashboardNotifierProvider.notifier).loadDashboard();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(dashboardNotifierProvider.notifier).loadDashboard(),
        child: _buildBody(state),
      ),
    );
  }

  Widget _buildBody(DashboardState state) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              'Error',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                state.error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(dashboardNotifierProvider.notifier).loadDashboard();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (state.dashboard == null) {
      return const Center(
        child: Text('No hay datos disponibles'),
      );
    }

    // Detectar si es teacher o student dashboard
    if (state.isTeacherDashboard) {
      return _buildTeacherDashboard(state.teacherDashboard!);
    } else if (state.isStudentDashboard) {
      return _buildStudentDashboard(state.studentDashboard!);
    }

    return const Center(
      child: Text('Tipo de dashboard no reconocido'),
    );
  }

  Widget _buildStudentDashboard(StudentDashboard dashboard) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Header Card
        Card(
          elevation: 4,
          color: Colors.purple.shade50,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(Icons.analytics, size: 48, color: Colors.purple.shade700),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mi Panel de Asistencia',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Resumen de tu desempeño académico',
                        style: TextStyle(
                          color: Colors.purple.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Resumen General
        Text(
          'Resumen General',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Sesiones Totales',
                dashboard.overview.totalSessions.toString(),
                Icons.event_available,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Asistencias',
                dashboard.overview.attendedSessions.toString(),
                Icons.check_circle,
                Colors.green,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Tasa de Asistencia
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.trending_up, color: Colors.orange.shade700, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tasa de Asistencia',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${dashboard.overview.attendanceRate.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: _getAttendanceColor(dashboard.overview.attendanceRate),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: dashboard.overview.attendanceRate / 100,
                  backgroundColor: Colors.grey.shade200,
                  color: _getAttendanceColor(dashboard.overview.attendanceRate),
                  minHeight: 8,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Estado de Sincronización
        Text(
          'Estado de Sincronización',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 12),

        Card(
          elevation: 2,
          child: ListTile(
            leading: Icon(
              dashboard.syncStatus.pendingSync > 0
                  ? Icons.sync_problem
                  : Icons.cloud_done,
              color: dashboard.syncStatus.pendingSync > 0
                  ? Colors.orange
                  : Colors.green,
              size: 32,
            ),
            title: Text(
              dashboard.syncStatus.pendingSync > 0
                  ? 'Sincronizaciones Pendientes'
                  : 'Todo Sincronizado',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              dashboard.syncStatus.pendingSync > 0
                  ? '${dashboard.syncStatus.pendingSync} registro(s) pendiente(s)'
                  : dashboard.syncStatus.lastSyncAt != null
                      ? 'Última sync: ${_formatDateTime(dashboard.syncStatus.lastSyncAt!)}'
                      : 'No hay datos de sincronización',
            ),
            trailing: dashboard.syncStatus.pendingSync > 0
                ? const Icon(Icons.warning, color: Colors.orange)
                : const Icon(Icons.check_circle, color: Colors.green),
          ),
        ),

        const SizedBox(height: 24),

        // Asistencias Recientes
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Asistencias Recientes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            if (dashboard.recentAttendances.isNotEmpty)
              TextButton.icon(
                onPressed: () {
                  // Navegar a historial completo
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Navega a "Mi Historial" desde el menú principal'),
                    ),
                  );
                },
                icon: const Icon(Icons.arrow_forward, size: 16),
                label: const Text('Ver todo'),
              ),
          ],
        ),
        const SizedBox(height: 12),

        if (dashboard.recentAttendances.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  Icon(Icons.event_busy, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No hay asistencias registradas',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...(dashboard.recentAttendances.map((attendance) {
            return Card(
              elevation: 1,
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.shade100,
                  child: Icon(Icons.check, color: Colors.blue.shade700),
                ),
                title: Text(
                  attendance.zoneName ?? 'Sesión',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.person, size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            attendance.teacherName ?? 'Profesor',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            attendance.zoneName ?? 'Zona',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatDate(attendance.deviceTime),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatTime(attendance.deviceTime),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList()),

        const SizedBox(height: 24),

        // Notificaciones
        if (dashboard.notificationStatus.unreadCount > 0)
          Card(
            color: Colors.amber.shade50,
            child: ListTile(
              leading: Icon(Icons.notifications_active, color: Colors.amber.shade700, size: 32),
              title: const Text(
                'Notificaciones sin leer',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: Text(
                'Tienes ${dashboard.notificationStatus.unreadCount} notificación(es) nueva(s)',
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Navegar a notificaciones
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Navega a "Notificaciones" desde el menú principal'),
                  ),
                );
              },
            ),
          ),

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getAttendanceColor(double rate) {
    if (rate >= 90) return Colors.green;
    if (rate >= 70) return Colors.orange;
    return Colors.red;
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours} h';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} días';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Widget _buildTeacherDashboard(TeacherDashboard dashboard) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Header Card
        Card(
          elevation: 4,
          color: Colors.indigo.shade50,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(Icons.school, size: 48, color: Colors.indigo.shade700),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Panel del Docente',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Resumen de tus sesiones y estudiantes',
                        style: TextStyle(
                          color: Colors.indigo.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Resumen General
        Text(
          'Resumen General',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Sesiones Totales',
                dashboard.totalSessions.toString(),
                Icons.event_available,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Sesiones Activas',
                dashboard.activeSessions.toString(),
                Icons.play_circle,
                Colors.green,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Estudiantes',
                dashboard.totalStudentsEnrolled.toString(),
                Icons.people,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Asistencia Prom.',
                '${dashboard.averageAttendanceRate.toStringAsFixed(1)}%',
                Icons.trending_up,
                Colors.purple,
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Sesiones Recientes
        if (dashboard.recentSessions.isNotEmpty) ...[
          Text(
            'Sesiones Recientes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 12),
          ...dashboard.recentSessions.take(5).map((session) {
            return Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: session.isActive 
                      ? Colors.green.shade100 
                      : Colors.grey.shade200,
                  child: Icon(
                    session.isActive ? Icons.play_circle : Icons.event,
                    color: session.isActive ? Colors.green : Colors.grey,
                  ),
                ),
                title: Text(
                  session.sessionName,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  '${session.zoneName} • ${session.date}\n'
                  'Asistencias: ${session.totalAttendances} • '
                  'Tasa: ${session.attendanceRate.toStringAsFixed(1)}%',
                ),
                isThreeLine: true,
                trailing: session.isActive 
                    ? Chip(
                        label: const Text('Activa', style: TextStyle(fontSize: 11)),
                        backgroundColor: Colors.green.shade100,
                        labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                      )
                    : null,
              ),
            );
          }).toList(),
        ],

        const SizedBox(height: 24),

        // Estadísticas adicionales
        if (dashboard.lastSessionDate != null) ...[
          Card(
            elevation: 2,
            child: ListTile(
              leading: Icon(Icons.calendar_today, color: Colors.blue.shade700),
              title: const Text('Última Sesión'),
              subtitle: Text(_formatDate(dashboard.lastSessionDate!)),
            ),
          ),
          const SizedBox(height: 12),
        ],

        if (dashboard.mostActiveSession != null) ...[
          Card(
            elevation: 2,
            child: ListTile(
              leading: Icon(Icons.star, color: Colors.amber.shade700),
              title: const Text('Sesión Más Activa'),
              subtitle: Text(dashboard.mostActiveSession!),
            ),
          ),
        ],
      ],
    );
  }
}
