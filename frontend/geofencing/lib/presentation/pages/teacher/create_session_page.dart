import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/geofence_provider.dart';
import '../../providers/session_provider.dart';
import '../../widgets/atoms/custom_button.dart';
import '../../widgets/atoms/loading_widget.dart';

class CreateSessionPage extends ConsumerStatefulWidget {
  const CreateSessionPage({Key? key}) : super(key: key);

  @override
  ConsumerState<CreateSessionPage> createState() => _CreateSessionPageState();
}

class _CreateSessionPageState extends ConsumerState<CreateSessionPage> {
  final TextEditingController _nameController = TextEditingController();
  String? selectedZoneId;
  int qrRotationSeconds = 30;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(geofenceProvider.notifier).loadZones();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _createSession() async {
    final name = _nameController.text.trim();
    
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa un nombre para la sesión'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    if (selectedZoneId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona una zona de geofencing'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    await ref.read(sessionProvider.notifier).createSession(
          name: name,
          zoneId: selectedZoneId!,
          qrRotationMinutes: (qrRotationSeconds / 60).ceil(), // Convertir segundos a minutos
        );

    if (!mounted) return;

    final sessionState = ref.read(sessionProvider);

    if (sessionState.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(sessionState.error!),
          backgroundColor: Colors.red,
        ),
      );
    } else if (sessionState.currentSession != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Sesión creada exitosamente'),
          backgroundColor: Colors.green,
        ),
      );

      // Navegar a la página de detalle de sesión
      Navigator.pushReplacementNamed(
        context,
        '/session-detail',
        arguments: sessionState.currentSession!.sessionId,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final geofenceState = ref.watch(geofenceProvider);
    final sessionState = ref.watch(sessionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Nueva Sesión'),
      ),
      body: geofenceState.isLoading
          ? const Center(child: LoadingWidget(message: 'Cargando zonas...'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Información
                  Card(
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.blue.shade700),
                              const SizedBox(width: 8),
                              Text(
                                'Información',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Al crear una sesión, se iniciará el registro de asistencia. '
                            'Los estudiantes podrán escanear el código QR que se generará automáticamente.',
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Nombre de sesión
                  const Text(
                    'Nombre de la Sesión',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      hintText: 'Ej: Clase de Matemáticas - Grupo A',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.edit),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Selección de zona
                  const Text(
                    'Zona de Geofencing',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Selecciona el lugar donde se llevará a cabo la clase',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),

                  if (geofenceState.zones.isEmpty)
                    Card(
                      color: Colors.orange.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Icon(Icons.warning_amber, size: 48, color: Colors.orange.shade700),
                            const SizedBox(height: 8),
                            const Text(
                              'No hay zonas de geofencing creadas',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Necesitas crear al menos una zona antes de iniciar una sesión',
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pushNamed(context, '/geofence-zones');
                              },
                              icon: const Icon(Icons.add_location),
                              label: const Text('Ir a Zonas'),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: geofenceState.zones.map((zone) {
                          final isSelected = selectedZoneId == zone.id;
                          return RadioListTile<String>(
                            value: zone.id,
                            groupValue: selectedZoneId,
                            onChanged: (value) {
                              setState(() {
                                selectedZoneId = value;
                              });
                            },
                            title: Text(
                              zone.name,
                              style: TextStyle(
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            subtitle: Text(
                              'Radio: ${zone.radiusMeters}m',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            ),
                            secondary: CircleAvatar(
                              backgroundColor: isSelected ? Colors.blue : Colors.grey.shade300,
                              child: const Icon(Icons.location_on, color: Colors.white),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                  const SizedBox(height: 32),

                  // Configuración de QR
                  const Text(
                    'Configuración de Código QR',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Define cada cuántos segundos se regenerará el código QR (máximo 2 minutos)',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Rotación de QR:',
                                style: TextStyle(fontSize: 16),
                              ),
                              Text(
                                '$qrRotationSeconds segundos',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                          Slider(
                            value: qrRotationSeconds.toDouble(),
                            min: 15,
                            max: 120,
                            divisions: 7, // (120-15)/15 = 7 divisiones (15, 30, 45, 60, 75, 90, 105, 120)
                            label: '$qrRotationSeconds seg',
                            onChanged: (value) {
                              setState(() {
                                // Redondear a múltiplos de 15
                                qrRotationSeconds = ((value / 15).round() * 15).toInt();
                              });
                            },
                          ),
                          Text(
                            'El código QR cambiará automáticamente cada $qrRotationSeconds segundos por seguridad',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Botón crear
                  if (sessionState.isLoading)
                    const Center(child: LoadingWidget(message: 'Creando sesión...'))
                  else
                    CustomButton(
                      text: 'Iniciar Sesión de Asistencia',
                      onPressed: geofenceState.zones.isEmpty ? null : _createSession,
                      icon: Icons.play_arrow,
                      backgroundColor: Colors.green,
                    ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }
}
