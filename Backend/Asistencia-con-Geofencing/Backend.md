# Proyecto 4 — Registro Asistencial con Geofencing + Códigos Rotativos

Estado: Diseño técnico y base de datos listos para implementar en 50 días.

Este documento describe tecnologías, arquitectura, endpoints REST (`api/v1`), y el esquema de base de datos en Postgres definido en [borrar/borrar.sql](borrar/borrar.sql). Todo se ajusta estrictamente a los requisitos: autenticación triple, geofencing, códigos QR dinámicos, funcionamiento offline, sincronización, sensores (brújula y proximidad), notificaciones, estadísticas personales y reportes PDF por rol.

## Tecnologías

- Front móvil: Flutter (Android-only, gratuito)
    - Estado: Riverpod (estructurado)
    - Offline: `sqflite` (SQLite local), caché + persistencia
    - Geolocalización/Geofencing: `geolocator` + validación en API
    - QR: `qr_code_scanner`
    - OAuth: `google_sign_in`, `flutter_facebook_auth`
    - Notificaciones Push: Firebase Cloud Messaging (gratuito)

- Front web (docente): React + Vite (gratuito, navegador — no iOS nativo)
    - UI atómica (Atomic Design) para panel de sesiones y QR
    - Tema claro/oscuro y animaciones básicas

- Backend: Spring Boot (API REST `api/v1`), PostgreSQL
    - Seguridad: Spring Security + JWT (JJWT)
    - Persistencia: Spring Data JPA
    - QR dinámico: generación de tokens + imagen QR (ZXing)
    - PDF: iText o OpenPDF (gratuitos)
    - Push: FCM server SDK (HTTP v1)

## Base de Datos (PostgreSQL)

Definida en [borrar/borrar.sql](borrar/borrar.sql). Tablas clave:
- `users`, `roles`, `user_roles`: usuarios y roles (ESTUDIANTE, DOCENTE, ADMIN).
- `oauth_accounts`: vincula cuentas Google/Facebook/externo con usuarios.
- (Sin refresh) JWT de vida corta, no se persiste token de actualización.
- `devices`: registro de dispositivos (ANDROID/WEB) + `fcm_token`.
- `geofence_zones`: zonas circulares para validar presencia (campus).
- `attendance_sessions`: sesiones iniciadas por docente, con geofence.
- `qr_tokens`: tokens por sesión con expiración (rotación 20–30s).
- `attendances`: asistencias con hora del dispositivo + servidor, ubicación, geofence, estado de sincronización y referencia de dispositivo/lote.
- `sync_batches`: lotes recibidos del cliente tras reconexión.
- `sensor_events`: eventos de brújula y proximidad (cumple sensores).
- `notifications`: ausencias y alertas por cercanía.
- `report_requests`: solicitudes de reporte (estudiante personal o sesión del día) sin cursos adicionales.

Índices añadidos para rendimiento: emails, sesiones por docente, asistencias por sesión/alumno, expiración de QR, etc.

## API REST — Endpoints (`/api/v1`) y Servicios

Autenticación (triple, sin refresh):
- POST `/api/v1/auth/login` — email+password → JWT (expira 20–30 min)
- POST `/api/v1/auth/google` — `idToken` Google → JWT (expira 20–30 min)
- POST `/api/v1/auth/facebook` — `accessToken` Facebook → JWT (expira 20–30 min)
- POST `/api/v1/auth/external-login` — valida contra API externa (opcional) y emite JWT corto
- POST `/api/v1/auth/logout` — cierra sesión cliente y opcionalmente elimina `fcm_token`
- GET `/api/v1/auth/me` — perfil del usuario autenticado

Dispositivos y Notificaciones:
- POST `/api/v1/devices/register` — registra `device_identifier`, `platform`, `fcm_token`
- PUT `/api/v1/devices/{id}/token` — actualiza `fcm_token`
- GET `/api/v1/notifications/me` — lista mis notificaciones

