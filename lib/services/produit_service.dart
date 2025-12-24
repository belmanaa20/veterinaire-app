import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/produit.dart';

class ProduitService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Produit>> getProduits() async {
    try {
      final data = await _supabase
          .from('produits')
          .select()
          .order('created_at', ascending: false);
      return (data as List).map((e) => Produit.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des produits: $e');
    }
  }

  Future<List<Produit>> getProduitsActifs() async {
    try {
      final data = await _supabase
          .from('produits')
          .select()
          .eq('actif', true)
          .order('designation');
      return (data as List).map((e) => Produit.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des produits actifs: $e');
    }
  }

  Future<List<Produit>> getProduitsStockFaible() async {
    try {
      final data = await _supabase
          .from('v_produits_stock_faible')
          .select();
      return (data as List).map((e) => Produit.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des produits en stock faible: $e');
    }
  }

  Future<Produit> getProduitById(int id) async {
    try {
      final data = await _supabase
          .from('produits')
          .select()
          .eq('id', id)
          .single();
      return Produit.fromJson(data);
    } catch (e) {
      throw Exception('Erreur lors de la récupération du produit: $e');
    }
  }

  Future<Produit?> getProduitByBarcode(String barcode) async {
    try {
      final data = await _supabase
          .from('produits')
          .select()
          .eq('code_barre', barcode)
          .maybeSingle();
      return data != null ? Produit.fromJson(data) : null;
    } catch (e) {
      throw Exception('Erreur lors de la récupération du produit par code-barres: $e');
    }
  }

  Future<Produit> createProduit(Produit produit) async {
    try {
      final data = await _supabase
          .from('produits')
          .insert(produit.toJson())
          .select()
          .single();
      return Produit.fromJson(data);
    } catch (e) {
      throw Exception('Erreur lors de la création du produit: $e');
    }
  }

  Future<Produit> updateProduit(Produit produit) async {
    try {
      final data = await _supabase
          .from('produits')
          .update(produit.toJson())
          .eq('id', produit.id!)
          .select()
          .single();
      return Produit.fromJson(data);
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du produit: $e');
    }
  }

  Future<void> deleteProduit(int id) async {
    try {
      await _supabase.from('produits').delete().eq('id', id);
    } catch (e) {
      throw Exception('Erreur lors de la suppression du produit: $e');
    }
  }

  Future<List<Produit>> searchProduits(String query) async {
    try {
      final data = await _supabase
          .from('produits')
          .select()
          .or('designation.ilike.%$query%,code_barre.ilike.%$query%,categorie.ilike.%$query%')
          .order('designation');
      return (data as List).map((e) => Produit.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Erreur lors de la recherche des produits: $e');
    }
  }
}
