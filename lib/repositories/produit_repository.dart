import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/produit.dart';
import '../services/hive_service.dart';
import '../services/supabase_service.dart';
import '../utils/connectivity_monitor.dart';

class ProduitRepository {
  final SupabaseClient _supabase = SupabaseService.client;
  final _connectivityMonitor = ConnectivityMonitor();

  /// Get all products (online first, fallback to cache)
  Future<List<Produit>> getAllProduits() async {
    try {
      if (_connectivityMonitor.isOnline) {
        final response = await _supabase
            .from(SupabaseConfig.tableProduits)
            .select()
            .order('designation', ascending: true);

        final produits = (response as List)
            .map((e) => Produit.fromJson(e as Map<String, dynamic>))
            .toList();

        // Cache in Hive
        await _cacheProduits(produits);

        return produits;
      } else {
        return _getProduitsFromCache();
      }
    } catch (e) {
      print('Error getting products from API: $e');
      return _getProduitsFromCache();
    }
  }

  /// Get product by ID
  Future<Produit?> getProduitById(int id) async {
    try {
      if (_connectivityMonitor.isOnline) {
        final response = await _supabase
            .from(SupabaseConfig.tableProduits)
            .select()
            .eq('id', id)
            .single();

        final produit = Produit.fromJson(response as Map<String, dynamic>);
        await HiveService.produitBox.put(id, produit.toJson());
        return produit;
      } else {
        final cached = HiveService.produitBox.get(id);
        return cached != null ? Produit.fromJson(Map<String, dynamic>.from(cached)) : null;
      }
    } catch (e) {
      print('Error getting product by ID: $e');
      final cached = HiveService.produitBox.get(id);
      return cached != null ? Produit.fromJson(Map<String, dynamic>.from(cached)) : null;
    }
  }

  /// Get product by barcode
  Future<Produit?> getProduitByBarcode(String barcode) async {
    try {
      if (_connectivityMonitor.isOnline) {
        final response = await _supabase
            .from(SupabaseConfig.tableProduits)
            .select()
            .eq('barcode', barcode)
            .single();

        final produit = Produit.fromJson(response as Map<String, dynamic>);
        await HiveService.produitBox.put(produit.id, produit.toJson());
        return produit;
      } else {
        // Search in cache
        final allProduits = _getProduitsFromCache();
        return allProduits.firstWhere(
          (p) => p.barcode == barcode,
          orElse: () => throw Exception('Product not found in cache'),
        );
      }
    } catch (e) {
      print('Error getting product by barcode: $e');
      return null;
    }
  }

