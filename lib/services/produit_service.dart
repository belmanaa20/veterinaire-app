import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/produit.dart';
import 'supabase_service.dart';
import 'cache_service.dart';
import 'connectivity_service.dart';
import 'sync_service.dart';

class ProduitService {
  final SupabaseClient _supabase = SupabaseService.client;

  /// Get all products (Hive first, then Supabase)
  Future<List<Produit>> getAllProduits({bool forceRefresh = false}) async {
    try {
      // 1. Essayer Hive (rapide)
      if (!forceRefresh) {
        final cachedData = CacheService.getList('produits', 'all');
        if (cachedData.isNotEmpty) {
          print('💾 Produits from Hive cache (${cachedData.length} items)');
          return cachedData.map((e) => Produit.fromJson(e)).toList();
        }
      }
      
      // 2. Si Online, récupérer de Supabase
      if (await ConnectivityService.isOnline()) {
        try {
          final response = await _supabase
              .from(SupabaseConfig.tableProduits)
              .select()
              .order('designation', ascending: true);
          
          // Sauvegarder dans Hive
          await CacheService.saveList('produits', 'all', List<Map<String, dynamic>>.from(response));
          
          print('✅ Produits from Supabase + cached');
          return (response as List)
              .map((e) => Produit.fromJson(e as Map<String, dynamic>))
              .toList();
          
        } catch (e) {
          print('⚠️ Supabase error, using cache: $e');
        }
      }
      
      // 3. Fallback: Hive
      final cachedData = CacheService.getList('produits', 'all');
      return cachedData.map((e) => Produit.fromJson(e)).toList();
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

  /// Create a new product (Online/Offline)
  Future<Produit> createProduit(Produit produit) async {
    try {
      if (await ConnectivityService.isOnline()) {
        try {
          // Online: Supabase
          final response = await _supabase
              .from(SupabaseConfig.tableProduits)
              .insert(produit.toInsert())
              .select()
              .single();
          
          // Mettre à jour Hive
          await CacheService.addToList('produits', 'all', response as Map<String, dynamic>);
          
          return Produit.fromJson(response as Map<String, dynamic>);
        } catch (e) {
          print('⚠️ Erreur Supabase, sauvegarde offline: $e');
          // Tomber dans le mode offline
        }
      }
      
      // Offline: Hive uniquement
      final tempId = DateTime.now().millisecondsSinceEpoch;
      final produitData = {
        ...produit.toJson(),
        'id': tempId,
        '_pending': true,
        '_temp_id': tempId,
      };
      
      await CacheService.addToList('produits', 'all', produitData);
      await SyncService.addToQueue('produits', 'insert', produitData);
      
      print('💾 Produit sauvegardé offline (sera synchronisé)');
      
      return produit.copyWith(id: tempId);
    } catch (e) {
      print('Error creating product: $e');
      rethrow;
    }
  }

  /// Update an existing product (Online/Offline)
  Future<Produit> updateProduit(int id, Produit produit) async {
    try {
      if (await ConnectivityService.isOnline()) {
        try {
          // Online: Supabase
          final response = await _supabase
              .from(SupabaseConfig.tableProduits)
              .update(produit.toInsert())
              .eq('id', id)
              .select()
              .single();
          
          // Mettre à jour Hive
          await CacheService.updateInList('produits', 'all', id, response as Map<String, dynamic>);
          
          return Produit.fromJson(response as Map<String, dynamic>);
        } catch (e) {
          print('⚠️ Erreur Supabase, sauvegarde offline: $e');
          // Tomber dans le mode offline
        }
      }
      
      // Offline: Hive uniquement
      final produitData = {
        ...produit.toJson(),
        'id': id,
        '_pending': true,
      };
      
      await CacheService.updateInList('produits', 'all', id, produitData);
      await SyncService.addToQueue('produits', 'update', produitData);
      
      print('💾 Produit mis à jour offline (sera synchronisé)');
      
      return produit;
    } catch (e) {
      print('Error updating product: $e');
      rethrow;
    }
  }

  /// Delete a product (Online/Offline)
  Future<void> deleteProduit(int id) async {
    try {
      if (await ConnectivityService.isOnline()) {
        try {
          // Online: Supabase
          await _supabase
              .from(SupabaseConfig.tableProduits)
              .delete()
              .eq('id', id);
          
          // Supprimer de Hive
          await CacheService.deleteFromList('produits', 'all', id);
          
          return;
        } catch (e) {
          print('⚠️ Erreur Supabase, sauvegarde offline: $e');
          // Tomber dans le mode offline
        }
      }
      
      // Offline: Marquer pour suppression
      await CacheService.deleteFromList('produits', 'all', id);
      await SyncService.addToQueue('produits', 'delete', {'id': id});
      
      print('💾 Produit marqué pour suppression (sera synchronisé)');
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
