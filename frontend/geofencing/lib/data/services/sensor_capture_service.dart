import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:sensors_plus/sensors_plus.dart';
import '../../domain/entities/sensor_data.dart';

/// Servicio para captura de datos de sensores
class SensorCaptureService {
  final List<SensorData> _capturedData = [];
  StreamSubscription<MagnetometerEvent>? _magnetometerSubscription;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  
  bool _isCapturing = false;
  DateTime? _captureStartTime;
  
  /// Duración de captura en segundos
  static const int captureDurationSeconds = 2;
  
  /// Intervalo entre lecturas en milisegundos  
  static const int readingIntervalMs = 1000;
  
  /// Máximo número de lecturas por sensor (CRÍTICO: evitar llenar la BD)
  static const int maxReadingsPerSensor = 2;

  /// Inicia la captura de sensores
  Future<void> startCapture() async {
    if (_isCapturing) return;
    
    _isCapturing = true;
    _captureStartTime = DateTime.now();
    _capturedData.clear();
    
    print('📱 Iniciando captura de sensores...');
    
    // Capturar brújula (magnetómetro)
    _magnetometerSubscription = magnetometerEventStream(
      samplingPeriod: Duration(milliseconds: readingIntervalMs),
    ).listen(
      (MagnetometerEvent event) {
        if (!_isCapturing) return;
        
        final now = DateTime.now();
        if (_captureStartTime != null &&
            now.difference(_captureStartTime!).inSeconds >= captureDurationSeconds) {
          return;
        }
        
        _captureMagnetometerData(event);
      },
      onError: (error) {
        print('❌ Error en magnetómetro: $error');
      },
    );
    
    // Capturar acelerómetro (para detectar movimiento)
    try {
      _accelerometerSubscription = accelerometerEventStream(
        samplingPeriod: Duration(milliseconds: readingIntervalMs),
      ).listen(
        (AccelerometerEvent event) {
          if (!_isCapturing) return;
          
          final now = DateTime.now();
          if (_captureStartTime != null &&
              now.difference(_captureStartTime!).inSeconds >= captureDurationSeconds) {
            return;
          }
          
          _captureAccelerometerData(event);
        },
        onError: (error) {
          print('⚠️ Error en acelerómetro: $error');
        },
      );
    } catch (e) {
      print('⚠️ Acelerómetro no soportado en este dispositivo');
    }
  }

  /// Captura datos del magnetómetro (brújula)
  void _captureMagnetometerData(MagnetometerEvent event) {
    // LÍMITE: Solo capturar maxReadingsPerSensor lecturas
    final compassCount = _capturedData.where((d) => d.type == SensorType.COMPASS).length;
    if (compassCount >= maxReadingsPerSensor) return;
    
    // Calcular azimuth (orientación de la brújula)
    final double azimuth = _calculateAzimuth(event.x, event.y, event.z);
    
    // Calcular pitch y roll aproximados
    final double pitch = math.atan2(event.y, math.sqrt(event.x * event.x + event.z * event.z)) * 180 / math.pi;
    final double roll = math.atan2(event.x, math.sqrt(event.y * event.y + event.z * event.z)) * 180 / math.pi;
    
    final compassData = {
      'azimuth': azimuth.toStringAsFixed(2),
      'pitch': pitch.toStringAsFixed(2),
      'roll': roll.toStringAsFixed(2),
      'x': event.x.toStringAsFixed(2),
      'y': event.y.toStringAsFixed(2),
      'z': event.z.toStringAsFixed(2),
    };
    
    final sensorData = SensorData(
      type: SensorType.COMPASS,
      value: jsonEncode(compassData),
      deviceTime: DateTime.now(),
    );
    
    _capturedData.add(sensorData);
    print('🧭 Brújula: azimuth=${azimuth.toStringAsFixed(1)}°, pitch=${pitch.toStringAsFixed(1)}°');
  }

