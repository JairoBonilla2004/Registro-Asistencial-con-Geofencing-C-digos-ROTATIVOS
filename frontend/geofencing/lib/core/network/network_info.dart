import 'package:connectivity_plus/connectivity_plus.dart';

/// Clase para verificar el estado de la conexión a internet
class NetworkInfo {
  final Connectivity _connectivity;

  NetworkInfo(this._connectivity);

  /// Verifica si hay conexión a internet
  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  /// Stream que emite cambios en la conectividad
  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map(
      (result) => result != ConnectivityResult.none,
    );
  }

  /// Obtiene el tipo de conexión actual
  Future<ConnectivityResult> get connectionType async {
    return await _connectivity.checkConnectivity();
  }
}
