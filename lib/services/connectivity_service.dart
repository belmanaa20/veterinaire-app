import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  static final Connectivity _connectivity = Connectivity();
  static final StreamController<bool> _connectionStatusController = StreamController<bool>.broadcast();
  
  /// Stream pour écouter les changements de connexion
  static Stream<bool> get connectionStatusStream => _connectionStatusController.stream;
  
  /// Vérifier si l'appareil est en ligne (avec vérification réseau réelle)
  static Future<bool> isOnline() async {
    try {
      // Vérifier la connectivité
      final connectivityResult = await _connectivity.checkConnectivity();
      
      if (connectivityResult.contains(ConnectivityResult.none)) {
        return false;
      }
      
      // Vérifier la connexion réelle (ping Google DNS)
      final result = await InternetAddress.lookup('google.com').timeout(
        const Duration(seconds: 5),
      );
      
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      
    } catch (e) {
      return false;
    }
  }
  
  /// Démarrer l'écoute des changements de connexion
  static void startListening() {
    _connectivity.onConnectivityChanged.listen((result) async {
      final online = await isOnline();
      _connectionStatusController.add(online);
    });
  }
  
  /// Obtenir le statut actuel (synchrone, basé sur cache)
  static Future<List<ConnectivityResult>> getCurrentStatus() async {
    return await _connectivity.checkConnectivity();
  }
  
  /// Fermer le stream controller
  static void dispose() {
    _connectionStatusController.close();
  }
}
