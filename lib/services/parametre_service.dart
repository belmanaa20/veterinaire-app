import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/parametre.dart';

class ParametreService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<Parametre> getParametres() async {
    try {
      final data = await _supabase
          .from('parametres')
          .select()
          .limit(1)
          .single();
      return Parametre.fromJson(data);
    } catch (e) {
      throw Exception('Erreur lors de la récupération des paramètres: $e');
    }
  }

  Future<Parametre> updateParametres(Parametre parametre) async {
    try {
      final data = await _supabase
          .from('parametres')
          .update(parametre.toJson())
          .eq('id', parametre.id)
          .select()
          .single();
      return Parametre.fromJson(data);
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour des paramètres: $e');
    }
  }
}
