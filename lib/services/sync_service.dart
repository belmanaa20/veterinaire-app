import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'cache_service.dart';
import 'connectivity_service.dart';
import 'supabase_service.dart';

class SyncService {
  final SupabaseClient _supabase = SupabaseService.client;
  Timer? _periodicSyncTimer;
  
  // ═══════════════════════════════════════
  // Queue de synchronisation
  // ═══════════════════════════════════════
  
  /// Ajouter une opération à la queue
  static Future<void> addToQueue(
    String table, 
    String action, // 'insert', 'update', 'delete'
    Map<String, dynamic> data,
  ) async {
    final box = CacheService.syncQueueBox;
    
    final queueItem = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'table': table,
      'action': action,
      'data': data,
      'created_at': DateTime.now().toIso8601String(),
      'attempts': 0,
    };
    
    final queue = box.get('queue', defaultValue: []);
    queue.add(queueItem);
    await box.put('queue', queue);
  }
  
  /// Obtenir le nombre d'opérations en attente
  static int getPendingCount() {
    final box = CacheService.syncQueueBox;
    final queue = box.get('queue', defaultValue: []);
    return queue.length;
  }
  
  // ═══════════════════════════════════════
  // Synchronisation
  // ═══════════════════════════════════════
  
  /// Synchroniser les clients
  Future<void> syncClients() async {
    if (!await ConnectivityService.isOnline()) return;
    
    try {
      // Récupérer de Supabase
      final response = await _supabase.from('clients').select();
      
      // Sauvegarder dans Hive
      await CacheService.saveList('clients', 'all', List<Map<String, dynamic>>.from(response));
      
      print('✅ Clients synchronized (${response.length} items)');
      
    } catch (e) {
      print('❌ Sync clients error: $e');
    }
  }
  
  /// Synchroniser les produits
  Future<void> syncProduits() async {
    if (!await ConnectivityService.isOnline()) return;
    
    try {
      final response = await _supabase.from('produits').select();
      await CacheService.saveList('produits', 'all', List<Map<String, dynamic>>.from(response));
      print('✅ Produits synchronized (${response.length} items)');
    } catch (e) {
      print('❌ Sync produits error: $e');
    }
  }
  
  /// Synchroniser les factures (dernières 90 jours)
  Future<void> syncFactures() async {
    if (!await ConnectivityService.isOnline()) return;
    
    try {
      final date90DaysAgo = DateTime.now().subtract(const Duration(days: 90));
      
      final response = await _supabase
          .from('v_factures_complet')
          .select()
          .gte('date_facture', date90DaysAgo.toIso8601String())
          .order('date_facture', ascending: false);
      
      await CacheService.saveList('factures', 'recent', List<Map<String, dynamic>>.from(response));
      print('✅ Factures synchronized (${response.length} items)');
    } catch (e) {
      print('❌ Sync factures error: $e');
    }
  }
  
  /// Traiter la queue de synchronisation
  Future<void> processSyncQueue() async {
    if (!await ConnectivityService.isOnline()) return;
    
    final box = CacheService.syncQueueBox;
    final queue = List<Map<String, dynamic>>.from(box.get('queue', defaultValue: []));
    
    if (queue.isEmpty) return;
    
    print('🔄 Processing sync queue (${queue.length} items)...');
    
    final List<Map<String, dynamic>> remainingQueue = [];
    
    for (var item in queue) {
      try {
        final table = item['table'];
        final action = item['action'];
        final data = Map<String, dynamic>.from(item['data']);
        
        // Supprimer les champs temporaires
        data.remove('_pending');
        data.remove('_temp_id');
        
        switch (action) {
          case 'insert':
            await _supabase.from(table).insert(data);
            break;
          case 'update':
            await _supabase.from(table).update(data).eq('id', data['id']);
            break;
          case 'delete':
            await _supabase.from(table).delete().eq('id', data['id']);
            break;
        }
        
        print('✅ Synced: $action on $table');
        
      } catch (e) {
        print('❌ Sync failed for item: $e');
        
        // Incrémenter le compteur de tentatives
        item['attempts'] = (item['attempts'] ?? 0) + 1;
        
        // Si moins de 5 tentatives, garder dans la queue
        if (item['attempts'] < 5) {
          remainingQueue.add(item);
        } else {
          print('⚠️ Item abandonné après 5 tentatives');
        }
      }
    }
    
    // Mettre à jour la queue
    await box.put('queue', remainingQueue);
    
    if (remainingQueue.isEmpty) {
      print('✅ Sync queue vide!');
    } else {
      print('⚠️ ${remainingQueue.length} items restent dans la queue');
    }
  }
  
  /// Synchronisation complète
  Future<void> syncAll() async {
    if (!await ConnectivityService.isOnline()) {
      print('📴 Offline - sync annulé');
      return;
    }
    
    print('🔄 Synchronisation complète...');
    
    await processSyncQueue(); // D'abord envoyer les modifications locales
    await syncClients();
    await syncProduits();
    await syncFactures();
    
    print('✅ Synchronisation terminée!');
  }
  
  // ═══════════════════════════════════════
  // Synchronisation automatique
  // ═══════════════════════════════════════
  
  /// Écouter les changements de connexion
  void startListeningToConnectivity() {
    ConnectivityService.startListening();
    
    ConnectivityService.connectionStatusStream.listen((isOnline) {
      if (isOnline) {
        print('🌐 Connexion restaurée - synchronisation...');
        syncAll();
      } else {
        print('📴 Hors ligne');
      }
    });
  }
  
  /// Synchronisation périodique (toutes les 5 minutes)
  void startPeriodicSync({Duration interval = const Duration(minutes: 5)}) {
    _periodicSyncTimer?.cancel();
    
    _periodicSyncTimer = Timer.periodic(interval, (timer) async {
      if (await ConnectivityService.isOnline()) {
        await syncAll();
      }
    });
  }
  
  void stopPeriodicSync() {
    _periodicSyncTimer?.cancel();
  }
}
