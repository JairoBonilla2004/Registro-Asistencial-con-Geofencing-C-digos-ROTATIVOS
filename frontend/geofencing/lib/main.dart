import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/services/firebase_messaging_service.dart';
import 'core/services/app_lifecycle_service.dart';
import 'core/providers/firebase_providers.dart';
import 'core/utils/session_manager.dart';
import 'data/models/offline_attendance_model.dart';
import 'presentation/pages/auth/login_page.dart';
import 'presentation/pages/auth/register_page.dart';
import 'presentation/pages/student/student_home_page.dart';
import 'presentation/pages/student/scan_qr_page.dart';
import 'presentation/pages/student/active_sessions_page.dart';
import 'presentation/pages/teacher/teacher_home_page.dart';
import 'presentation/pages/teacher/create_session_page.dart';
import 'presentation/pages/teacher/my_sessions_page.dart';
import 'presentation/pages/teacher/geofence_zones_page.dart';
import 'presentation/pages/teacher/session_detail_page.dart';
import 'presentation/pages/shared/reports_page.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/device_provider.dart';
import 'presentation/providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  print('Firebase inicializado');

  final firebaseMessagingService = FirebaseMessagingService();
  await firebaseMessagingService.initialize();

  await Hive.initFlutter();

  Hive.registerAdapter(OfflineAttendanceModelAdapter());
  
  // Abrir cajas de Hive
  await Hive.openBox<OfflineAttendanceModel>('offline_attendances');

  runApp(
    ProviderScope(
      overrides: [
        // Proveer el servicio de Firebase Messaging
        firebaseMessagingServiceProvider.overrideWithValue(firebaseMessagingService),
      ],
      child: const MyApp(),
    ),
  );
}


