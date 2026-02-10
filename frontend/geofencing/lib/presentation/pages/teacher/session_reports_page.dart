import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/attendance_session.dart';
import '../../providers/session_provider.dart';
import '../../providers/report_provider.dart';

class SessionReportsPage extends ConsumerStatefulWidget {
  const SessionReportsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<SessionReportsPage> createState() =>
      _SessionReportsPageState();
}

class _SessionReportsPageState extends ConsumerState<SessionReportsPage> {
  String _searchQuery = '';
  String _statusFilter = 'all'; // 'all', 'active', 'finished'

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(sessionProvider.notifier).loadMySessions();
    });
  }

  List<AttendanceSession> _filterSessions(List<AttendanceSession> sessions) {
    var filtered = sessions;

    // Filtrar por búsqueda
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((session) {
        return session.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            session.zoneName.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Filtrar por estado
    if (_statusFilter == 'active') {
      filtered = filtered.where((session) => session.active).toList();
    } else if (_statusFilter == 'finished') {
      filtered = filtered.where((session) => !session.active).toList();
    }

    // Ordenar por fecha descendente
    filtered.sort((a, b) => b.startTime.compareTo(a.startTime));

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sessionProvider);
    final filteredSessions = _filterSessions(state.activeSessions);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes de Sesiones'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(sessionProvider.notifier).loadMySessions();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Header con información
          Container(
            color: Colors.indigo.shade50,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.description, size: 48, color: Colors.indigo.shade700),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gestión de Reportes',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Descarga reportes de tus sesiones finalizadas',
                        style: TextStyle(
                          color: Colors.indigo.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Barra de búsqueda y filtros
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Búsqueda
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar por nombre de sesión o zona...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 12),

                // Filtros de estado
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('Todas', 'all'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Activas', 'active'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Finalizadas', 'finished'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Lista de sesiones
          Expanded(
            child: _buildSessionsList(state, filteredSessions),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _statusFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _statusFilter = value;
        });
      },
      selectedColor: Colors.indigo.shade100,
      checkmarkColor: Colors.indigo.shade700,
    );
  }

  Widget _buildSessionsList(
      SessionState state, List<AttendanceSession> sessions) {
    if (state.isLoading && sessions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && sessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              'Error al cargar sesiones',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(state.error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(sessionProvider.notifier).loadMySessions();
              },
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (sessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No se encontraron sesiones',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Intenta con otro término de búsqueda'
                  : 'Crea tu primera sesión para ver reportes',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(sessionProvider.notifier).loadMySessions(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: sessions.length,
        itemBuilder: (context, index) {
          return _buildSessionCard(sessions[index]);
        },
      ),
    );
  }

  Widget _buildSessionCard(AttendanceSession session) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final isActive = session.active;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con nombre y estado
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            session.zoneName,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Chip(
                  label: Text(
                    isActive ? 'Activa' : 'Finalizada',
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor:
                      isActive ? Colors.green.shade100 : Colors.grey.shade200,
                  labelStyle: TextStyle(
                    color:
                        isActive ? Colors.green.shade700 : Colors.grey.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Información de la sesión
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    Icons.calendar_today,
                    'Inicio',
                    dateFormat.format(session.startTime),
                  ),
                ),
                if (!isActive && session.endTime != null)
                  Expanded(
                    child: _buildInfoItem(
                      Icons.event_available,
                      'Fin',
                      dateFormat.format(session.endTime!),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Botones de acción
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Botón descargar reporte
                if (!isActive)
                  ElevatedButton.icon(
                    onPressed: () => _generateReport(session),
                    icon: const Icon(Icons.download, size: 18),
                    label: const Text('Descargar Reporte'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                    ),
                  )
                else
                  ElevatedButton.icon(
                    onPressed: () {
                      _showCannotGenerateDialog();
                    },
                    icon: const Icon(Icons.block, size: 18),
                    label: const Text('Finaliza primero'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade400,
                      foregroundColor: Colors.white,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showCannotGenerateDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('Sesión Activa'),
          ],
        ),
        content: const Text(
          'No puedes generar un reporte de una sesión que aún está activa.\n\n'
          'Por favor, finaliza la sesión primero desde "Mis Sesiones".',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  Future<void> _generateReport(AttendanceSession session) async {
    // Mostrar diálogo de confirmación
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Generar Reporte'),
        content: Text(
          '¿Deseas generar el reporte de asistencia para la sesión "${session.name}"?\n\n'
          'El reporte incluirá la lista de estudiantes que asistieron y sus datos de registro.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Generar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Mostrar indicador de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Generando reporte...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      // Generar reporte
      final useCase = ref.read(generateReportUseCaseProvider);
      final result = await useCase(
        reportType: 'SESSION_ATTENDANCE',
        sessionId: session.sessionId,
      );

      result.fold(
        (failure) {
          Navigator.pop(context); // Cerrar diálogo de carga
          _showErrorDialog(failure.message);
        },
        (report) {
          Navigator.pop(context); // Cerrar diálogo de carga
          _showSuccessDialog(session.name);
          // Recargar lista de reportes
          ref.read(reportNotifierProvider.notifier).loadReports();
        },
      );
    } catch (e) {
      Navigator.pop(context); // Cerrar diálogo de carga
      _showErrorDialog('Error inesperado: $e');
    }
  }

  void _showSuccessDialog(String sessionName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Reporte Generado'),
          ],
        ),
        content: Text(
          'El reporte de la sesión "$sessionName" se está generando.\n\n'
          'Podrás descargarlo en unos momentos desde la sección "Reportes".',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Volver a la página de reportes
            },
            child: const Text('Ver Reportes'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 8),
            Text('Error'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
