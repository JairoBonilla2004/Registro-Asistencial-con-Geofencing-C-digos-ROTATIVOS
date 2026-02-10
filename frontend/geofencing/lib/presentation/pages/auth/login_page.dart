import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/device_provider.dart';
import '../../../core/providers/firebase_providers.dart';
import '../../widgets/organisms/login_form.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuchar cambios de autenticación para navegar
    ref.listen<AuthState>(authProvider, (previous, next) {
      print('AuthState cambió: isAuthenticated=${next.isAuthenticated}, user=${next.user?.email}, error=${next.error}');
      
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: Colors.red,
          ),
        );
      }
      
      if (next.isAuthenticated && next.user != null) {
        print('Usuario autenticado: ${next.user!.email}, roles: ${next.user!.roles}');
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Bienvenido!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Navegar según rol del usuario
        final roles = next.user!.roles;
        if (roles.contains('DOCENTE') || roles.contains('TEACHER')) {
          print('Navegando a /teacher');
          Navigator.pushReplacementNamed(context, '/teacher');
        } else {
          print('Navegando a /student');
          Navigator.pushReplacementNamed(context, '/student');
        }
      }
    });

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              // Logo
              Icon(
                Icons.location_on,
                size: 100,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 24),
              // Título
              const Text(
                'Asistencia con Geofencing',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Inicia sesión para continuar',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 48),
              // Formulario
              const LoginForm(),
              const SizedBox(height: 24),
              // Link a registro
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('¿No tienes cuenta? '),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    child: const Text('Regístrate'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _registerDeviceAfterLogin(WidgetRef ref) async {
    print('🔵 Iniciando _registerDeviceAfterLogin...');
    
    try {
      print('🔵 Cargando información del dispositivo...');
      // Cargar información del dispositivo guardada
      await ref.read(deviceProvider.notifier).loadDeviceInfo();
      
      final deviceState = ref.read(deviceProvider);
      print('🔵 Device state: deviceId=${deviceState.deviceId}, isRegistered=${deviceState.isRegistered}');
      
      // Si ya está registrado, solo actualizar el token si es necesario
      if (deviceState.isRegistered && deviceState.deviceId != null) {
        print('✅ Dispositivo ya registrado: ${deviceState.deviceId}');
        
        // Configurar listener para cambios en el token
        final messagingService = ref.read(firebaseMessagingServiceProvider);
        messagingService.onTokenRefresh((newToken) {
          print('🔄 Token FCM actualizado');
          ref.read(deviceProvider.notifier).updateFcmToken(newToken);
        });
        
        return;
      }
      
      print('🔵 Dispositivo no registrado, obteniendo servicios...');
      // Obtener servicios
      final messagingService = ref.read(firebaseMessagingServiceProvider);
      
      print('🔵 Obteniendo información del dispositivo...');
      // Obtener información del dispositivo
      final deviceIdentifier = await messagingService.getDeviceIdentifier();
      final platform = messagingService.getPlatform();
      final fcmToken = await messagingService.getToken();
      
      print('🔵 Device Identifier: $deviceIdentifier');
      print('🔵 Platform: $platform');
      print('🔵 FCM Token obtenido: ${fcmToken != null ? "Sí" : "No"}');
      
      if (fcmToken == null) {
        print('⚠️ No se pudo obtener token FCM');
        return;
      }
      
      print('📱 Registrando dispositivo después del login...');
      print('📱 Device ID: $deviceIdentifier');
      print('📱 Platform: $platform');
      
      // Registrar dispositivo
      await ref.read(deviceProvider.notifier).registerDevice(
        deviceIdentifier: deviceIdentifier,
        platform: platform,
        fcmToken: fcmToken,
      );
      
      print('🔵 Registro completado, recargando info...');
      // Recargar información del dispositivo para asegurar que deviceId esté disponible
      await ref.read(deviceProvider.notifier).loadDeviceInfo();
      
      final updatedDeviceState = ref.read(deviceProvider);
      print('✅ Dispositivo registrado exitosamente: ${updatedDeviceState.deviceId}');
      print('📱 Token FCM: ${updatedDeviceState.fcmToken}');
      print('📱 isRegistered: ${updatedDeviceState.isRegistered}');
      
      // Configurar listener para cambios en el token
      messagingService.onTokenRefresh((newToken) {
        print('🔄 Token FCM actualizado');
        ref.read(deviceProvider.notifier).updateFcmToken(newToken);
      });
      
    } catch (e, stackTrace) {
      print('❌ Error registrando dispositivo: $e');
      print('❌ StackTrace: $stackTrace');
    }
  }
}