class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    
    return MaterialApp(
      title: 'Asistencia con Geofencing',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey, // Key global para navegación desde cualquier lugar
      themeMode: themeMode, // Modo de tema dinámico
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
          // Colores personalizados para mejor contraste en modo oscuro
          surface: const Color(0xFF1E1E1E),           // Fondo de tarjetas más oscuro
          background: const Color(0xFF121212),         // Fondo principal negro suave
          primary: const Color(0xFF64B5F6),            // Azul más brillante
          secondary: const Color(0xFF81C784),          // Verde para acciones secundarias
          error: const Color(0xFFEF5350),              // Rojo para errores
          onSurface: const Color(0xFFE0E0E0),          // Texto sobre superficies (gris claro)
          onBackground: const Color(0xFFFFFFFF),       // Texto sobre fondo (blanco)
          onPrimary: const Color(0xFF000000),          // Texto sobre botones primarios (negro)
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Color(0xFF1E1E1E),
          foregroundColor: Color(0xFFFFFFFF),
        ),
        cardTheme: CardThemeData(
          elevation: 4,
          color: const Color(0xFF2C2C2C),              // Tarjetas con fondo gris oscuro
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFFE0E0E0)),
          bodyMedium: TextStyle(color: Color(0xFFB0B0B0)),
          titleLarge: TextStyle(color: Color(0xFFFFFFFF), fontWeight: FontWeight.bold),
          titleMedium: TextStyle(color: Color(0xFFE0E0E0)),
          labelLarge: TextStyle(color: Color(0xFFFFFFFF)),
        ),
        iconTheme: const IconThemeData(
          color: Color(0xFFE0E0E0),
        ),
        dividerColor: const Color(0xFF424242),
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/student': (context) => const StudentHomePage(),
        '/teacher': (context) => const TeacherHomePage(),
        '/scan-qr': (context) => const ScanQRPage(),
        '/active-sessions': (context) => const ActiveSessionsPage(),
        '/create-session': (context) => const CreateSessionPage(),
        '/my-sessions': (context) => const MySessionsPage(),
        '/geofence-zones': (context) => const GeofenceZonesPage(),
        '/reports': (context) => const ReportsPage(),
      },
      onGenerateRoute: (settings) {
        // Ruta dinámica para session-detail con parámetro
        if (settings.name == '/session-detail') {
          final sessionId = settings.arguments as String?;
          return MaterialPageRoute(
            builder: (context) => SessionDetailPage(sessionId: sessionId),
          );
        }
        return null;
      },
    );
  }
}

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  late final AppLifecycleService _lifecycleService;

  @override
  void initState() {
    super.initState();
    _initializeAppLifecycle();
    _checkAuthAndNavigate();
  }

  void _initializeAppLifecycle() {
    _lifecycleService = AppLifecycleService(
      onResumed: () {
        // Cuando la app vuelve a primer plano, verificar sesión
        final authState = ref.read(authProvider);
        if (authState.isAuthenticated) {
          print('✅ App volvió a primer plano - Sesión activa');
          // Opcional: Re-validar token o sincronizar datos
        }
      },
      onPaused: () {
        // App va a background - NO desactivar dispositivo
        // El usuario sigue recibiendo notificaciones (estilo WhatsApp)
        print('🟡 App en background - Notificaciones activas');
      },
    );
    _lifecycleService.initialize();
  }

  @override
  void dispose() {
    _lifecycleService.dispose();
    super.dispose();
  }

  Future<void> _checkAuthAndNavigate() async {
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    
    try {
      // SOLUCIÓN PROFESIONAL: Verificar sesión persistente (estilo WhatsApp/Gmail)
      // - Si hay sesión válida, recupera el usuario
      // - Auto-registra el dispositivo para notificaciones
      await ref.read(authProvider.notifier).checkAuthStatus();
      
      if (!mounted) return;
      
      final authState = ref.read(authProvider);
      
      if (authState.isAuthenticated && authState.user != null) {
        // Sesión válida encontrada, dispositivo ya re-registrado automáticamente
        print('✅ Sesión recuperada - Usuario: ${authState.user?.email}');
        print('✅ Roles: ${authState.user?.roles}');
        
        // Navegar según rol del usuario
        if (authState.isStudent) {
          print('➡️ Navegando a Student Home');
          Navigator.pushReplacementNamed(context, '/student');
        } else if (authState.isTeacher) {
          print('➡️ Navegando a Teacher Home');
          Navigator.pushReplacementNamed(context, '/teacher');
        } else {
          print('⚠️ Usuario sin rol definido - Ir a login');
          Navigator.pushReplacementNamed(context, '/login');
        }
      } else {
        // No hay sesión, ir a login
        print('ℹ️ No hay sesión - Ir a login');
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      print('❌ Error en _checkAuthAndNavigate: $e');
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future<void> _registerDeviceIfNeeded() async {
    try {
      // Cargar información del dispositivo guardada
      await ref.read(deviceProvider.notifier).loadDeviceInfo();
      
      final deviceState = ref.read(deviceProvider);
      
      // Si ya está registrado, solo actualizar el token si es necesario
      if (deviceState.isRegistered && deviceState.deviceId != null) {
        print('✅ Dispositivo ya registrado: ${deviceState.deviceId}');
        
        // Configurar listener para cambios en el token
        final messagingService = ref.read(firebaseMessagingServiceProvider);
        messagingService.onTokenRefresh((newToken) {
          ref.read(deviceProvider.notifier).updateFcmToken(newToken);
        });
        
        return;
      }
      
      // Obtener servicios
      final messagingService = ref.read(firebaseMessagingServiceProvider);
      
      // Obtener información del dispositivo
      final deviceIdentifier = await messagingService.getDeviceIdentifier();
      final platform = messagingService.getPlatform();
      final fcmToken = await messagingService.getToken();
      
      if (fcmToken == null) {
        print('⚠️ No se pudo obtener token FCM');
        return;
      }
      
      print('📱 Registrando dispositivo...');
      print('📱 Device ID: $deviceIdentifier');
      print('📱 Platform: $platform');
      
      // Registrar dispositivo
      await ref.read(deviceProvider.notifier).registerDevice(
        deviceIdentifier: deviceIdentifier,
        platform: platform,
        fcmToken: fcmToken,
      );
      
      // Configurar listener para cambios en el token
      messagingService.onTokenRefresh((newToken) {
        ref.read(deviceProvider.notifier).updateFcmToken(newToken);
      });
      
      print('✅ Dispositivo registrado exitosamente');
    } catch (e) {
      print('❌ Error registrando dispositivo: $e');
      // No bloqueamos el inicio de sesión por errores en el registro del dispositivo
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.7),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.location_on,
                  size: 80,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Asistencia con Geofencing',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Control de asistencia con ubicación',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 40),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