  /// Captura datos del acelerómetro (detecta movimiento/proximidad)
  void _captureAccelerometerData(AccelerometerEvent event) {
    // LÍMITE: Solo capturar maxReadingsPerSensor lecturas
    final proximityCount = _capturedData.where((d) => d.type == SensorType.PROXIMITY).length;
    if (proximityCount >= maxReadingsPerSensor) return;
    
    // Calcular magnitud del movimiento
    final double magnitude = math.sqrt(
      event.x * event.x + event.y * event.y + event.z * event.z
    );
    
    // Determinar si está "cerca" basado en la orientación del dispositivo
    // Un dispositivo horizontal (en mesa) tendrá Z cercano a 9.8
    // Un dispositivo vertical o en movimiento tendrá otros valores
    final bool isNearUser = magnitude > 8.0 && magnitude < 12.0;
    
    final proximityData = {
      'near': isNearUser,
      'magnitude': magnitude.toStringAsFixed(2),
      'x': event.x.toStringAsFixed(2),
      'y': event.y.toStringAsFixed(2),
      'z': event.z.toStringAsFixed(2),
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    
    final sensorData = SensorData(
      type: SensorType.PROXIMITY,
      value: jsonEncode(proximityData),
      deviceTime: DateTime.now(),
    );
    
    _capturedData.add(sensorData);
    print('📏 Acelerómetro: mag=${magnitude.toStringAsFixed(1)}, near=$isNearUser');
  }

  /// Calcula el azimuth (orientación de la brújula) en grados
  double _calculateAzimuth(double x, double y, double z) {
    double azimuth = math.atan2(y, x) * 180 / math.pi;
    if (azimuth < 0) {
      azimuth += 360;
    }
    return azimuth;
  }

  /// Detiene la captura y retorna los datos recolectados
  Future<List<SensorData>> stopCaptureAndGetData() async {
    print('🛑 Deteniendo captura de sensores...');
    
    _isCapturing = false;
    
    await _magnetometerSubscription?.cancel();
    await _accelerometerSubscription?.cancel();
    
    _magnetometerSubscription = null;
    _accelerometerSubscription = null;
    
    final capturedCount = _capturedData.length;
    final compassCount = _capturedData.where((d) => d.type == SensorType.COMPASS).length;
    final proximityCount = _capturedData.where((d) => d.type == SensorType.PROXIMITY).length;
    
    print('✅ Captura completada: $capturedCount eventos ($compassCount brújula, $proximityCount proximidad)');
    
    return List.from(_capturedData);
  }

  /// Cancela la captura sin retornar datos
  Future<void> cancelCapture() async {
    _isCapturing = false;
    
    await _magnetometerSubscription?.cancel();
    await _accelerometerSubscription?.cancel();
    
    _magnetometerSubscription = null;
    _accelerometerSubscription = null;
    
    _capturedData.clear();
    print('❌ Captura de sensores cancelada');
  }

  /// Verifica si los sensores están disponibles
  Future<Map<String, bool>> checkSensorsAvailability() async {
    bool hasMagnetometer = false;
    bool hasProximity = false;
    
    // Probar magnetómetro
    try {
      final completer = Completer<bool>();
      final subscription = magnetometerEventStream().listen(
        (_) {
          if (!completer.isCompleted) completer.complete(true);
        },
        onError: (_) {
          if (!completer.isCompleted) completer.complete(false);
        },
      );
      
      hasMagnetometer = await completer.future.timeout(
        const Duration(seconds: 2),
        onTimeout: () => false,
      );
      
      await subscription.cancel();
    } catch (e) {
      hasMagnetometer = false;
    }
    
    // Probar acelerómetro (como sensor de proximidad)
    try {
      final completer = Completer<bool>();
      final subscription = accelerometerEventStream().listen(
        (_) {
          if (!completer.isCompleted) completer.complete(true);
        },
        onError: (_) {
          if (!completer.isCompleted) completer.complete(false);
        },
      );
      
      hasProximity = await completer.future.timeout(
        const Duration(seconds: 2),
        onTimeout: () => false,
      );
      
      await subscription.cancel();
    } catch (e) {
      hasProximity = false;
    }
    
    return {
      'magnetometer': hasMagnetometer,
      'proximity': hasProximity,
    };
  }

  /// Limpia recursos
  void dispose() {
    _magnetometerSubscription?.cancel();
    _accelerometerSubscription?.cancel();
    _capturedData.clear();
  }
}
