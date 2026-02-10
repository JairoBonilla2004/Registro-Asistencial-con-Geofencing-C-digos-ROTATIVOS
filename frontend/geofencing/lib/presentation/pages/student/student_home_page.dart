import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/attendance_session.dart';
import '../../../core/providers/firebase_providers.dart';
import '../../../core/providers/active_sessions_provider.dart';
import '../../../data/models/session_with_distance_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/device_provider.dart';
import '../../providers/session_provider.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/atoms/empty_state_widget.dart';
import '../../widgets/atoms/error_widget.dart' as app_error;
import '../../widgets/atoms/loading_widget.dart';
import '../../widgets/molecules/session_card.dart';
import '../../widgets/notifications_panel.dart';
import '../../widgets/theme_toggle_button.dart';

class StudentHomePage extends ConsumerStatefulWidget {
  const StudentHomePage({Key? key}) : super(key: key);

  @override
  ConsumerState<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends ConsumerState<StudentHomePage> {
  Timer? _refreshTimer;
  
  @override
  void initState() {
    super.initState();
    // Cargar sesiones activas y registrar dispositivo al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sessionProvider.notifier).loadActiveSessions();
      // Iniciar tracking GPS para sesiones cercanas
      ref.read(activeSessionsProvider.notifier).startTracking();
      _registerDeviceIfNeeded();
      _setupNotificationRefresh();
      _startPeriodicRefresh();
    });
  }
  
  @override
  void dispose() {
    _refreshTimer?.cancel();
    // Detener tracking GPS
    ref.read(activeSessionsProvider.notifier).stopTracking();
    super.dispose();
  }
  
  // Configurar callback para refrescar notificaciones en tiempo real
  void _setupNotificationRefresh() {
    final firebaseService = ref.read(firebaseMessagingServiceProvider);
    firebaseService.onNotificationReceived = () {
      // Invalidar provider para refrescar el badge
      ref.invalidate(unreadNotificationsProvider);
      print('🔔 Provider de notificaciones refrescado por Firebase');
    };
  }
  
  // Polling cada 30 segundos como backup (cuando la app está activa)
  void _startPeriodicRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        ref.invalidate(unreadNotificationsProvider);
        print('🔄 Refresh periódico de notificaciones (cada 30s)');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(sessionProvider);
    final unreadCount = ref.watch(unreadCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sesiones Activas'),
        actions: [
          const ThemeToggleButton(),
          // Botón de notificaciones con badge
          IconButton(
            icon: Badge(
              label: Text('$unreadCount'),
              isLabelVisible: unreadCount > 0,
              child: const Icon(Icons.notifications),
            ),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => DraggableScrollableSheet(
                  initialChildSize: 0.7,
                  minChildSize: 0.5,
                  maxChildSize: 0.95,
                  expand: false,
                  builder: (context, scrollController) => Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Notificaciones',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      Expanded(
                        child: NotificationsPanel(),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(activeSessionsProvider.notifier).refresh();
            },
          ),
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
      body: Column(
        children: [
          // Panel de ubicación GPS en tiempo real
          _buildGPSLocationPanel(),
          // Sesiones activas con distancias
          Expanded(child: _buildActiveSessionsWithDistance()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/scan-qr');
        },
        icon: const Icon(Icons.qr_code_scanner),
        label: const Text('Escanear QR'),
        heroTag: 'scanQrBtn',
      ),
    );
  }

  Widget _buildGPSLocationPanel() {
    final activeSessionsState = ref.watch(activeSessionsProvider);
    
    if (activeSessionsState.lastPosition == null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orange[50],
          border: Border(
            bottom: BorderSide(color: Colors.orange[200]!, width: 1),
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.orange[700]!),
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Obteniendo ubicación GPS...',
                style: TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[700]!, Colors.blue[500]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.my_location, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Tu Ubicación Actual',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.gps_fixed,
                      size: 12,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '±${activeSessionsState.lastPosition!.accuracy.toStringAsFixed(0)}m',
                      style: const TextStyle(fontSize: 11, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lat: ${activeSessionsState.lastPosition!.latitude.toStringAsFixed(6)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.9),
                        fontFamily: 'monospace',
                      ),
                    ),
                    Text(
                      'Lng: ${activeSessionsState.lastPosition!.longitude.toStringAsFixed(6)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.9),
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActiveSessionsWithDistance() {
    final activeSessionsState = ref.watch(activeSessionsProvider);

    print('🎨 DEBUG - _buildActiveSessionsWithDistance rebuild');
    print('   isLoading: ${activeSessionsState.isLoading}');
    print('   error: ${activeSessionsState.error}');
    print('   sessions.length: ${activeSessionsState.sessions.length}');

    if (activeSessionsState.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Buscando sesiones cercanas...'),
          ],
        ),
      );
    }

    if (activeSessionsState.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                activeSessionsState.error!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
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
        ),
      );
    }

    if (activeSessionsState.sessions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              const Text(
                'No hay sesiones activas',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'No hay sesiones disponibles en este momento',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(activeSessionsProvider.notifier).refresh();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: activeSessionsState.sessions.length,
        itemBuilder: (context, index) {
          final session = activeSessionsState.sessions[index];
          return _buildSessionDistanceCard(session);
        },
      ),
    );
  }

  Widget _buildSessionDistanceCard(SessionWithDistanceModel session) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con emoji y nombre
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
                        'Docente: ${session.teacherName}',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            
            // Información de zona
            Row(
              children: [
                Icon(Icons.location_on, size: 18, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Zona: ${session.zoneName}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Detalles técnicos
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Centro de la zona:',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Lat: ${session.zoneLatitude.toStringAsFixed(6)}',
                    style: TextStyle(fontSize: 10, fontFamily: 'monospace', color: Colors.grey[600]),
                  ),
                  Text(
                    'Lng: ${session.zoneLongitude.toStringAsFixed(6)}',
                    style: TextStyle(fontSize: 10, fontFamily: 'monospace', color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Radio de zona: ${session.radiusMeters}m',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blue[700]),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Indicador de distancia
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: session.withinZone ? Colors.green[50] : Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: session.withinZone ? Colors.green : Colors.orange,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.social_distance,
                    size: 24,
                    color: session.withinZone ? Colors.green[700] : Colors.orange[700],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Distancia: ${session.getDistanceText()}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: session.withinZone ? Colors.green[700] : Colors.orange[700],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          session.getProximityMessage(),
                          style: TextStyle(
                            fontSize: 13,
                            color: session.withinZone ? Colors.green[600] : Colors.orange[600],
                          ),
                        ),
                        Text(
                          'Valor exacto: ${session.distanceInMeters.toStringAsFixed(2)}m',
                          style: TextStyle(fontSize: 10, fontFamily: 'monospace', color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    session.withinZone ? Icons.check_circle : Icons.cancel,
                    color: session.withinZone ? Colors.green : Colors.red,
                    size: 32,
                  ),
                ],
              ),
            ),
            
            // Botón de acción
            if (session.canScanQR())
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/scan-qr');
                    },
                    icon: const Icon(Icons.qr_code_scanner),
                    label: const Text('Escanear QR'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(SessionState state) {
    if (state.isLoading) {
      return const LoadingWidget(message: 'Cargando sesiones...');
    }

    if (state.error != null) {
      return app_error.ErrorWidget(
        message: state.error!,
        onRetry: () {
          ref.read(sessionProvider.notifier).loadActiveSessions();
        },
      );
    }

    if (state.activeSessions.isEmpty) {
      return const EmptyStateWidget(
        message: 'No hay sesiones activas',
        subtitle: 'No hay sesiones disponibles en este momento',
        icon: Icons.event_busy,
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(sessionProvider.notifier).loadActiveSessions();
      },
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 80),
        itemCount: state.activeSessions.length,
        itemBuilder: (context, index) {
          final session = state.activeSessions[index];
          return SessionCard(
            session: session,
            onTap: () {
              // Mostrar información de la sesión al estudiante
              _showSessionInfoDialog(context, session);
            },
          );
        },
      ),
    );
  }

  void _showSessionInfoDialog(BuildContext context, AttendanceSession session) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info_outline, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            const Expanded(child: Text('Información de la Sesión')),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow('Zona', session.zoneName, Icons.location_on),
              const SizedBox(height: 12),
              _buildInfoRow('Docente', session.teacherName, Icons.person),
              const SizedBox(height: 12),
              _buildInfoRow(
                'Coordenadas',
                '${session.zoneLatitude.toStringAsFixed(6)}, ${session.zoneLongitude.toStringAsFixed(6)}',
                Icons.place,
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                'Radio',
                '${session.radiusMeters.toStringAsFixed(0)} metros',
                Icons.radio_button_unchecked,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.qr_code_scanner, color: Colors.blue.shade700),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Para registrar tu asistencia, escanea el código QR que mostrará el docente',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/scan-qr');
            },
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('Escanear QR'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _registerDeviceIfNeeded() async {
    try {
      print('🔵 [StudentHome] Verificando registro de dispositivo...');
      await ref.read(deviceProvider.notifier).loadDeviceInfo();
      
      final deviceState = ref.read(deviceProvider);
      
      if (deviceState.isRegistered && deviceState.deviceId != null) {
        print('✅ [StudentHome] Dispositivo ya registrado: ${deviceState.deviceId}');
        return;
      }
      
      print('🔵 [StudentHome] Registrando dispositivo...');
      final messagingService = ref.read(firebaseMessagingServiceProvider);
      
      final deviceIdentifier = await messagingService.getDeviceIdentifier();
      final platform = messagingService.getPlatform();
      final fcmToken = await messagingService.getToken();
      
      if (fcmToken == null) {
        print('⚠️ [StudentHome] No se pudo obtener token FCM');
        return;
      }
      
      await ref.read(deviceProvider.notifier).registerDevice(
        deviceIdentifier: deviceIdentifier,
        platform: platform,
        fcmToken: fcmToken,
      );
      
      await ref.read(deviceProvider.notifier).loadDeviceInfo();
      
      final updatedState = ref.read(deviceProvider);
      print('✅ [StudentHome] Dispositivo registrado: ${updatedState.deviceId}');
      
      messagingService.onTokenRefresh((newToken) {
        ref.read(deviceProvider.notifier).updateFcmToken(newToken);
      });
    } catch (e, stackTrace) {
      print('❌ [StudentHome] Error registrando dispositivo: $e');
      print('❌ [StudentHome] StackTrace: $stackTrace');
    }
  }
}
