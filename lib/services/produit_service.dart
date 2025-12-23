import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/produit.dart';
import 'supabase_service.dart';

class ProduitService {
  final SupabaseClient _supabase = SupabaseService.client;

  /// Get all products
  Future<List<Produit>> getAllProduits() async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.tableProduits)
          .select()
          .order('designation', ascending: true);
      
      return (response as List)
          .map((e) => Produit.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting products: $e');
      rethrow;
    }
  }

  /// Get product by ID
  Future<Produit?> getProduitById(int id) async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.tableProduits)
          .select()
          .eq('id', id)
          .single();
      
      return Produit.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      print('Error getting product by ID: $e');
      return null;
    }
  }

  /// Get product by barcode
  Future<Produit?> getProduitByBarcode(String barcode) async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.tableProduits)
          .select()
          .eq('barcode', barcode)
          .single();
      
      return Produit.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      print('Error getting product by barcode: $e');
      return null;
    }
  }

  /// Search products
  Future<List<Produit>> searchProduits(String query) async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.tableProduits)
          .select()
          .or('designation.ilike.%$query%,code.ilike.%$query%,barcode.ilike.%$query%')
          .order('designation', ascending: true);
      
      return (response as List)
          .map((e) => Produit.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error searching products: $e');
      rethrow;
    }
  }

  /// Get products with low stock
  Future<List<Produit>> getProduitsStockFaible() async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.viewProduitsStockFaible)
          .select();
      
      return (response as List)
          .map((e) => Produit.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting low stock products: $e');
      rethrow;
    }
  }

  /// Create a new product
  Future<Produit> createProduit(Produit produit) async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.tableProduits)
          .insert(produit.toInsert())
          .select()
          .single();
      
      return Produit.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      print('Error creating product: $e');
      rethrow;
    }
  }

  /// Update an existing product
  Future<Produit> updateProduit(int id, Produit produit) async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.tableProduits)
          .update(produit.toInsert())
          .eq('id', id)
          .select()
          .single();
      
      return Produit.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      print('Error updating product: $e');
      rethrow;
    }
  }

  /// Delete a product
  Future<void> deleteProduit(int id) async {
    try {
      await _supabase
          .from(SupabaseConfig.tableProduits)
          .delete()
          .eq('id', id);
    } catch (e) {
      print('Error deleting product: $e');
      rethrow;
    }
  }

  /// Update product stock
  Future<void> updateStock(int id, double newStock) async {
    try {
      await _supabase
          .from(SupabaseConfig.tableProduits)
          .update({'stock': newStock})
          .eq('id', id);
    } catch (e) {
      print('Error updating stock: $e');
      rethrow;
    }
  }

  /// Get products by category
  Future<List<Produit>> getProduitsByCategorie(String categorie) async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.tableProduits)
          .select()
          .eq('categorie', categorie)
          .order('designation', ascending: true);
      
      return (response as List)
          .map((e) => Produit.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting products by category: $e');
      rethrow;
    }
  }
}
