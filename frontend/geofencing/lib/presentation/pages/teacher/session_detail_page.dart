import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../providers/session_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../widgets/atoms/loading_widget.dart';

class SessionDetailPage extends ConsumerStatefulWidget {
  final String? sessionId;

  const SessionDetailPage({Key? key, this.sessionId}) : super(key: key);

  @override
  ConsumerState<SessionDetailPage> createState() => _SessionDetailPageState();
}

class _SessionDetailPageState extends ConsumerState<SessionDetailPage> {
  Timer? _qrTimer;
  Timer? _attendanceTimer;
  Timer? _countdownTimer;
  bool _isGeneratingQR = false;
  int _secondsRemaining = 0;
  int _qrRotationInterval = 30; // Valor por defecto

  @override
  void initState() {
    super.initState();
    _initializeSession();
  }

  void _initializeSession() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sessionState = ref.read(sessionProvider);
      
      if (sessionState.currentSession != null) {
        // Generar primer QR
        _generateQR();
        
        // Cargar asistencias
        _loadAttendances();
        
        // Configurar timers
        _setupTimers();
      }
    });
  }

  void _setupTimers() {
    final session = ref.read(sessionProvider).currentSession;
    
    // Solo configurar timers si la sesión está activa
    if (session == null || !session.active) {
      return;
    }
    
    // Obtener intervalo de rotación (viene en minutos desde el backend, convertir a segundos)
    // TODO: El backend debería enviar esto en segundos también
    _qrRotationInterval = 30; // Por ahora 30 segundos por defecto
    _secondsRemaining = _qrRotationInterval;
    
    // Timer para regenerar QR según el intervalo configurado
    _qrTimer = Timer.periodic(Duration(seconds: _qrRotationInterval), (_) {
      _generateQR();
      _secondsRemaining = _qrRotationInterval; // Resetear contador
    });
    
    // Cronómetro de cuenta regresiva (actualiza cada segundo)
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _secondsRemaining--;
          if (_secondsRemaining <= 0) {
            _secondsRemaining = _qrRotationInterval;
          }
        });
      }
    });

    // Timer para recargar asistencias cada 10 segundos
    _attendanceTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _loadAttendances();
    });
  }

  Future<void> _generateQR() async {
    if (_isGeneratingQR) return;

    final session = ref.read(sessionProvider).currentSession;
    
    // No generar QR si la sesión no está activa
    if (session == null || !session.active) {
      return;
    }

    setState(() {
      _isGeneratingQR = true;
    });

    await ref.read(sessionProvider.notifier).generateQR(session.sessionId);

    setState(() {
      _isGeneratingQR = false;
    });
  }

  Future<void> _loadAttendances() async {
    final session = ref.read(sessionProvider).currentSession;
    if (session != null) {
      await ref.read(attendanceProvider.notifier).loadSessionAttendances(session.sessionId);
    }
  }

  Future<void> _endSession() async {
    final session = ref.read(sessionProvider).currentSession;
    if (session == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Finalizar Sesión'),
        content: const Text(
          '¿Estás seguro de que quieres finalizar esta sesión?\n\n'
          'Los estudiantes ya no podrán registrar su asistencia.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Finalizar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(sessionProvider.notifier).endSession(session.sessionId);

      if (!mounted) return;

      final sessionState = ref.read(sessionProvider);
      if (sessionState.error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sesión finalizada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(sessionState.error!),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _qrTimer?.cancel();
    _attendanceTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(sessionProvider);
    final attendanceState = ref.watch(attendanceProvider);
    final session = sessionState.currentSession;
    final qrToken = sessionState.currentQR;

    if (session == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalle de Sesión')),
        body: const Center(
          child: Text('No hay sesión seleccionada'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sesión Activa'),
        actions: [
          if (session.active)
            IconButton(
              icon: const Icon(Icons.stop_circle, color: Colors.red),
              onPressed: _endSession,
              tooltip: 'Finalizar Sesión',
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadAttendances,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Información de la sesión
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.event,
                              color: Colors.green.shade700,
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
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatDateTime(session.startTime),
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      _buildInfoRow(
                        Icons.location_on,
                        'Zona',
                        session.zoneName,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Código QR (solo si la sesión está activa)
              if (session.active)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.qr_code_2, size: 24),
                            SizedBox(width: 8),
                            Text(
                              'Código QR para Asistencia',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        if (_isGeneratingQR || qrToken == null)
                          Container(
                            height: 280,
                            alignment: Alignment.center,
                            child: const LoadingWidget(
                              message: 'Generando código QR...',
                            ),
                          )
                        else
                          Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey.shade300, width: 2),
                                ),
                                child: QrImageView(
                                  data: qrToken.token,
                                  version: QrVersions.auto,
                                  size: 250,
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Countdown timer display
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: _secondsRemaining <= 5
                                        ? [Colors.red.shade400, Colors.red.shade600]
                                        : _secondsRemaining <= 10
                                            ? [Colors.orange.shade400, Colors.orange.shade600]
                                            : [Colors.green.shade400, Colors.green.shade600],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(25),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.timer,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        'Próximo QR en: $_secondsRemaining seg',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Expira: ${DateFormat('HH:mm:ss').format(qrToken.expiresAt)}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              OutlinedButton.icon(
                                onPressed: _generateQR,
                                icon: const Icon(Icons.refresh, size: 18),
                                label: const Text('Regenerar QR'),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                )
              else
                // Mostrar mensaje cuando la sesión está finalizada
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Icon(
                          Icons.event_busy,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Sesión Finalizada',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'El código QR ya no está disponible para esta sesión',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // Estadísticas
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Asistencias Registradas',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatCard(
                            'Total',
                            '${attendanceState.sessionAttendances.length}',
                            Icons.people,
                            Colors.blue,
                          ),
                          _buildStatCard(
                            'En Zona',
                            '${attendanceState.sessionAttendances.where((a) => a.withinGeofence).length}',
                            Icons.location_on,
                            Colors.green,
                          ),
                          _buildStatCard(
                            'Fuera',
                            '${attendanceState.sessionAttendances.where((a) => !a.withinGeofence).length}',
                            Icons.location_off,
                            Colors.orange,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Lista de asistencias
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Últimas Asistencias',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (attendanceState.isLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (attendanceState.sessionAttendances.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.people_outline,
                                  size: 64,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Aún no hay asistencias registradas',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: attendanceState.sessionAttendances.length > 10
                              ? 10
                              : attendanceState.sessionAttendances.length,
                          separatorBuilder: (_, __) => const Divider(),
                          itemBuilder: (context, index) {
                            final attendance = attendanceState.sessionAttendances[index];
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                backgroundColor: attendance.withinGeofence
                                    ? Colors.green.shade100
                                    : Colors.orange.shade100,
                                child: Icon(
                                  attendance.withinGeofence
                                      ? Icons.check_circle
                                      : Icons.warning,
                                  color: attendance.withinGeofence
                                      ? Colors.green
                                      : Colors.orange,
                                ),
                              ),
                              title: Text(
                                attendance.studentName ?? 'Estudiante',
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                              subtitle: Text(
                                DateFormat('HH:mm:ss').format(attendance.serverTime),
                              ),
                              trailing: Text(
                                attendance.withinGeofence ? 'En zona' : 'Fuera',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: attendance.withinGeofence
                                      ? Colors.green
                                      : Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          },
                        ),
                      if (attendanceState.sessionAttendances.length > 10)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Center(
                            child: Text(
                              'Mostrando 10 de ${attendanceState.sessionAttendances.length}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      floatingActionButton: session.active
          ? FloatingActionButton.extended(
              onPressed: _endSession,
              backgroundColor: Colors.red,
              icon: const Icon(Icons.stop),
              label: const Text('Finalizar Sesión'),
            )
          : null,
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
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
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 32),
        ),
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
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
