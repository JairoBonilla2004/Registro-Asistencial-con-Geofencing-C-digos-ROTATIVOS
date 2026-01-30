class AppConstants {
  // Secure Storage Keys
  static const String jwtTokenKey = 'jwt_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';
  static const String userRoleKey = 'user_role';
  static const String deviceIdKey = 'device_id';
  static const String lastSyncKey = 'last_sync';
  
  // Shared Preferences Keys
  static const String isFirstLaunchKey = 'is_first_launch';
  static const String themeKey = 'theme';
  static const String languageKey = 'language';
  
  // Roles
  static const String roleStudent = 'STUDENT';
  static const String roleTeacher = 'TEACHER';
  
  // Providers
  static const String providerLocal = 'LOCAL';
  static const String providerGoogle = 'GOOGLE';
  static const String providerFacebook = 'FACEBOOK';
  static const String providerExternal = 'EXTERNAL';
  
  // QR Configuration
  static const int qrExpirationMinutes = 10;
  static const int qrRegenerationMinutes = 5;
  
  // Location Configuration
  static const int locationAccuracyMeters = 10;
  static const int maxGeofenceRadiusMeters = 500;
  
  // Sync Configuration
  static const int maxOfflineAttendances = 100;
  static const int syncRetryAttempts = 3;
  static const Duration syncRetryDelay = Duration(seconds: 5);
  
  // Polling Configuration
  static const Duration attendancePollingInterval = Duration(seconds: 10);
  static const Duration proximityCheckInterval = Duration(minutes: 5);
  
  // Sensor Types
  static const String sensorTypeCompass = 'COMPASS';
  static const String sensorTypeProximity = 'PROXIMITY';
  
  // Notification Types
  static const String notificationAbsence = 'ABSENCE';
  static const String notificationProximity = 'PROXIMITY_ALERT';
  static const String notificationGeneral = 'GENERAL';
  
  // Report Types
  static const String reportStudentPersonal = 'STUDENT_PERSONAL';
  static const String reportSessionAttendance = 'SESSION_ATTENDANCE';
  
  // Error Codes
  static const String errorTokenExpired = 'TOKEN_EXPIRED';
  static const String errorOutsideGeofence = 'OUTSIDE_GEOFENCE';
  static const String errorAlreadyRegistered = 'ALREADY_REGISTERED';
  static const String errorSessionInactive = 'SESSION_INACTIVE';
  static const String errorInvalidCredentials = 'INVALID_CREDENTIALS';
  static const String errorEmailExists = 'EMAIL_ALREADY_EXISTS';
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 12.0;
  static const double defaultElevation = 2.0;
  
  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);
}
