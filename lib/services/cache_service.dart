import 'package:hive_flutter/hive_flutter.dart';

class CacheService {
  // Boxes
  static Box get clientsBox => Hive.box('clients');
  static Box get produitsBox => Hive.box('produits');
  static Box get facturesBox => Hive.box('factures');
  static Box get parametresBox => Hive.box('parametres');
  static Box get syncQueueBox => Hive.box('sync_queue');
  static Box get settingsBox => Hive.box('app_settings');
  
  // ═══════════════════════════════════════
  // CRUD générique
  // ═══════════════════════════════════════
  
  /// Sauvegarder une liste d'entités
  static Future<void> saveList(String boxName, String key, List<Map<String, dynamic>> data) async {
    final box = Hive.box(boxName);
    await box.put(key, data);
    await box.put('${key}_last_sync', DateTime.now().toIso8601String());
  }
  
  /// Récupérer une liste
  static List<Map<String, dynamic>> getList(String boxName, String key) {
    final box = Hive.box(boxName);
    final data = box.get(key, defaultValue: []);
    return List<Map<String, dynamic>>.from(data);
  }
  
  /// Ajouter un élément à une liste
  static Future<void> addToList(String boxName, String key, Map<String, dynamic> item) async {
    final box = Hive.box(boxName);
    final list = getList(boxName, key);
    list.add(item);
    await box.put(key, list);
  }
  
  /// Mettre à jour un élément
  static Future<void> updateInList(
    String boxName, 
    String key, 
    int id, 
    Map<String, dynamic> updatedItem
  ) async {
    final box = Hive.box(boxName);
    final list = getList(boxName, key);
    final index = list.indexWhere((item) => item['id'] == id);
    
    if (index != -1) {
      list[index] = updatedItem;
      await box.put(key, list);
    }
  }
  
  /// Supprimer un élément
  static Future<void> deleteFromList(String boxName, String key, int id) async {
    final box = Hive.box(boxName);
    final list = getList(boxName, key);
    list.removeWhere((item) => item['id'] == id);
    await box.put(key, list);
  }
  
  /// Obtenir la date de dernière synchronisation
  static DateTime? getLastSyncTime(String boxName, String key) {
    final box = Hive.box(boxName);
    final dateStr = box.get('${key}_last_sync');
    return dateStr != null ? DateTime.parse(dateStr) : null;
  }
  
  /// Nettoyer tout le cache
  static Future<void> clearAll() async {
    await clientsBox.clear();
    await produitsBox.clear();
    await facturesBox.clear();
    await parametresBox.clear();
    // Ne PAS vider sync_queue (contient les opérations en attente)
  }
  
  /// Obtenir la taille du cache (en MB)
  static Future<double> getCacheSize() async {
    // Calculer approximativement
    int totalItems = 0;
    totalItems += clientsBox.length;
    totalItems += produitsBox.length;
    totalItems += facturesBox.length;
    
    // Estimation: ~1KB par item
    return (totalItems * 1024) / (1024 * 1024); // MB
  }
}
