import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../providers/geofence_provider.dart';
import '../../widgets/atoms/custom_button.dart';
import '../../widgets/atoms/loading_widget.dart';
import '../../widgets/atoms/empty_state_widget.dart';

// Provider para obtener ubicación actual
final locationProvider = FutureProvider<Position>((ref) async {
  try {
    // Verificar si el servicio está habilitado
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Intentar abrir la configuración de ubicación
      await Geolocator.openLocationSettings();
      // Volver a verificar
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Debes habilitar el GPS en tu dispositivo');
      }
    }

    // Verificar permisos
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Debes permitir el acceso a la ubicación');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Permisos denegados permanentemente. Ve a Ajustes para habilitarlos');
    }

    // Obtener ubicación
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 10),
    );
  } catch (e) {
    throw Exception(e.toString());
  }
});

class GeofenceZonesPage extends ConsumerStatefulWidget {
  const GeofenceZonesPage({Key? key}) : super(key: key);

  @override
  ConsumerState<GeofenceZonesPage> createState() => _GeofenceZonesPageState();
}

class _GeofenceZonesPageState extends ConsumerState<GeofenceZonesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(geofenceProvider.notifier).loadZones();
    });
  }

  Future<void> _getCurrentLocation(
    TextEditingController latController,
    TextEditingController lonController,
  ) async {
    try {
      // Mostrar indicador de carga
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                SizedBox(width: 16),
                Text('Obteniendo ubicación...'),
              ],
            ),
            duration: Duration(seconds: 10),
          ),
        );
      }

      // Refrescar el provider para obtener nueva ubicación
      ref.invalidate(locationProvider);
      final position = await ref.read(locationProvider.future);
      
      latController.text = position.latitude.toStringAsFixed(7);
      lonController.text = position.longitude.toStringAsFixed(7);
      
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Ubicación obtenida correctamente'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        final errorMessage = e.toString().replaceAll('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Configurar',
              textColor: Colors.white,
              onPressed: () {
                Geolocator.openLocationSettings();
              },
            ),
          ),
        );
      }
    }
  }

  void _showCreateZoneDialog() {
    final nameController = TextEditingController();
    final latController = TextEditingController();
    final lonController = TextEditingController();
    final radiusController = TextEditingController(text: '150');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Crear Zona de Geofencing'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la zona',
                  hintText: 'Ej: Edificio A - Campus Central',
                ),
              ),
              const SizedBox(height: 16),
              
              // Botón para usar ubicación actual
              OutlinedButton.icon(
                onPressed: () => _getCurrentLocation(latController, lonController),
                icon: const Icon(Icons.my_location),
                label: const Text('Usar mi ubicación actual'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              
              const SizedBox(height: 16),
              TextField(
                controller: latController,
                decoration: const InputDecoration(
                  labelText: 'Latitud',
                  hintText: 'Ej: -0.2534678',
                  prefixIcon: Icon(Icons.location_on),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: lonController,
                decoration: const InputDecoration(
                  labelText: 'Longitud',
                  hintText: 'Ej: -78.5234123',
                  prefixIcon: Icon(Icons.location_on),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: radiusController,
                decoration: const InputDecoration(
                  labelText: 'Radio (metros)',
                  hintText: '150',
                  helperText: 'Distancia máxima permitida desde el centro.\nEj: 100m = dentro de edificio, 500m = campus',
                  helperMaxLines: 2,
                ),
                keyboardType: TextInputType.number,
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
            onPressed: () async {
              final name = nameController.text.trim();
              final lat = double.tryParse(latController.text.trim());
              final lon = double.tryParse(lonController.text.trim());
              final radius = double.tryParse(radiusController.text.trim());

              if (name.isEmpty || lat == null || lon == null || radius == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Por favor completa todos los campos correctamente'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              Navigator.pop(context);

              await ref.read(geofenceProvider.notifier).createZone(
                    name: name,
                    latitude: lat,
                    longitude: lon,
                    radiusMeters: radius,
                  );

              if (mounted) {
                final state = ref.read(geofenceProvider);
                if (state.error != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.error!),
                      backgroundColor: Colors.red,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Zona creada exitosamente'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final geofenceState = ref.watch(geofenceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Zonas de Geofencing'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(geofenceProvider.notifier).loadZones();
            },
          ),
        ],
      ),
      body: geofenceState.isLoading
          ? const Center(child: LoadingWidget())
          : geofenceState.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        geofenceState.error!,
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          ref.read(geofenceProvider.notifier).loadZones();
                        },
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : geofenceState.zones.isEmpty
                  ? EmptyStateWidget(
                      icon: Icons.location_off,
                      message: 'No hay zonas creadas',
                      action: ElevatedButton.icon(
                        onPressed: _showCreateZoneDialog,
                        icon: const Icon(Icons.add_location),
                        label: const Text('Crear Primera Zona'),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: geofenceState.zones.length,
                      itemBuilder: (context, index) {
                        final zone = geofenceState.zones[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue,
                              child: const Icon(Icons.location_on, color: Colors.white),
                            ),
                            title: Text(
                              zone.name,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text('Lat: ${zone.latitude.toStringAsFixed(6)}'),
                                Text('Lon: ${zone.longitude.toStringAsFixed(6)}'),
                                Text('Radio: ${zone.radiusMeters}m'),
                              ],
                            ),
                            isThreeLine: true,
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              // Aquí se podría mostrar más detalles o un mapa
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Zona: ${zone.name}'),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateZoneDialog,
        icon: const Icon(Icons.add_location),
        label: const Text('Nueva Zona'),
      ),
    );
  }
}
