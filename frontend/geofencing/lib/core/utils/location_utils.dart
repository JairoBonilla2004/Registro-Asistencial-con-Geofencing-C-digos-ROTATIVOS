import 'dart:math';

/// Utilidades para cálculos de geolocalización
class LocationUtils {
  /// Calcula la distancia entre dos puntos usando la fórmula de Haversine
  /// Retorna la distancia en metros
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadius = 6371000; // Radio de la Tierra en metros

    // Convertir grados a radianes
    final lat1Rad = _degreesToRadians(lat1);
    final lat2Rad = _degreesToRadians(lat2);
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);

    // Fórmula de Haversine
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1Rad) * cos(lat2Rad) * sin(dLon / 2) * sin(dLon / 2);
    
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  /// Verifica si un punto está dentro de un geofence circular
  static bool isWithinGeofence(
    double currentLat,
    double currentLon,
    double geofenceLat,
    double geofenceLon,
    double radiusMeters,
  ) {
    final distance = calculateDistance(
      currentLat,
      currentLon,
      geofenceLat,
      geofenceLon,
    );
    return distance <= radiusMeters;
  }

  /// Convierte grados a radianes
  static double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  /// Formatea la distancia para mostrar al usuario
  static String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)} m';
    } else {
      return '${(meters / 1000).toStringAsFixed(2)} km';
    }
  }
}
