import 'package:flutter/material.dart';

/// Key global del navigator para navegación desde cualquier contexto
/// Útil para manejar sesiones expiradas, errores globales, etc.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Maneja errores de sesión expirada de manera profesional
class SessionManager {
  static bool _isNavigatingToLogin = false;
  static bool _hasShownMessage = false;

  /// Navega al login con mensaje de sesión expirada
  static Future<void> handleSessionExpired({String? message}) async {
    // Evitar navegaciones múltiples
    if (_isNavigatingToLogin) {
      print('⚠️ Ya se está manejando sesión expirada, ignorando llamada duplicada');
      return;
    }
    
    _isNavigatingToLogin = true;

    try {
      final context = navigatorKey.currentContext;
      if (context == null) {
        print('⚠️ No hay contexto disponible para mostrar mensaje');
        return;
      }

      // Mostrar mensaje solo una vez
      if (!_hasShownMessage) {
        _hasShownMessage = true;
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              message ?? 'Tu sesión ha expirado. Por favor, inicia sesión nuevamente.',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.orange.shade700,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      // Esperar un momento antes de navegar
      await Future.delayed(const Duration(milliseconds: 300));

      // Navegar al login limpiando el stack
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        '/login',
        (route) => false,
      );
      
      print('✅ Navegado a login por sesión expirada');
    } finally {
      // Resetear después de 3 segundos
      Future.delayed(const Duration(seconds: 3), () {
        _isNavigatingToLogin = false;
        _hasShownMessage = false;
      });
    }
  }

  /// Muestra un error genérico amigable
  static void showError(String message) {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Muestra un mensaje de éxito
  static void showSuccess(String message) {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green.shade700,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
