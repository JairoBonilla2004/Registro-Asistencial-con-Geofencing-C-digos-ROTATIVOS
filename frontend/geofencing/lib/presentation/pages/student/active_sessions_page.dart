import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/active_sessions_provider.dart';
import '../../../data/models/session_with_distance_model.dart';
import 'scan_qr_page.dart';

class ActiveSessionsPage extends ConsumerStatefulWidget {
  const ActiveSessionsPage({super.key});

  @override
  ConsumerState<ActiveSessionsPage> createState() => _ActiveSessionsPageState();
}

class _ActiveSessionsPageState extends ConsumerState<ActiveSessionsPage> {
  @override
  void initState() {
    super.initState();
    // Iniciar tracking cuando se abre la página
    Future.microtask(() {
      ref.read(activeSessionsProvider.notifier).startTracking();
    });
  }

  @override
  void dispose() {
    // Detener tracking cuando se cierra la página
    ref.read(activeSessionsProvider.notifier).stopTracking();
    super.dispose();
  }

  Widget _buildCurrentLocationPanel(ActiveSessionsState state) {
    if (state.lastPosition == null) {
      return Container(
        padding: const EdgeInsets.all(12),
        color: Colors.orange[100],
        child: Row(
          children: [
            const CircularProgressIndicator(strokeWidth: 2),
            const SizedBox(width: 12),
            const Text('Obteniendo ubicación...'),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        border: Border(
          bottom: BorderSide(color: Colors.blue[200]!, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.my_location, color: Colors.blue[700], size: 20),
              const SizedBox(width: 8),
              const Text(
                'Tu ubicación actual:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Lat: ${state.lastPosition!.latitude.toStringAsFixed(7)}',
            style: TextStyle(fontSize: 12, color: Colors.grey[700], fontFamily: 'monospace'),
          ),
          Text(
            'Lng: ${state.lastPosition!.longitude.toStringAsFixed(7)}',
            style: TextStyle(fontSize: 12, color: Colors.grey[700], fontFamily: 'monospace'),
          ),
          Text(
            'Precisión: ±${state.lastPosition!.accuracy.toStringAsFixed(1)}m',
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sessionsState = ref.watch(activeSessionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sesiones Activas'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(activeSessionsProvider.notifier).startTracking();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Panel de ubicación actual
          _buildCurrentLocationPanel(sessionsState),
          // Lista de sesiones
          Expanded(child: _buildBody(sessionsState)),
        ],
      ),
    );
  }

  Widget _buildBody(ActiveSessionsState state) {
    if (state.isLoading && state.sessions.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Cargando sesiones...'),
          ],
        ),
      );
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              state.error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(activeSessionsProvider.notifier).startTracking();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (state.sessions.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No hay sesiones activas',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Consulta con tu docente el horario de clases',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.read(activeSessionsProvider.notifier).startTracking();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.sessions.length,
        itemBuilder: (context, index) {
          final session = state.sessions[index];
          return _buildSessionCard(session);
        },
      ),
    );
  }

  Widget _buildSessionCard(SessionWithDistanceModel session) {
    final canScan = session.canScanQR();
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado con nombre de sesión y emoji
            Row(
              children: [
                Text(
                  session.getProximityEmoji(),
                  style: const TextStyle(fontSize: 32),
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
                      Text(
                        'Prof. ${session.teacherName}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const Divider(height: 24),
            
            // Información de ubicación de la zona
            Row(
              children: [
                Icon(Icons.location_on, size: 20, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    session.zoneName,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Coordenadas de la zona (técnico)
            Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Coordenadas Zona:',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey[700]),
                  ),
                  Text(
                    'Lat: ${session.zoneLatitude.toStringAsFixed(7)}',
                    style: TextStyle(fontSize: 10, fontFamily: 'monospace', color: Colors.grey[600]),
                  ),
                  Text(
                    'Lng: ${session.zoneLongitude.toStringAsFixed(7)}',
                    style: TextStyle(fontSize: 10, fontFamily: 'monospace', color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Radio zona: ${session.radiusMeters}m',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blue[700]),
                  ),
                ],
              ),
            ),
            
            // Distancia calculada con indicador visual
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: session.withinZone ? Colors.green[50] : Colors.orange[50],
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: session.withinZone ? Colors.green : Colors.orange,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.social_distance,
                    size: 20,
                    color: session.withinZone ? Colors.green[700] : Colors.orange[700],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Distancia: ${session.getDistanceText()}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: session.withinZone ? Colors.green[700] : Colors.orange[700],
                          ),
                        ),
                        Text(
                          session.getProximityMessage(),
                          style: TextStyle(
                            fontSize: 12,
                            color: session.withinZone ? Colors.green[600] : Colors.orange[600],
                          ),
                        ),
                        Text(
                          'Calculado: ${session.distanceInMeters.toStringAsFixed(2)}m',
                          style: TextStyle(fontSize: 10, fontFamily: 'monospace', color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    session.withinZone ? Icons.check_circle : Icons.cancel,
                    color: session.withinZone ? Colors.green : Colors.red,
                    size: 28,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Barra de progreso de distancia
            _buildDistanceProgressBar(session),
            
            const SizedBox(height: 16),
            
            // Botón para escanear QR
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: canScan
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ScanQRPage(),
                          ),
                        );
                      }
                    : null,
                icon: Icon(canScan ? Icons.qr_code_scanner : Icons.lock),
                label: Text(
                  canScan ? 'Escanear QR' : 'Demasiado lejos',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: canScan ? Colors.deepPurple : Colors.grey,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDistanceProgressBar(SessionWithDistanceModel session) {
    // Calcular progreso (100% = dentro de la zona, 0% = 500m+)
    final maxDistance = 500.0;
    final progress = (1 - (session.distanceInMeters / maxDistance)).clamp(0.0, 1.0);
    
    Color progressColor;
    if (session.withinZone) {
      progressColor = Colors.green;
    } else if (session.distanceInMeters <= 50) {
      progressColor = Colors.lightGreen;
    } else if (session.distanceInMeters <= 100) {
      progressColor = Colors.orange;
    } else {
      progressColor = Colors.red;
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Proximidad',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            Text(
              '${(progress * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: progressColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
          ),
        ),
      ],
    );
  }
}
