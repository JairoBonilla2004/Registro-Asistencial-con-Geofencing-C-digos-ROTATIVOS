import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';
import '../../../domain/entities/report.dart';
import '../../providers/report_provider.dart';
import '../student/statistics_page.dart';
import '../teacher/session_reports_page.dart';

// Plugin de notificaciones global
final FlutterLocalNotificationsPlugin _notificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Handler global para notificaciones
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) {
  print('📂 [Background] Notification tapped: ${response.payload}');
  if (response.payload != null && response.payload!.isNotEmpty) {
    _handleNotificationTap(response.payload!);
  }
}

// Función para manejar el tap en la notificación
void _handleNotificationTap(String filePath) async {
  print('📂 Attempting to open file: $filePath');
  
  // Verificar que el archivo existe
  final file = File(filePath);
  if (!await file.exists()) {
    print('❌ File does not exist: $filePath');
    return;
  }
  
  print('✅ File exists, opening...');
  
  // Abrir el archivo
  final result = await OpenFile.open(filePath);
  print('📂 Open file result: ${result.type} - ${result.message}');
}

class ReportsPage extends ConsumerStatefulWidget {
  const ReportsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends ConsumerState<ReportsPage> {
  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    Future.microtask(() {
      ref.read(reportNotifierProvider.notifier).loadReports();
    });
  }