Geofencing:
- GET `/api/v1/geofencing/zones` — lista zonas
- POST `/api/v1/geofencing/zones` — crea zona (admin)
- PUT `/api/v1/geofencing/zones/{id}` — actualiza zona (admin)
- DELETE `/api/v1/geofencing/zones/{id}` — elimina zona (admin)

Sesiones de asistencia (docente):
- POST `/api/v1/sessions` — crea sesión (`geofence_id`, `start_time`)
- PATCH `/api/v1/sessions/{id}/close` — cierra sesión (`end_time`, `active=false`)
- GET `/api/v1/sessions` — lista mis sesiones (docente)
- GET `/api/v1/sessions/{id}` — detalle de sesión

QR dinámico:
- GET `/api/v1/sessions/{id}/qr` — obtiene token vigente + expiración
    - Servicio rota token cada 20–30s y valida expiración al registrar asistencia

Registro de asistencia (estudiante):
- POST `/api/v1/attendance` — payload: `session_id`, `qr_token`, `device_time`, `latitude`, `longitude`, `sensorData`
    - Servicio valida: token vigente, duplicados, geofence, ventana de tiempo
- GET `/api/v1/attendance/me` — historial personal
- GET `/api/v1/sessions/{id}/attendance` — lista presentes/ausentes de la sesión (docente)

Offline / Sincronización:
- POST `/api/v1/sync/batch` — envía lote de asistencias y eventos capturados offline
    - Servicio crea `sync_batches`, marca registros `is_synced=true`

Sensores:
- POST `/api/v1/sensors/events` — registra eventos de `COMPASS`/`PROXIMITY` con `device_time`

Estadísticas (no globales):
- GET `/api/v1/statistics/me` — porcentaje personal de asistencia
- GET `/api/v1/statistics/session/{id}` — totales de la sesión (docente)

Reportes PDF (bajo demanda por humano):
- POST `/api/v1/reports/student` — genera reporte personal del estudiante autenticado → PDF
- POST `/api/v1/reports/session` — genera reporte de la sesión (docente) → PDF
- GET `/api/v1/reports/{id}/download` — descarga el PDF si autorizado

## Lógica Clave de Negocio

- Geofencing: el servidor valida `within_geofence` usando `geofence_zones` (posiciones del cliente con margen de error controlado). El docente no usa geofencing.
- QR rotativo: `qr_tokens` por sesión con `expires_at`. Un token expirado se rechaza y no se reutiliza.
- Duplicados: `UNIQUE (session_id, student_id)` impide doble registro.
- Offline: el móvil guarda en SQLite. Al reconectar, envía a `/sync/batch`; el backend consolida y marca `is_synced`.
- Sensores: se persiste `sensor_events` y resumen en `attendances.sensor_status`.
- Notificaciones: se envían por FCM para ausencias o cercanía al campus.
- Reportes: el sistema genera PDF, pero el humano los solicita. Tipos: estudiante personal y sesión del día.

## Cumplimiento de Requisitos

- Autenticación triple: LOCAL + Google + Facebook (+ externo opcional). JWT centralizado.
- Geofencing: validación en servidor con zonas definidas.
- Códigos dinámicos: rotación y expiración cada 20–30s.
- Offline/Online: almacenamiento local, sincronización y resolución mínima de conflictos.
- Sensores: captura de brújula y proximidad.
- Notificaciones: ausencias y alertas por cercanía.
- Estadísticas: personales y por sesión, sin globales visibles.
- Reportes PDF: estudiante y docente; el sistema sólo genera bajo demanda.

## Consideraciones de Implementación (Spring Boot)

- Versionado: todas las rutas bajo `/api/v1`.
- Seguridad: filtros JWT cortos (20–30 min); roles `ESTUDIANTE` y `DOCENTE`.
- Servicios: AuthService, GeofenceService, SessionService, QRService, AttendanceService, SyncService, SensorService, NotificationService, ReportService, StatisticsService.
- Gratuito: librerías y servicios open source + FCM.

Sin añadir entidades de cursos ni otras no requeridas; los reportes del docente se limitan a la sesión de asistencia.
