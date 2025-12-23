import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'hive_service.dart';

class ConnectivityMonitor {
  static final ConnectivityMonitor _instance = ConnectivityMonitor._internal();
  factory ConnectivityMonitor() => _instance;
  ConnectivityMonitor._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _subscription;
  
  bool _isOnline = true;
  bool get isOnline => _isOnline;

  final _onlineController = StreamController<bool>.broadcast();
  Stream<bool> get onlineStream => _onlineController.stream;

  /// Start monitoring connectivity
  Future<void> start() async {
    // Check initial connectivity
    final result = await _connectivity.checkConnectivity();
    _updateConnectionStatus(result);

    // Listen to connectivity changes
    _subscription = _connectivity.onConnectivityChanged.listen((result) {
      _updateConnectionStatus(result);
    });
  }

  /// Stop monitoring connectivity
  void stop() {
    _subscription?.cancel();
    _onlineController.close();
  }

  /// Update connection status
  void _updateConnectionStatus(ConnectivityResult result) {
    final wasOnline = _isOnline;
    _isOnline = result != ConnectivityResult.none;

    // Update Hive metadata
    HiveService.setOfflineMode(!_isOnline);

    // Notify listeners
    _onlineController.add(_isOnline);

    // Log status change
    if (wasOnline != _isOnline) {
      print(_isOnline 
          ? '🌐 Connection restored - Now ONLINE' 
          : '📴 Connection lost - Now OFFLINE');
    }
  }

  /// Check current connectivity status
  Future<bool> checkConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    _updateConnectionStatus(result);
    return _isOnline;
  }
}