  Future<void> _initializeNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    
    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print('📂 [Foreground] Notification tapped: ${response.payload}');
        print('📂 [Foreground] Action ID: ${response.actionId}');
        if (response.payload != null && response.payload!.isNotEmpty) {
          _handleNotificationTap(response.payload!);
        }
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    // Crear el canal de notificación en Android 8.0+
    const androidChannel = AndroidNotificationChannel(
      'download_channel',
      'Descargas',
      description: 'Notificaciones de archivos descargados',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
    
    print('✅ Notifications initialized and channel created');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reportNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(reportNotifierProvider.notifier).loadReports();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(reportNotifierProvider.notifier).loadReports(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Header
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.bar_chart, size: 48, color: Colors.blue.shade700),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Reportes de Asistencia',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Genera reportes personalizados en formato PDF',
                            style: TextStyle(
                              color: Colors.blue.shade600,
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

          // Reporte Personal (para estudiantes)
          _buildReportCard(
            context,
            title: 'Reportes por Sesión',
            description: 'Genera reportes individuales de cada sesión',
            icon: Icons.event_note,
            color: Colors.green,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SessionReportsPage(),
                ),
              );
            },
          ),

          const SizedBox(height: 12),

          // Reporte de Estadísticas
          _buildReportCard(
            context,
            title: 'Estadísticas Generales',
            description: 'Análisis de asistencia por período',
            icon: Icons.analytics,
            color: Colors.purple,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StatisticsPage(),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // Mis reportes generados
          const Text(
            'Reportes Generados',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          if (state.isLoading && state.reports.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              ),
            )
          else if (state.error != null && state.reports.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.error!,
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else if (state.reports.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.folder_open,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No hay reportes generados',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Los reportes que generes aparecerán aquí',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            ...state.reports.map((report) => _buildReportItem(report)),
        ],
      ),
      ),
    );
  }

  Widget _buildReportItem(Report report) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (report.status) {
      case 'COMPLETED':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'Completado';
        break;
      case 'GENERATING':
      case 'PROCESSING':
        statusColor = Colors.orange;
        statusIcon = Icons.hourglass_empty;
        statusText = 'Generando...';
        break;
      case 'FAILED':
        statusColor = Colors.red;
        statusIcon = Icons.error;
        statusText = 'Fallido';
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.info;
        statusText = report.status;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(statusIcon, color: statusColor, size: 32),
        title: Text(
          report.reportType == 'STUDENT_PERSONAL'
              ? 'Reporte Personal'
              : 'Reporte de Sesión',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Estado: $statusText'),
            Text(
              'Solicitado: ${DateFormat('dd/MM/yyyy HH:mm').format(report.requestedAt)}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: report.status == 'COMPLETED'
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.download),
                    onPressed: () => _showDownloadDialog(report.id),
                    color: Colors.blue,
                    tooltip: 'Descargar',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _showDeleteDialog(report),
                    color: Colors.red,
                    tooltip: 'Eliminar',
                  ),
                ],
              )
            : null,
      ),
    );
  }

  Widget _buildReportCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  void _showPersonalReportDialog(BuildContext context) {
    DateTime? startDate;
    DateTime? endDate;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Reporte Personal'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Selecciona el período para tu reporte:'),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Fecha Inicio'),
                  subtitle: Text(
                    startDate != null
                        ? DateFormat('dd/MM/yyyy').format(startDate!)
                        : 'Seleccionar fecha',
                  ),
                  leading: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().subtract(const Duration(days: 30)),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() => startDate = date);
                    }
                  },
                ),
                ListTile(
                  title: const Text('Fecha Fin'),
                  subtitle: Text(
                    endDate != null
                        ? DateFormat('dd/MM/yyyy').format(endDate!)
                        : 'Seleccionar fecha',
                  ),
                  leading: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: startDate ?? DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() => endDate = date);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: ref.watch(reportNotifierProvider).isGenerating
                  ? null
                  : () async {
                      if (startDate == null || endDate == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Debes seleccionar ambas fechas'),
                          ),
                        );
                        return;
                      }

                      if (startDate!.isAfter(endDate!)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('La fecha de inicio debe ser anterior a la fecha final'),
                          ),
                        );
                        return;
                      }

                      final success = await ref
                          .read(reportNotifierProvider.notifier)
                          .generateReport(
                            reportType: 'STUDENT_PERSONAL',
                            startDate: startDate,
                            endDate: endDate,
                          );

                      if (!context.mounted) return;

                      Navigator.pop(context);

                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Reporte generado exitosamente'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                ref.read(reportNotifierProvider).error ??
                                    'Error al generar el reporte'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
              child: ref.watch(reportNotifierProvider).isGenerating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Generar'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSessionReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reporte de Sesión'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Selecciona la sesión para generar el reporte:'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Funcionalidad disponible desde\nla página de "Mis Sesiones"',
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Simplemente cerrar el diálogo - el usuario puede navegar manualmente
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Navega a "Mis Sesiones" desde el menú principal'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadReport(String reportId) async {
    try {
      // SOLUCIÓN PROFESIONAL: Solicitar permisos según versión de Android
      if (Platform.isAndroid) {
        // Android 10+ (API 29+) no necesita permisos para acceder a Downloads
        // Android 8-9 (API 26-28) necesita WRITE_EXTERNAL_STORAGE
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        final sdkInt = androidInfo.version.sdkInt;
        
        if (sdkInt < 29) {
          // Android 8-9: Solicitar permiso de almacenamiento
          final status = await Permission.storage.request();
          if (!status.isGranted) {
            _showErrorDialog(
              'Necesitas conceder permiso de almacenamiento para descargar el reporte.'
            );
            return;
          }
        }
      }

      // Mostrar diálogo de progreso
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
                  Text('Descargando reporte...'),
                ],
              ),
            ),
          ),
        ),
      );

      // Descargar el reporte
      final useCase = ref.read(downloadReportUseCaseProvider);
      final result = await useCase(reportId);

      result.fold(
        (failure) {
          Navigator.pop(context);
          _showErrorDialog(failure.message);
        },
        (bytes) async {
          // Obtener directorio de descargas
          Directory? directory;
          String fileName;
          
          if (Platform.isAndroid) {
            final androidInfo = await DeviceInfoPlugin().androidInfo;
            final sdkInt = androidInfo.version.sdkInt;
            
            if (sdkInt >= 29) {
              // Android 10+ (API 29+): Usar directorio Downloads público
              directory = Directory('/storage/emulated/0/Download');
            } else {
              // Android 8-9: Usar directorio Downloads público con permisos
              directory = Directory('/storage/emulated/0/Download');
              if (!await directory.exists()) {
                // Fallback a directorio de la app
                directory = await getExternalStorageDirectory();
              }
            }
          } else {
            // Para iOS, usar directorio de documentos de la app
            directory = await getApplicationDocumentsDirectory();
          }

          // Crear nombre de archivo con timestamp
          final timestamp = DateTime.now();
          final dateStr = '${timestamp.year}${timestamp.month.toString().padLeft(2, '0')}${timestamp.day.toString().padLeft(2, '0')}_${timestamp.hour.toString().padLeft(2, '0')}${timestamp.minute.toString().padLeft(2, '0')}${timestamp.second.toString().padLeft(2, '0')}';
          fileName = 'reporte_$dateStr.pdf';
          final filePath = '${directory?.path ?? '/sdcard/Download'}/$fileName';
          final file = File(filePath);

          try {
            // Guardar el archivo
            await file.writeAsBytes(bytes);
            print('✅ File saved successfully: $filePath');
            print('✅ File exists after save: ${await file.exists()}');
            print('✅ File size: ${await file.length()} bytes');

            Navigator.pop(context);

            // Mostrar notificación en la barra de notificaciones
            await _showDownloadNotification(fileName, filePath);
            print('✅ Notification shown');

            // Mostrar diálogo de éxito
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 8),
                    Flexible(child: Text('Descarga Completa')),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('El reporte se ha descargado exitosamente.'),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.folder, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  Platform.isAndroid && (directory?.path.contains('Download') ?? false)
                                      ? 'Descargas' 
                                      : 'Documentos de la app',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            fileName,
                            style: const TextStyle(fontSize: 11),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cerrar'),
                  ),
                ],
              ),
            );

            // Refrescar la lista de reportes
            ref.read(reportNotifierProvider.notifier).loadReports();
          } catch (e) {
            Navigator.pop(context);
            _showErrorDialog('No se pudo guardar el archivo. Intenta nuevamente.');
          }
        },
      );
    } catch (e) {
      Navigator.pop(context);
      _showErrorDialog('Error inesperado: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade600),
            const SizedBox(width: 8),
            const Text('Error'),
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

  Future<void> _showDownloadNotification(String fileName, String filePath) async {
    print('📲 Showing notification for file: $filePath');
    
    const androidDetails = AndroidNotificationDetails(
      'download_channel',
      'Descargas',
      channelDescription: 'Notificaciones de archivos descargados',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      styleInformation: BigTextStyleInformation('Toca para abrir el archivo'),
      playSound: true,
      enableVibration: true,
      // Hacer que la notificación sea clickeable
      autoCancel: true,
      // Acción directa en la notificación
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          'open_file',
          'Abrir',
          showsUserInterface: true,
        ),
      ],
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    final notificationId = DateTime.now().millisecondsSinceEpoch % 100000;
    
    await _notificationsPlugin.show(
      notificationId,
      '✅ Descarga completa',
      'Reporte guardado: $fileName',
      notificationDetails,
      payload: filePath, // Pasar la ruta del archivo para abrirlo
    );
    
    print('📲 Notification shown with ID: $notificationId and payload: $filePath');
  }

  void _showDownloadDialog(String reportId) {
    _downloadReport(reportId);
  }

  void _showDeleteDialog(Report report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('Eliminar Reporte'),
          ],
        ),
        content: Text(
          '¿Estás seguro de que deseas eliminar este reporte?\n\n'
          'Esta acción no se puede deshacer y el archivo PDF será eliminado permanentemente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteReport(report.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteReport(String reportId) async {
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
                Text('Eliminando reporte...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final useCase = ref.read(deleteReportUseCaseProvider);
      final result = await useCase(reportId);

      result.fold(
        (failure) {
          Navigator.pop(context); // Cerrar diálogo de carga
          _showErrorDialog(failure.message);
        },
        (_) {
          Navigator.pop(context); // Cerrar diálogo de carga
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Reporte eliminado exitosamente'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          // Recargar lista
          ref.read(reportNotifierProvider.notifier).loadReports();
        },
      );
    } catch (e) {
      Navigator.pop(context); // Cerrar diálogo de carga
      _showErrorDialog('Error inesperado: $e');
    }
  }
}
