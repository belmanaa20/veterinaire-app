import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/client.dart';
import '../services/hive_service.dart';
import '../services/supabase_service.dart';
import '../utils/connectivity_monitor.dart';

class ClientRepository {
  final SupabaseClient _supabase = SupabaseService.client;
  final _connectivityMonitor = ConnectivityMonitor();

  /// Get all clients (online first, fallback to cache)
  Future<List<Client>> getAllClients() async {
    try {
      if (_connectivityMonitor.isOnline) {
        // Try to fetch from API
        final response = await _supabase
            .from(SupabaseConfig.tableClients)
            .select()
            .order('nom', ascending: true);

        final clients = (response as List)
            .map((e) => Client.fromJson(e as Map<String, dynamic>))
            .toList();

        // Cache in Hive
        await _cacheClients(clients);

        return clients;
      } else {
        // Offline: return from cache
        return _getClientsFromCache();
      }
    } catch (e) {
      print('Error getting clients from API: $e');
      // Fallback to cache
      return _getClientsFromCache();
    }
  }

  /// Get client by ID (online first, fallback to cache)
  Future<Client?> getClientById(int id) async {
    try {
      if (_connectivityMonitor.isOnline) {
        final response = await _supabase
            .from(SupabaseConfig.tableClients)
            .select()
            .eq('id', id)
            .single();

        final client = Client.fromJson(response as Map<String, dynamic>);

        // Cache in Hive
        await HiveService.clientBox.put(id, client.toJson());

        return client;
      } else {
        // Offline: return from cache
        final cached = HiveService.clientBox.get(id);
        return cached != null ? Client.fromJson(Map<String, dynamic>.from(cached)) : null;
      }
    } catch (e) {
      print('Error getting client by ID: $e');
      // Fallback to cache
      final cached = HiveService.clientBox.get(id);
      return cached != null ? Client.fromJson(Map<String, dynamic>.from(cached)) : null;
    }
  }

  /// Create a new client (sync when online, queue when offline)
  Future<Client?> createClient(Client client) async {
    try {
      if (_connectivityMonitor.isOnline) {
        final response = await _supabase
            .from(SupabaseConfig.tableClients)
            .insert(client.toInsert())
            .select()
            .single();

        final newClient = Client.fromJson(response as Map<String, dynamic>);

        // Cache in Hive
        await HiveService.clientBox.put(newClient.id, newClient.toJson());

        return newClient;
      } else {
        // Offline: queue for sync
        final tempId = DateTime.now().millisecondsSinceEpoch;
        final tempClient = client.copyWith(id: tempId);
        
        // Store in cache with temp ID
        await HiveService.clientBox.put(tempId, tempClient.toJson());
        
        // Add to sync queue
        await _addToSyncQueue('create', tempClient.toInsert());
        
        return tempClient;
      }
    } catch (e) {
      print('Error creating client: $e');
      return null;
    }
  }

  /// Update a client (sync when online, queue when offline)
  Future<Client?> updateClient(int id, Client client) async {
    try {
      if (_connectivityMonitor.isOnline) {
        final response = await _supabase
            .from(SupabaseConfig.tableClients)
            .update(client.toInsert())
            .eq('id', id)
            .select()
            .single();

        final updatedClient = Client.fromJson(response as Map<String, dynamic>);

        // Update cache
        await HiveService.clientBox.put(id, updatedClient.toJson());

        return updatedClient;
      } else {
        // Offline: queue for sync
        await HiveService.clientBox.put(id, client.toJson());
        await _addToSyncQueue('update', {'id': id, ...client.toInsert()});
        
        return client;
      }
    } catch (e) {
      print('Error updating client: $e');
      return null;
    }
  }

  /// Delete a client (sync when online, queue when offline)
  Future<bool> deleteClient(int id) async {
    try {
      if (_connectivityMonitor.isOnline) {
        await _supabase
            .from(SupabaseConfig.tableClients)
            .delete()
            .eq('id', id);

        // Remove from cache
        await HiveService.clientBox.delete(id);

        return true;
      } else {
        // Offline: queue for sync
        await HiveService.clientBox.delete(id);
        await _addToSyncQueue('delete', {'id': id});
        
        return true;
      }
    } catch (e) {
      print('Error deleting client: $e');
      return false;
    }
  }

  /// Search clients (online first, fallback to cache)
  Future<List<Client>> searchClients(String query) async {
    try {
      if (_connectivityMonitor.isOnline) {
        final response = await _supabase
            .from(SupabaseConfig.tableClients)
            .select()
            .or('nom.ilike.%$query%,telephone.ilike.%$query%,culture.ilike.%$query%')
            .order('nom', ascending: true);

        return (response as List)
            .map((e) => Client.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        // Offline: search in cache
        final allClients = _getClientsFromCache();
        final lowerQuery = query.toLowerCase();
        return allClients.where((client) {
          return client.nom.toLowerCase().contains(lowerQuery) ||
              (client.telephone?.toLowerCase().contains(lowerQuery) ?? false) ||
              (client.culture?.toLowerCase().contains(lowerQuery) ?? false);
        }).toList();
      }
    } catch (e) {
      print('Error searching clients: $e');
      return [];
    }
  }

  /// Cache clients in Hive
  Future<void> _cacheClients(List<Client> clients) async {
    await HiveService.clientBox.clear();
    for (final client in clients) {
      await HiveService.clientBox.put(client.id, client.toJson());
    }
  }

  /// Get clients from cache
  List<Client> _getClientsFromCache() {
    try {
      final cached = HiveService.clientBox.values.toList();
      return cached
          .map((e) => Client.fromJson(Map<String, dynamic>.from(e)))
          .toList()
        ..sort((a, b) => a.nom.compareTo(b.nom));
    } catch (e) {
      print('Error getting clients from cache: $e');
      return [];
    }
  }

  /// Add operation to sync queue
  Future<void> _addToSyncQueue(String operation, Map<String, dynamic> data) async {
    final queueItem = {
      'type': 'client',
      'operation': operation,
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    final key = 'client_${operation}_${DateTime.now().millisecondsSinceEpoch}';
    await HiveService.syncQueueBox.put(key, queueItem);
  }
}
