import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

/// Servicio para obtener información del dispositivo
class DeviceInfoService {
  static final DeviceInfoService _instance = DeviceInfoService._internal();
  factory DeviceInfoService() => _instance;
  DeviceInfoService._internal();

  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  String? _cachedDeviceId;

  /// Obtiene un identificador único del dispositivo
  /// Formato: "platform_model_id"
  /// Ejemplo: "android_samsung_sm-g973f_abc123"
  Future<String> getDeviceIdentifier() async {
    // Usar caché si ya lo obtuvimos
    if (_cachedDeviceId != null) {
      return _cachedDeviceId!;
    }

    try {
      String deviceId;

      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await _deviceInfo.androidInfo;
        deviceId = 'android_${androidInfo.model}_${androidInfo.id}'
            .toLowerCase()
            .replaceAll(' ', '_')
            .replaceAll('-', '_');
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await _deviceInfo.iosInfo;
        deviceId = 'ios_${iosInfo.model}_${iosInfo.identifierForVendor}'
            .toLowerCase()
            .replaceAll(' ', '_')
            .replaceAll('-', '_');
      } else {
        // Fallback para otras plataformas
        deviceId = 'unknown_${DateTime.now().millisecondsSinceEpoch}';
      }

      _cachedDeviceId = deviceId;
      return deviceId;
    } catch (e) {
      print('Error obteniendo identificador de dispositivo: $e');
      // Fallback si hay error
      _cachedDeviceId = 'fallback_${DateTime.now().millisecondsSinceEpoch}';
      return _cachedDeviceId!;
    }
  }

  /// Limpia el caché del device ID (útil para testing)
  void clearCache() {
    _cachedDeviceId = null;
  }

  /// Obtiene información detallada del dispositivo para debugging
  Future<Map<String, dynamic>> getDeviceInfo() async {
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await _deviceInfo.androidInfo;
      return {
        'platform': 'Android',
        'model': androidInfo.model,
        'manufacturer': androidInfo.manufacturer,
        'androidId': androidInfo.id,
        'version': androidInfo.version.release,
        'sdk': androidInfo.version.sdkInt,
      };
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await _deviceInfo.iosInfo;
      return {
        'platform': 'iOS',
        'model': iosInfo.model,
        'name': iosInfo.name,
        'identifierForVendor': iosInfo.identifierForVendor,
        'systemVersion': iosInfo.systemVersion,
      };
    }
    return {'platform': 'Unknown'};
  }
}
