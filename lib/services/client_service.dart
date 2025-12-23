import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/client.dart';
import 'supabase_service.dart';
import 'cache_service.dart';
import 'connectivity_service.dart';
import 'sync_service.dart';

class ClientService {
  final SupabaseClient _supabase = SupabaseService.client;

  /// Get all clients (Hive first, then Supabase)
  Future<List<Client>> getAllClients({bool forceRefresh = false}) async {
    try {
      // 1. Essayer Hive (rapide)
      if (!forceRefresh) {
        final cachedData = CacheService.getList('clients', 'all');
        if (cachedData.isNotEmpty) {
          print('💾 Clients from Hive cache (${cachedData.length} items)');
          return cachedData.map((e) => Client.fromJson(e)).toList();
        }
      }
      
      // 2. Si Online, récupérer de Supabase
      if (await ConnectivityService.isOnline()) {
        try {
          final response = await _supabase
              .from(SupabaseConfig.tableClients)
              .select()
              .order('nom', ascending: true);
          
          // Sauvegarder dans Hive
          await CacheService.saveList('clients', 'all', List<Map<String, dynamic>>.from(response));
          
          print('✅ Clients from Supabase + cached');
          return (response as List)
              .map((e) => Client.fromJson(e as Map<String, dynamic>))
              .toList();
          
        } catch (e) {
          print('⚠️ Supabase error, using cache: $e');
        }
      }
      
      // 3. Fallback: Hive
      final cachedData = CacheService.getList('clients', 'all');
      return cachedData.map((e) => Client.fromJson(e)).toList();
    } catch (e) {
      print('Error getting clients: $e');
      rethrow;
    }
  }

  /// Get client by ID
  Future<Client?> getClientById(int id) async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.tableClients)
          .select()
          .eq('id', id)
          .single();
      
      return Client.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      print('Error getting client by ID: $e');
      return null;
    }
  }

  /// Search clients by name or phone
  Future<List<Client>> searchClients(String query) async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.tableClients)
          .select()
          .or('nom.ilike.%$query%,telephone.ilike.%$query%')
          .order('nom', ascending: true);
      
      return (response as List)
          .map((e) => Client.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error searching clients: $e');
      rethrow;
    }
  }

  /// Create a new client (Online/Offline)
  Future<Client> createClient(Client client) async {
    try {
      if (await ConnectivityService.isOnline()) {
        try {
          // Online: Supabase
          final response = await _supabase
              .from(SupabaseConfig.tableClients)
              .insert(client.toInsert())
              .select()
              .single();
          
          // Mettre à jour Hive
          await CacheService.addToList('clients', 'all', response as Map<String, dynamic>);
          
          return Client.fromJson(response as Map<String, dynamic>);
          
        } catch (e) {
          print('⚠️ Erreur Supabase, sauvegarde offline: $e');
          // Tomber dans le mode offline
        }
      }
      
      // Offline: Hive uniquement
      final tempId = DateTime.now().millisecondsSinceEpoch;
      final clientData = {
        ...client.toJson(),
        'id': tempId,
        '_pending': true,
        '_temp_id': tempId,
      };
      
      await CacheService.addToList('clients', 'all', clientData);
      await SyncService.addToQueue('clients', 'insert', clientData);
      
      print('💾 Client sauvegardé offline (sera synchronisé)');
      
      return client.copyWith(id: tempId);
    } catch (e) {
      print('Error creating client: $e');
      rethrow;
    }
  }

  /// Update an existing client (Online/Offline)
  Future<Client> updateClient(int id, Client client) async {
    try {
      if (await ConnectivityService.isOnline()) {
        try {
          // Online: Supabase
          final response = await _supabase
              .from(SupabaseConfig.tableClients)
              .update(client.toInsert())
              .eq('id', id)
              .select()
              .single();
          
          // Mettre à jour Hive
          await CacheService.updateInList('clients', 'all', id, response as Map<String, dynamic>);
          
          return Client.fromJson(response as Map<String, dynamic>);
        } catch (e) {
          print('⚠️ Erreur Supabase, sauvegarde offline: $e');
          // Tomber dans le mode offline
        }
      }
      
      // Offline: Hive uniquement
      final clientData = {
        ...client.toJson(),
        'id': id,
        '_pending': true,
      };
      
      await CacheService.updateInList('clients', 'all', id, clientData);
      await SyncService.addToQueue('clients', 'update', clientData);
      
      print('💾 Client mis à jour offline (sera synchronisé)');
      
      return client;
    } catch (e) {
      print('Error updating client: $e');
      rethrow;
    }
  }

  /// Delete a client (Online/Offline)
  Future<void> deleteClient(int id) async {
    try {
      if (await ConnectivityService.isOnline()) {
        try {
          // Online: Supabase
          await _supabase
              .from(SupabaseConfig.tableClients)
              .delete()
              .eq('id', id);
          
          // Supprimer de Hive
          await CacheService.deleteFromList('clients', 'all', id);
          
          return;
        } catch (e) {
          print('⚠️ Erreur Supabase, sauvegarde offline: $e');
          // Tomber dans le mode offline
        }
      }
      
      // Offline: Marquer pour suppression
      await CacheService.deleteFromList('clients', 'all', id);
      await SyncService.addToQueue('clients', 'delete', {'id': id});
      
      print('💾 Client marqué pour suppression (sera synchronisé)');
    } catch (e) {
      print('Error deleting client: $e');
      rethrow;
    }
  }

  /// Get clients by culture type
  Future<List<Client>> getClientsByCulture(String culture) async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.tableClients)
          .select()
          .eq('culture', culture)
          .order('nom', ascending: true);
      
      return (response as List)
          .map((e) => Client.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting clients by culture: $e');
      rethrow;
    }
  }
}
