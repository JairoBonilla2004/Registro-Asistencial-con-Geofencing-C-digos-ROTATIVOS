class ApiConstants {

  static const String baseUrl = 'https://registro-asistencial-con-geofencing-c.onrender.com/api/v1';

  // Endpoints de Autenticación
  static const String register = '/auth/register';
  static const String authenticate = '/auth/authenticate';
  static const String logout = '/auth/logout';
  
  // Endpoints de Dispositivos
  static const String registerDevice = '/devices/register';
  static const String updateFcmToken = '/devices/{deviceId}/fcm';
  static const String updateFCMToken = '/devices/{deviceId}/fcm';
  static const String myDevices = '/devices/me';
  
  // Endpoints de Sesiones
  static const String createSession = '/sessions';
  static const String activeSessions = '/sessions/active';
  static const String activeSessionsWithDistances = '/sessions/active-with-distances';
  static const String mySessions = '/sessions/my-sessions';
  static const String sessions = '/sessions';
  static const String sessionAttendances = '/sessions/{id}/attendances';
  static const String endSession = '/sessions/{id}/end';
  
  // Endpoints de QR
  static const String generateQr = '/qr/generate';
  static const String validateQr = '/qr/validate';
  
  // Endpoints de Geofencing
  static const String geofenceZones = '/geofence/zones';
  static const String createGeofenceZone = '/geofence/zones';
  static const String validateLocation = '/geofence/validate';
  
  // Endpoints de Asistencias
  static const String syncAttendances = '/attendances/sync';
  static const String myHistory = '/attendances/my-history';
  static const String pendingSync = '/attendances/pending-sync';
  
  // Endpoints de Sensores
  static const String sensorEvents = '/sensors/events';
  
  // Endpoints de Notificaciones
  static const String notifications = '/notifications';
  static const String unreadNotifications = '/notifications/unread';
  static const String markAsRead = '/notifications/{id}/read';
  static const String markAllAsRead = '/notifications/read-all';
  
  // Endpoints de Estadísticas
  static const String dashboard = '/statistics/dashboard';
  static const String teacherDashboard = '/statistics/teacher/dashboard';
  static const String sessionStatistics = '/statistics/session/{id}';
  
  // Endpoints de Reportes
  static const String reports = '/reports';
  static const String generateReport = '/reports/generate';
  static const String listReports = '/reports';
  static const String downloadReport = '/reports/{id}/download';
  static const String deleteReport = '/reports/{id}';
  
  // Endpoints de Usuario
  static const String profile = '/users/me'; // Alias para userProfile
  static const String userProfile = '/users/me';
  static const String updateProfile = '/users/me';
  
  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
}
