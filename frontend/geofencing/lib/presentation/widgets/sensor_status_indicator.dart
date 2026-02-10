import 'package:flutter/material.dart';

/// Widget para mostrar el estado de los sensores durante la captura
class SensorStatusIndicator extends StatelessWidget {
  final bool isCapturing;
  final int compassReadings;
  final int proximityReadings;
  final bool hasMagnetometer;
  final bool hasProximity;
  final int? remainingSeconds;

  const SensorStatusIndicator({
    Key? key,
    required this.isCapturing,
    required this.compassReadings,
    required this.proximityReadings,
    required this.hasMagnetometer,
    required this.hasProximity,
    this.remainingSeconds,
  }) : super(key: key);

  String _getCompassStatus() {
    if (!hasMagnetometer) return 'Sensor no disponible';
    if (compassReadings == 0) return 'Esperando...';
    if (compassReadings >= 2) return '✓ Moviendo dispositivo';
    return 'Detectando movimiento...';
  }

  String _getProximityStatus() {
    if (!hasProximity) return 'Sensor no disponible';
    if (proximityReadings == 0) return 'Esperando...';
    if (proximityReadings >= 2) return '✓ Dispositivo en mano';
    return 'Detectando proximidad...';
  }

  @override
  Widget build(BuildContext context) {
    if (!isCapturing && compassReadings == 0 && proximityReadings == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCapturing ? Colors.green : Colors.grey,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCapturing ? Icons.sensors : Icons.check_circle,
                color: isCapturing ? Colors.green : Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isCapturing 
                      ? (remainingSeconds != null 
                          ? 'Capturando... ${remainingSeconds}s' 
                          : 'Capturando sensores...') 
                      : 'Sensores capturados ✓',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildSensorRow(
            icon: Icons.explore,
            status: _getCompassStatus(),
            available: hasMagnetometer,
            readings: compassReadings,
            isActive: isCapturing,
          ),
          const SizedBox(height: 4),
          _buildSensorRow(
            icon: Icons.sensors,
            status: _getProximityStatus(),
            available: hasProximity,
            readings: proximityReadings,
            isActive: isCapturing,
          ),
        ],
      ),
    );
  }

  Widget _buildSensorRow({
    required IconData icon,
    required String status,
    required bool available,
    required int readings,
    required bool isActive,
  }) {
    final Color statusColor = !available
        ? Colors.grey
        : readings >= 2
            ? Colors.green
            : readings > 0
                ? Colors.orange
                : isActive
                    ? Colors.orange
                    : Colors.grey;

    return Row(
      children: [
        Icon(icon, color: statusColor, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            status,
            style: TextStyle(
              color: available ? Colors.white : Colors.grey,
              fontSize: 12,
            ),
          ),
        ),
        if (available && readings > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$readings',
              style: TextStyle(
                color: statusColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }
}

