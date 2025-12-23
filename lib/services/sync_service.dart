import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../services/hive_service.dart';
import '../services/supabase_service.dart';
import '../utils/connectivity_monitor.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final SupabaseClient _supabase = SupabaseService.client;
  final _connectivityMonitor = ConnectivityMonitor();
  
  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;

  /// Initialize sync service and start listening to connectivity
  void initialize() {
    _connectivityMonitor.onlineStream.listen((isOnline) {
      if (isOnline && !_isSyncing) {
        // Auto-sync when connection is restored
        syncAll();
      }
    });
  }

  /// Sync all pending changes to the server
  Future<void> syncAll() async {
    if (_isSyncing || !_connectivityMonitor.isOnline) {
      return;
    }

    _isSyncing = true;
    print('🔄 Starting sync...');

    try {
      await _syncClients();
      await _syncProduits();
      await _syncFactures();

      // Update last sync time
      await HiveService.setLastSyncTime(DateTime.now());
      
      print('✅ Sync completed successfully');
    } catch (e) {
      print('❌ Sync failed: $e');
    } finally {
      _isSyncing = false;
    }
  }

  /// Sync client changes
  Future<void> _syncClients() async {
    final syncQueue = HiveService.syncQueueBox;
    final clientItems = syncQueue.keys
        .where((key) => key.toString().startsWith('client_'))
        .toList();

    for (final key in clientItems) {
      try {
        final item = syncQueue.get(key) as Map;
        final operation = item['operation'] as String;
        final data = Map<String, dynamic>.from(item['data'] as Map);

        switch (operation) {
          case 'create':
            await _supabase
                .from(SupabaseConfig.tableClients)
                .insert(data);
            break;
          case 'update':
            final id = data.remove('id');
            await _supabase
                .from(SupabaseConfig.tableClients)
                .update(data)
                .eq('id', id);
            break;
          case 'delete':
            await _supabase
                .from(SupabaseConfig.tableClients)
                .delete()
                .eq('id', data['id']);
            break;
        }

        // Remove from sync queue after successful sync
        await syncQueue.delete(key);
        print('✓ Synced client: $operation');
      } catch (e) {
        print('✗ Failed to sync client $key: $e');
        // Keep in queue for retry
      }
    }
  }

  /// Sync product changes
  Future<void> _syncProduits() async {
    final syncQueue = HiveService.syncQueueBox;
    final produitItems = syncQueue.keys
        .where((key) => key.toString().startsWith('produit_'))
        .toList();

    for (final key in produitItems) {
      try {
        final item = syncQueue.get(key) as Map;
        final operation = item['operation'] as String;
        final data = Map<String, dynamic>.from(item['data'] as Map);

        switch (operation) {
          case 'create':
            await _supabase
                .from(SupabaseConfig.tableProduits)
                .insert(data);
            break;
          case 'update':
            final id = data.remove('id');
            await _supabase
                .from(SupabaseConfig.tableProduits)
                .update(data)
                .eq('id', id);
            break;
          case 'update_stock':
            await _supabase
                .from(SupabaseConfig.tableProduits)
                .update({'stock': data['stock']})
                .eq('id', data['id']);
            break;
          case 'delete':
            await _supabase
                .from(SupabaseConfig.tableProduits)
                .delete()
                .eq('id', data['id']);
            break;
        }

        await syncQueue.delete(key);
        print('✓ Synced produit: $operation');
      } catch (e) {
        print('✗ Failed to sync produit $key: $e');
      }
    }
  }

  /// Sync facture changes
  Future<void> _syncFactures() async {
    final syncQueue = HiveService.syncQueueBox;
    final factureItems = syncQueue.keys
        .where((key) => key.toString().startsWith('facture_'))
        .toList();

    for (final key in factureItems) {
      try {
        final item = syncQueue.get(key) as Map;
        final operation = item['operation'] as String;
        final data = Map<String, dynamic>.from(item['data'] as Map);

        switch (operation) {
          case 'create':
            // Use RPC function for facture creation
            await _supabase.rpc('creer_facture', params: data);
            break;
          case 'update':
            final id = data.remove('id');
            await _supabase
                .from(SupabaseConfig.tableFactures)
                .update(data)
                .eq('id', id);
            break;
          case 'delete':
            await _supabase
                .from(SupabaseConfig.tableFactures)
                .delete()
                .eq('id', data['id']);
            break;
          case 'add_ligne':
            await _supabase.rpc('ajouter_ligne_facture', params: data);
            break;
          case 'fermer':
            await _supabase.rpc('fermer_facture', params: data);
            break;
          case 'paiement':
            await _supabase.rpc('enregistrer_paiement', params: data);
            break;
        }

        await syncQueue.delete(key);
        print('✓ Synced facture: $operation');
      } catch (e) {
        print('✗ Failed to sync facture $key: $e');
      }
    }
  }

  /// Get pending sync count
  int getPendingSyncCount() {
    return HiveService.syncQueueBox.length;
  }

  /// Clear sync queue (for testing/debugging)
  Future<void> clearSyncQueue() async {
    await HiveService.syncQueueBox.clear();
  }
}
