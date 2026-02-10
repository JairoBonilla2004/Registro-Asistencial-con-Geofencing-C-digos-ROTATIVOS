import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Widget para mostrar la proximidad del estudiante a la zona en tiempo real
class ProximityIndicator extends StatelessWidget {
  final double? distanceInMeters;
  final bool isCalculating;
  final String? zoneName;

  const ProximityIndicator({
    Key? key,
    required this.distanceInMeters,
    required this.isCalculating,
    this.zoneName,
  }) : super(key: key);

  /// Obtiene el mensaje según la distancia
  String _getMessage() {
    if (isCalculating) return 'Calculando ubicación...';
    if (distanceInMeters == null) return 'Ubicación no disponible';
    
    final distance = distanceInMeters!;
    
    if (distance > 200) return '🔴 Muy lejos de la zona';
    if (distance > 100) return '🟠 Estás lejos - Acércate más';
    if (distance > 50) return '🟡 Te estás acercando...';
    if (distance > 20) return '🟡 Ya casi llegas';
    if (distance > 10) return '🟢 Estás muy cerca';
    return '✅ Perfecto - Dentro de la zona';
  }

  /// Obtiene el color según la distancia
  Color _getColor() {
    if (isCalculating || distanceInMeters == null) return Colors.grey;
    
    final distance = distanceInMeters!;
    
    if (distance > 100) return Colors.red;
    if (distance > 50) return Colors.orange;
    if (distance > 10) return Colors.yellow.shade700;
    return Colors.green;
  }

  /// Obtiene el icono según la distancia
  IconData _getIcon() {
    if (isCalculating) return Icons.my_location;
    if (distanceInMeters == null) return Icons.location_off;
    
    final distance = distanceInMeters!;
    
    if (distance > 100) return Icons.not_listed_location;
    if (distance > 50) return Icons.directions_walk;
    if (distance > 10) return Icons.directions_run;
    return Icons.check_circle;
  }

  /// Calcula el progreso (0.0 a 1.0) - más cerca = más progreso
  double _getProgress() {
    if (distanceInMeters == null) return 0.0;
    
    final distance = distanceInMeters!;
    
    // Considerar 200m como máximo (0% progreso) y 0m como 100% progreso
    const maxDistance = 200.0;
    final progress = 1.0 - math.min(distance / maxDistance, 1.0);
    
    return math.max(0.0, progress);
  }

  /// Formatea la distancia para mostrar
  String _formatDistance() {
    if (distanceInMeters == null) return '--';
    
    final distance = distanceInMeters!;
    
    if (distance >= 1000) {
      return '${(distance / 1000).toStringAsFixed(1)} km';
    }
    
    return '${distance.toStringAsFixed(0)} m';
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    final message = _getMessage();
    final icon = _getIcon();
    final progress = _getProgress();
    final distanceText = _formatDistance();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Encabezado con icono y zona
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  zoneName ?? 'Zona del Docente',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Distancia grande
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 40),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tu ubicación',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    distanceText,
                    style: TextStyle(
                      color: color,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Barra de progreso
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              children: [
                Container(
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    height: 16,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          color.withOpacity(0.6),
                          color,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Mensaje de estado
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: color.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isCalculating)
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                if (isCalculating) const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    message,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),

          // Advertencia si está muy lejos
          if (distanceInMeters != null && distanceInMeters! > 50)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                'Acércate para poder escanear el QR',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}
