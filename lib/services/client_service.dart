import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/client.dart';
import 'supabase_service.dart';

class ClientService {
  final SupabaseClient _supabase = SupabaseService.client;

  /// Get all clients
  Future<List<Client>> getAllClients() async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.tableClients)
          .select()
          .order('nom', ascending: true);
      
      return (response as List)
          .map((e) => Client.fromJson(e as Map<String, dynamic>))
          .toList();
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

  /// Create a new client
  Future<Client> createClient(Client client) async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.tableClients)
          .insert(client.toInsert())
          .select()
          .single();
      
      return Client.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      print('Error creating client: $e');
      rethrow;
    }
  }

  /// Update an existing client
  Future<Client> updateClient(int id, Client client) async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.tableClients)
          .update(client.toInsert())
          .eq('id', id)
          .select()
          .single();
      
      return Client.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      print('Error updating client: $e');
      rethrow;
    }
  }

  /// Delete a client
  Future<void> deleteClient(int id) async {
    try {
      await _supabase
          .from(SupabaseConfig.tableClients)
          .delete()
          .eq('id', id);
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
