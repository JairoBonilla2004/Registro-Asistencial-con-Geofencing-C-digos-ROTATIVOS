import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/session_provider.dart';
import '../../widgets/atoms/custom_button.dart';
import '../../widgets/atoms/loading_widget.dart';
import '../../widgets/theme_toggle_button.dart';

class TeacherHomePage extends ConsumerStatefulWidget {
  const TeacherHomePage({Key? key}) : super(key: key);

  @override
  ConsumerState<TeacherHomePage> createState() => _TeacherHomePageState();
}

class _TeacherHomePageState extends ConsumerState<TeacherHomePage> {
  @override
  void initState() {
    super.initState();
    // Cargar sesiones del docente (mis sesiones creadas)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sessionProvider.notifier).loadMySessions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(sessionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel Docente'),
        actions: [
          const ThemeToggleButton(),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // Mostrar diálogo de confirmación
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Cerrar Sesión'),
                  content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Cerrar Sesión'),
                    ),
                  ],
                ),
              );
              
              if (confirm == true && mounted) {
                // Llamar al logout para limpiar tokens
                await ref.read(authProvider.notifier).logout();
                if (mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                }
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Título
            const Text(
              'Gestión de Sesiones',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Crea y gestiona tus sesiones de asistencia',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            
            // Botones principales
            CustomButton(
              text: 'Crear Nueva Sesión',
              onPressed: () {
                Navigator.pushNamed(context, '/create-session');
              },
              icon: Icons.add_circle,
            ),
            const SizedBox(height: 12),
            CustomButton(
              text: 'Mis Sesiones',
              onPressed: () {
                Navigator.pushNamed(context, '/my-sessions');
              },
              icon: Icons.list,
              backgroundColor: Colors.blue,
            ),
            const SizedBox(height: 12),
            CustomButton(
              text: 'Zonas Geofence',
              onPressed: () {
                Navigator.pushNamed(context, '/geofence-zones');
              },
              icon: Icons.location_on,
              backgroundColor: Colors.green,
            ),
            const SizedBox(height: 12),
            CustomButton(
              text: 'Reportes',
              onPressed: () {
                Navigator.pushNamed(context, '/reports');
              },
              icon: Icons.bar_chart,
              backgroundColor: Colors.orange,
            ),
            
            const SizedBox(height: 32),
            
            // Estadísticas rápidas
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Resumen de Sesiones',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (sessionState.isLoading)
                      const Center(child: LoadingWidget())
                    else
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(
                            'Activas',
                            '${sessionState.activeSessions.where((s) => s.active).length}',
                            Icons.play_circle,
                            Colors.green,
                          ),
                          _buildStatItem(
                            'Finalizadas',
                            '${sessionState.activeSessions.where((s) => !s.active).length}',
                            Icons.check_circle,
                            Colors.grey,
                          ),
                          _buildStatItem(
                            'Total',
                            '${sessionState.activeSessions.length}',
                            Icons.event,
                            Colors.blue,
                          ),
                          _buildStatItem(
                            'Con QR',
                            '${sessionState.activeSessions.where((s) => s.hasActiveQR).length}',
                            Icons.qr_code,
                            Colors.green,
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 32, color: color),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