  /// Search products
  Future<List<Produit>> searchProduits(String query) async {
    try {
      if (_connectivityMonitor.isOnline) {
        final response = await _supabase
            .from(SupabaseConfig.tableProduits)
            .select()
            .or('designation.ilike.%$query%,code.ilike.%$query%,barcode.ilike.%$query%')
            .order('designation', ascending: true);

        return (response as List)
            .map((e) => Produit.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        final allProduits = _getProduitsFromCache();
        final lowerQuery = query.toLowerCase();
        return allProduits.where((produit) {
          return produit.designation.toLowerCase().contains(lowerQuery) ||
              produit.code.toLowerCase().contains(lowerQuery) ||
              produit.barcode.toLowerCase().contains(lowerQuery);
        }).toList();
      }
    } catch (e) {
      print('Error searching products: $e');
      return [];
    }
  }

  /// Get products with low stock
  Future<List<Produit>> getProduitsStockFaible() async {
    try {
      if (_connectivityMonitor.isOnline) {
        final response = await _supabase
            .from(SupabaseConfig.viewProduitsStockFaible)
            .select();

        return (response as List)
            .map((e) => Produit.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        final allProduits = _getProduitsFromCache();
        return allProduits.where((p) => p.isStockFaible).toList();
      }
    } catch (e) {
      print('Error getting low stock products: $e');
      return [];
    }
  }

  /// Create a new product
  Future<Produit?> createProduit(Produit produit) async {
    try {
      if (_connectivityMonitor.isOnline) {
        final response = await _supabase
            .from(SupabaseConfig.tableProduits)
            .insert(produit.toInsert())
            .select()
            .single();

        final newProduit = Produit.fromJson(response as Map<String, dynamic>);
        await HiveService.produitBox.put(newProduit.id, newProduit.toJson());
        return newProduit;
      } else {
        final tempId = DateTime.now().millisecondsSinceEpoch;
        final tempProduit = produit.copyWith(id: tempId);
        await HiveService.produitBox.put(tempId, tempProduit.toJson());
        await _addToSyncQueue('create', tempProduit.toInsert());
        return tempProduit;
      }
    } catch (e) {
      print('Error creating product: $e');
      return null;
    }
  }

  /// Update a product
  Future<Produit?> updateProduit(int id, Produit produit) async {
    try {
      if (_connectivityMonitor.isOnline) {
        final response = await _supabase
            .from(SupabaseConfig.tableProduits)
            .update(produit.toInsert())
            .eq('id', id)
            .select()
            .single();

        final updatedProduit = Produit.fromJson(response as Map<String, dynamic>);
        await HiveService.produitBox.put(id, updatedProduit.toJson());
        return updatedProduit;
      } else {
        await HiveService.produitBox.put(id, produit.toJson());
        await _addToSyncQueue('update', {'id': id, ...produit.toInsert()});
        return produit;
      }
    } catch (e) {
      print('Error updating product: $e');
      return null;
    }
  }

  /// Delete a product
  Future<bool> deleteProduit(int id) async {
    try {
      if (_connectivityMonitor.isOnline) {
        await _supabase
            .from(SupabaseConfig.tableProduits)
            .delete()
            .eq('id', id);

        await HiveService.produitBox.delete(id);
        return true;
      } else {
        await HiveService.produitBox.delete(id);
        await _addToSyncQueue('delete', {'id': id});
        return true;
      }
    } catch (e) {
      print('Error deleting product: $e');
      return false;
    }
  }

  /// Update product stock
  Future<void> updateStock(int id, double newStock) async {
    try {
      if (_connectivityMonitor.isOnline) {
        await _supabase
            .from(SupabaseConfig.tableProduits)
            .update({'stock': newStock})
            .eq('id', id);

        // Update cache
        final cached = HiveService.produitBox.get(id);
        if (cached != null) {
          final produit = Produit.fromJson(Map<String, dynamic>.from(cached));
          await HiveService.produitBox.put(id, produit.copyWith(stock: newStock).toJson());
        }
      } else {
        // Update cache only
        final cached = HiveService.produitBox.get(id);
        if (cached != null) {
          final produit = Produit.fromJson(Map<String, dynamic>.from(cached));
          await HiveService.produitBox.put(id, produit.copyWith(stock: newStock).toJson());
        }
        await _addToSyncQueue('update_stock', {'id': id, 'stock': newStock});
      }
    } catch (e) {
      print('Error updating stock: $e');
    }
  }

  /// Cache produits in Hive
  Future<void> _cacheProduits(List<Produit> produits) async {
    await HiveService.produitBox.clear();
    for (final produit in produits) {
      await HiveService.produitBox.put(produit.id, produit.toJson());
    }
  }

  /// Get produits from cache
  List<Produit> _getProduitsFromCache() {
    try {
      final cached = HiveService.produitBox.values.toList();
      return cached
          .map((e) => Produit.fromJson(Map<String, dynamic>.from(e)))
          .toList()
        ..sort((a, b) => a.designation.compareTo(b.designation));
    } catch (e) {
      print('Error getting products from cache: $e');
      return [];
    }
  }

  /// Add operation to sync queue
  Future<void> _addToSyncQueue(String operation, Map<String, dynamic> data) async {
    final queueItem = {
      'type': 'produit',
      'operation': operation,
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    final key = 'produit_${operation}_${DateTime.now().millisecondsSinceEpoch}';
    await HiveService.syncQueueBox.put(key, queueItem);
  }
}
