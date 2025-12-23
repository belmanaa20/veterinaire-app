import 'package:flutter/material.dart';
import '../services/connectivity_service.dart';
import '../services/sync_service.dart';

class ConnectionStatusWidget extends StatefulWidget {
  final bool showPendingCount;
  
  const ConnectionStatusWidget({
    super.key,
    this.showPendingCount = true,
  });

  @override
  State<ConnectionStatusWidget> createState() => _ConnectionStatusWidgetState();
}

class _ConnectionStatusWidgetState extends State<ConnectionStatusWidget> {
  bool _isOnline = true;
  
  @override
  void initState() {
    super.initState();
    _checkConnection();
    
    // Écouter les changements
    ConnectivityService.connectionStatusStream.listen((online) {
      if (mounted) {
        setState(() {
          _isOnline = online;
        });
      }
    });
  }
  
  Future<void> _checkConnection() async {
    final online = await ConnectivityService.isOnline();
    if (mounted) {
      setState(() {
        _isOnline = online;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final pendingCount = SyncService.getPendingCount();
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Indicateur Online/Offline
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _isOnline ? Colors.green : Colors.orange,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _isOnline ? Icons.cloud_done : Icons.cloud_off,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                _isOnline ? 'En ligne' : 'Hors ligne',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        
        // Nombre d'opérations en attente
        if (widget.showPendingCount && pendingCount > 0) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.sync,
                  color: Colors.white,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  '$pendingCount en attente',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
