import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../config/app_constants.dart';

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
      
      // Vérifier la connexion réelle (ping avec fallback hosts)
      for (final host in AppConstants.connectivityPingHosts) {
        try {
          final result = await InternetAddress.lookup(host).timeout(
            const Duration(seconds: 5),
          );
          
          if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
            return true;
          }
        } catch (e) {
          // Try next host
          continue;
        }
      }
      
      return false;
      
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
