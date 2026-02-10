import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/session_provider.dart';
import '../../widgets/atoms/loading_widget.dart';
import '../../widgets/atoms/empty_state_widget.dart';

class MySessionsPage extends ConsumerStatefulWidget {
  const MySessionsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<MySessionsPage> createState() => _MySessionsPageState();
}

class _MySessionsPageState extends ConsumerState<MySessionsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sessionProvider.notifier).loadMySessions();
    });
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  String _calculateDuration(DateTime start, DateTime? end) {
    if (end == null) return 'En curso';
    
    final duration = end.difference(start);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}min';
    }
    return '${minutes}min';
  }

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(sessionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Sesiones'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(sessionProvider.notifier).loadMySessions();
            },
          ),
        ],
      ),
      body: sessionState.isLoading
          ? const Center(child: LoadingWidget(message: 'Cargando sesiones...'))
          : sessionState.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        sessionState.error!,
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          ref.read(sessionProvider.notifier).loadMySessions();
                        },
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : sessionState.activeSessions.isEmpty
                  ? EmptyStateWidget(
                      icon: Icons.event_busy,
                      message: 'No tienes sesiones creadas',
                      action: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, '/create-session');
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Crear Primera Sesión'),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        await ref.read(sessionProvider.notifier).loadMySessions();
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: sessionState.activeSessions.length,
                        itemBuilder: (context, index) {
                          final session = sessionState.activeSessions[index];
                          final isActive = session.active;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            elevation: 2,
                            child: InkWell(
                              onTap: () {
                                ref.read(sessionProvider.notifier).setCurrentSession(session);
                                Navigator.pushNamed(
                                  context,
                                  '/session-detail',
                                  arguments: session.sessionId,
                                );
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Header
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: isActive ? Colors.green.shade50 : Colors.grey.shade50,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Icon(
                                            isActive ? Icons.play_circle_filled : Icons.stop_circle,
                                            color: isActive ? Colors.green : Colors.grey,
                                            size: 32,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
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
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: isActive ? Colors.green : Colors.grey,
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  isActive ? 'ACTIVA' : 'FINALIZADA',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Icon(Icons.chevron_right, color: Colors.grey),
                                      ],
                                    ),

                                    const Divider(height: 24),

                                    // Información
                                    _buildInfoRow(
                                      Icons.calendar_today,
                                      'Inicio',
                                      _formatDateTime(session.startTime),
                                    ),
                                    if (!isActive && session.endTime != null) ...[
                                      const SizedBox(height: 8),
                                      _buildInfoRow(
                                        Icons.event_available,
                                        'Fin',
                                        _formatDateTime(session.endTime!),
                                      ),
                                    ],
                                    const SizedBox(height: 8),
                                    _buildInfoRow(
                                      Icons.access_time,
                                      'Duración',
                                      _calculateDuration(session.startTime, session.endTime),
                                    ),
                                    const SizedBox(height: 8),
                                    _buildInfoRow(
                                      Icons.location_on,
                                      'Zona',
                                      session.zoneName,
                                    ),

                                    if (isActive) ...[
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: OutlinedButton.icon(
                                              onPressed: () {
                                                ref.read(sessionProvider.notifier).setCurrentSession(session);
                                                Navigator.pushNamed(
                                                  context,
                                                  '/session-detail',
                                                  arguments: session.sessionId,
                                                );
                                              },
                                              icon: const Icon(Icons.visibility, size: 18),
                                              label: const Text('Ver Detalle'),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/create-session');
        },
        icon: const Icon(Icons.add),
        label: const Text('Nueva Sesión'),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
