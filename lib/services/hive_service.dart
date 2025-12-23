import 'package:hive_flutter/hive_flutter.dart';
import '../models/client.dart';
import '../models/produit.dart';
import '../models/facture.dart';
import '../models/ligne_facture.dart';
import '../models/parametres.dart';

class HiveService {
  static const String clientBoxName = 'clients';
  static const String produitBoxName = 'produits';
  static const String factureBoxName = 'factures';
  static const String ligneFactureBoxName = 'lignes_facture';
  static const String parametresBoxName = 'parametres';
  static const String syncQueueBoxName = 'sync_queue';
  static const String metadataBoxName = 'metadata';

  /// Initialize Hive and open boxes
  static Future<void> initialize() async {
    try {
      // Initialize Hive for Flutter
      await Hive.initFlutter();

      // Open all boxes (no type adapters needed for Map storage)
      await Future.wait([
        Hive.openBox(clientBoxName),
        Hive.openBox(produitBoxName),
        Hive.openBox(factureBoxName),
        Hive.openBox(ligneFactureBoxName),
        Hive.openBox(parametresBoxName),
        Hive.openBox(syncQueueBoxName),
        Hive.openBox(metadataBoxName),
      ]);

      print('✅ Hive initialized successfully');
    } catch (e) {
      print('❌ Error initializing Hive: $e');
      rethrow;
    }
  }

  /// Get a box by name
  static Box getBox(String boxName) {
    return Hive.box(boxName);
  }

  /// Get clients box
  static Box get clientBox => Hive.box(clientBoxName);

  /// Get produits box
  static Box get produitBox => Hive.box(produitBoxName);

  /// Get factures box
  static Box get factureBox => Hive.box(factureBoxName);

  /// Get lignes facture box
  static Box get ligneFactureBox => Hive.box(ligneFactureBoxName);

  /// Get parametres box
  static Box get parametresBox => Hive.box(parametresBoxName);

  /// Get sync queue box
  static Box get syncQueueBox => Hive.box(syncQueueBoxName);

  /// Get metadata box (for last sync timestamp, etc.)
  static Box get metadataBox => Hive.box(metadataBoxName);

  /// Clear all cached data
  static Future<void> clearAll() async {
    await Future.wait([
      clientBox.clear(),
      produitBox.clear(),
      factureBox.clear(),
      ligneFactureBox.clear(),
      parametresBox.clear(),
      syncQueueBox.clear(),
    ]);
  }

  /// Get last sync timestamp
  static DateTime? getLastSyncTime() {
    final timestamp = metadataBox.get('last_sync_time');
    return timestamp != null ? DateTime.parse(timestamp as String) : null;
  }

  /// Set last sync timestamp
  static Future<void> setLastSyncTime(DateTime time) async {
    await metadataBox.put('last_sync_time', time.toIso8601String());
  }

  /// Check if app is in offline mode
  static bool isOfflineMode() {
    return metadataBox.get('offline_mode', defaultValue: false) as bool;
  }

  /// Set offline mode
  static Future<void> setOfflineMode(bool offline) async {
    await metadataBox.put('offline_mode', offline);
  }
}
