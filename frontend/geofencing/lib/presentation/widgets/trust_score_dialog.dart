import 'package:flutter/material.dart';

class TrustScoreDialog extends StatelessWidget {
  final int? trustScore;
  final bool withinGeofence;

  const TrustScoreDialog({
    Key? key,
    required this.trustScore,
    required this.withinGeofence,
  }) : super(key: key);

  Color _getScoreColor(int? score) {
    if (score == null) return Colors.grey;
    if (score >= 70) return Colors.green;
    if (score >= 50) return Colors.orange;
    return Colors.red;
  }

  String _getScoreLevel(int? score) {
    if (score == null) return 'Desconocido';
    if (score >= 70) return 'VÁLIDO';
    if (score >= 50) return 'SOSPECHOSO';
    return 'INVÁLIDO';
  }

  IconData _getScoreIcon(int? score) {
    if (score == null) return Icons.help_outline;
    if (score >= 70) return Icons.check_circle;
    if (score >= 50) return Icons.warning;
    return Icons.cancel;
  }

  String _getScoreMessage(int? score) {
    if (score == null) {
      return 'No se pudieron capturar datos de sensores';
    }
    if (score >= 70) {
      return 'Registro validado con alta confiabilidad';
    }
    if (score >= 50) {
      return 'Registro marcado para revisión del docente';
    }
    return 'Registro con baja confiabilidad';
  }

  @override
  Widget build(BuildContext context) {
    final color = _getScoreColor(trustScore);
    final level = _getScoreLevel(trustScore);
    final icon = _getScoreIcon(trustScore);
    final message = _getScoreMessage(trustScore);
    final scoreValue = trustScore ?? 0;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icono y título
            Icon(
              Icons.check_circle_outline,
              color: Colors.green,
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              '¡Asistencia Registrada!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Confiabilidad Score
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color, width: 2),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, color: color, size: 32),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Confiabilidad',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            '$scoreValue%',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Barra de progreso
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: scoreValue / 100,
                      minHeight: 12,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Nivel
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      level,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Mensaje explicativo
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // Estado de geofencing
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  withinGeofence ? Icons.location_on : Icons.location_off,
                  color: withinGeofence ? Colors.green : Colors.orange,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  withinGeofence
                      ? 'Dentro de la zona'
                      : 'Fuera de la zona',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Botón cerrar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Entendido',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
