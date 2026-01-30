import 'package:flutter/material.dart';

/// Servicio para manejar el ciclo de vida de la aplicación
/// SOLUCIÓN PROFESIONAL (estilo WhatsApp/Gmail):
/// - Mantiene la sesión activa mientras el usuario esté usando la app
/// - No desactiva el dispositivo al ir a background (usuario puede recibir notificaciones)
/// - Solo desactiva cuando hace logout explícito
class AppLifecycleService with WidgetsBindingObserver {
  final Function()? onResumed;
  final Function()? onPaused;
  final Function()? onInactive;
  final Function()? onDetached;

  AppLifecycleService({
    this.onResumed,
    this.onPaused,
    this.onInactive,
    this.onDetached,
  });

  void initialize() {
    WidgetsBinding.instance.addObserver(this);
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        // App vuelve a primer plano
        print('🔵 App RESUMED - Usuario activo');
        onResumed?.call();
        break;

      case AppLifecycleState.paused:
        // App va a background (pero sigue recibiendo notificaciones)
        print('🟡 App PAUSED - Usuario puede recibir notificaciones');
        onPaused?.call();
        break;

      case AppLifecycleState.inactive:
        // App en transición (ej: llamada entrante, multitarea)
        print('🟠 App INACTIVE - Transición temporal');
        onInactive?.call();
        break;

      case AppLifecycleState.detached:
        // App completamente cerrada (muy raro en Flutter)
        print('🔴 App DETACHED - App terminada');
        onDetached?.call();
        break;

      case AppLifecycleState.hidden:
        // App oculta pero no desconectada
        print('⚫ App HIDDEN');
        break;
    }
  }
}
