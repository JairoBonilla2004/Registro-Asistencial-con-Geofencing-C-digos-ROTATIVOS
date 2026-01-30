import 'package:equatable/equatable.dart';

/// Clase base abstracta para todos los failures
abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure(this.message, {this.code});

  @override
  List<Object?> get props => [message, code];
}

/// Fallo de red (sin conexión a internet)
class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'Sin conexión a internet']) : super(message);
}

/// Fallo del servidor (500, 502, 503, etc.)
class ServerFailure extends Failure {
  const ServerFailure([String message = 'Error del servidor', String? code])
      : super(message, code: code);
}

/// Fallo de autenticación (401, 403)
class AuthFailure extends Failure {
  const AuthFailure([String message = 'No autenticado', String? code])
      : super(message, code: code);
}

/// Fallo de validación (400)
class ValidationFailure extends Failure {
  const ValidationFailure([String message = 'Datos inválidos', String? code])
      : super(message, code: code);
}

/// Fallo de no encontrado (404)
class NotFoundFailure extends Failure {
  const NotFoundFailure([String message = 'Recurso no encontrado'])
      : super(message);
}

/// Fallo de cache local
class CacheFailure extends Failure {
  const CacheFailure([String message = 'Error al acceder al almacenamiento local'])
      : super(message);
}

/// Fallo de ubicación/GPS
class LocationFailure extends Failure {
  const LocationFailure([String message = 'Error al obtener ubicación'])
      : super(message);
}

/// Fallo de permisos
class PermissionFailure extends Failure {
  const PermissionFailure([String message = 'Permisos denegados'])
      : super(message);
}

/// Fallo de geofencing (fuera de zona)
class GeofenceFailure extends Failure {
  final double? distance;
  final double? maxRadius;

  const GeofenceFailure(
    String message, {
    this.distance,
    this.maxRadius,
  }) : super(message, code: 'OUTSIDE_GEOFENCE');

  @override
  List<Object?> get props => [message, code, distance, maxRadius];
}

/// Fallo de QR (expirado, inválido)
class QRFailure extends Failure {
  const QRFailure([String message = 'Código QR inválido o expirado', String? code])
      : super(message, code: code);
}

/// Fallo de sincronización
class SyncFailure extends Failure {
  final int? syncedCount;
  final int? failedCount;

  const SyncFailure(
    String message, {
    this.syncedCount,
    this.failedCount,
  }) : super(message);

  @override
  List<Object?> get props => [message, syncedCount, failedCount];
}

/// Fallo genérico/desconocido
class UnknownFailure extends Failure {
  const UnknownFailure([String message = 'Error desconocido']) : super(message);
}
