import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/client.dart';

class ClientService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Client>> getClients() async {
    try {
      final data = await _supabase
          .from('clients')
          .select()
          .order('created_at', ascending: false);
      return (data as List).map((e) => Client.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des clients: $e');
    }
  }

  Future<Client> getClientById(int id) async {
    try {
      final data = await _supabase
          .from('clients')
          .select()
          .eq('id', id)
          .single();
      return Client.fromJson(data);
    } catch (e) {
      throw Exception('Erreur lors de la récupération du client: $e');
    }
  }

  Future<Client> createClient(Client client) async {
    try {
      final data = await _supabase
          .from('clients')
          .insert(client.toJson())
          .select()
          .single();
      return Client.fromJson(data);
    } catch (e) {
      throw Exception('Erreur lors de la création du client: $e');
    }
  }

  Future<Client> updateClient(Client client) async {
    try {
      final data = await _supabase
          .from('clients')
          .update(client.toJson())
          .eq('id', client.id!)
          .select()
          .single();
      return Client.fromJson(data);
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du client: $e');
    }
  }

  Future<void> deleteClient(int id) async {
    try {
      await _supabase.from('clients').delete().eq('id', id);
    } catch (e) {
      throw Exception('Erreur lors de la suppression du client: $e');
    }
  }

  Future<List<Client>> searchClients(String query) async {
    try {
      final data = await _supabase
          .from('clients')
          .select()
          .or('nom.ilike.%$query%,prenom.ilike.%$query%,nom_animal.ilike.%$query%')
          .order('created_at', ascending: false);
      return (data as List).map((e) => Client.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Erreur lors de la recherche des clients: $e');
    }
  }
}
