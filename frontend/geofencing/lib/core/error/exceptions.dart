/// Excepción base para todas las excepciones personalizadas
class AppException implements Exception {
  final String message;
  final String? code;

  AppException(this.message, {this.code});

  @override
  String toString() => code != null ? '[$code] $message' : message;
}

/// Excepción de red
class NetworkException extends AppException {
  NetworkException() : super('Sin conexión a internet');
}

/// Excepción del servidor
class ServerException extends AppException {
  ServerException([String message = 'Error del servidor', String? code])
      : super(message, code: code);
}

/// Excepción de autenticación
class AuthException extends AppException {
  AuthException([String message = 'No autenticado', String? code])
      : super(message, code: code);
}

/// Excepción de validación
class ValidationException extends AppException {
  ValidationException([String message = 'Datos inválidos', String? code])
      : super(message, code: code);
}

/// Excepción de no encontrado
class NotFoundException extends AppException {
  NotFoundException([String message = 'Recurso no encontrado'])
      : super(message);
}

/// Excepción de cache
class CacheException extends AppException {
  CacheException([String message = 'Error al acceder al almacenamiento local'])
      : super(message);
}

/// Excepción de ubicación
class LocationException extends AppException {
  LocationException([String message = 'Error al obtener ubicación'])
      : super(message);
}

/// Excepción de permisos
class PermissionException extends AppException {
  PermissionException([String message = 'Permisos denegados']) : super(message);
}

/// Excepción de geofencing
class GeofenceException extends AppException {
  GeofenceException([String message = 'Error de geofencing', String? code])
      : super(message, code: code);
}

/// Excepción de QR
class QRException extends AppException {
  QRException([String message = 'Error de código QR', String? code])
      : super(message, code: code);
}
