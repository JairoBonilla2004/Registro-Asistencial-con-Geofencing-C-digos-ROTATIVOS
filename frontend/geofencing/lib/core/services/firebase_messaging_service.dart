import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Handler para notificaciones en background
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('📱 [Background] Mensaje recibido: ${message.messageId}');
  print('📱 [Background] Título: ${message.notification?.title}');
  print('📱 [Background] Cuerpo: ${message.notification?.body}');
  print('📱 [Background] Data: ${message.data}');
}

class FirebaseMessagingService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
  // Callback para refrescar notificaciones cuando llega un mensaje
  Function()? onNotificationReceived;

  // Inicializar Firebase Messaging
  Future<void> initialize() async {
    try {
      // Crear canal de notificaciones en Android
      if (Platform.isAndroid) {
        const AndroidNotificationChannel channel = AndroidNotificationChannel(
          'absence_notifications', // Debe coincidir con el backend
          'Notificaciones de Ausencias',
          description: 'Notificaciones cuando faltas a una sesión de asistencia',
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
        );

        await _localNotifications
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
            ?.createNotificationChannel(channel);

        print('✅ Canal de notificaciones creado: absence_notifications');
      }

      // Solicitar permisos (iOS y Android 13+)
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      print('📱 Permisos de notificaciones: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('✅ Usuario otorgó permisos de notificaciones');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        print('⚠️ Usuario otorgó permisos provisionales');
      } else {
        print('❌ Usuario denegó permisos de notificaciones');
        return;
      }

      // Inicializar flutter_local_notifications
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      
      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      await _localNotifications.initialize(initializationSettings);
      print('✅ Flutter Local Notifications inicializado');

      // Configurar handler para mensajes en background
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // Handler para mensajes cuando la app está en foreground
      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        print('📱 [Foreground] Mensaje recibido: ${message.messageId}');
        print('📱 [Foreground] Título: ${message.notification?.title}');
        print('📱 [Foreground] Cuerpo: ${message.notification?.body}');
        print('📱 [Foreground] Data: ${message.data}');

        // En foreground FCM NO muestra notificaciones automáticamente
        // Debemos mostrarla nosotros manualmente
        if (message.notification != null) {
          await _showLocalNotification(
            message.notification!.title ?? 'Notificación',
            message.notification!.body ?? '',
            message.data,
          );
        }
        
        // ⭐ REFRESCAR NOTIFICACIONES EN TIEMPO REAL
        if (onNotificationReceived != null) {
          onNotificationReceived!();
        }
      });

      // Handler para cuando el usuario toca una notificación
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('📱 [Opened] Notificación tocada: ${message.messageId}');
        print('📱 [Opened] Data: ${message.data}');

        // ⭐ REFRESCAR NOTIFICACIONES EN TIEMPO REAL
        if (onNotificationReceived != null) {
          onNotificationReceived!();
        }
        
        // Aquí puedes navegar a una pantalla específica
      });

      // Verificar si la app fue abierta desde una notificación
      RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        print('📱 [Initial] App abierta desde notificación: ${initialMessage.messageId}');
        // Manejar navegación inicial
      }

      print('✅ Firebase Messaging inicializado correctamente');
    } catch (e) {
      print('❌ Error inicializando Firebase Messaging: $e');
    }
  }

  // Obtener el token FCM
  Future<String?> getToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        print('📱 Token FCM obtenido: ${token.substring(0, 20)}...');
        return token;
      }
      print('⚠️ No se pudo obtener token FCM');
      return null;
    } catch (e) {
      print('❌ Error obteniendo token FCM: $e');
      return null;
    }
  }

  // Obtener identificador único del dispositivo
  Future<String> getDeviceIdentifier() async {
    final deviceInfo = DeviceInfoPlugin();
    
    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        // Usar androidId como identificador único
        return androidInfo.id; // Android ID único
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return iosInfo.identifierForVendor ?? 'unknown_ios';
      } else {
        return 'unknown_platform';
      }
    } catch (e) {
      print('❌ Error obteniendo identificador de dispositivo: $e');
      return 'error_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  // Obtener plataforma
  String getPlatform() {
    if (Platform.isAndroid) {
      return 'ANDROID';
    } else if (Platform.isIOS) {
      return 'IOS';
    } else {
      return 'OTHER';
    }
  }

  // Mostrar notificación local
  Future<void> _showLocalNotification(
    String title,
    String body,
    Map<String, dynamic> data,
  ) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'absence_notifications',
      'Notificaciones de Ausencias',
      channelDescription: 'Notificaciones cuando faltas a una sesión de asistencia',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecond,
      title,
      body,
      notificationDetails,
      payload: data.toString(),
    );

    print('✅ Notificación local mostrada: $title');
  }

  // Listener para cambios en el token
  void onTokenRefresh(Function(String) callback) {
    _firebaseMessaging.onTokenRefresh.listen((String newToken) {
      print('📱 Token FCM actualizado: ${newToken.substring(0, 20)}...');
      callback(newToken);
    });
  }

  // Suscribirse a un topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      print('📱 Suscrito al topic: $topic');
    } catch (e) {
      print('❌ Error suscribiéndose al topic $topic: $e');
    }
  }

  // Desuscribirse de un topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      print('📱 Desuscrito del topic: $topic');
    } catch (e) {
      print('❌ Error desuscribiéndose del topic $topic: $e');
    }
  }
}
