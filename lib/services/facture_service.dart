import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../config/app_constants.dart';
import '../models/facture.dart';
import '../models/ligne_facture.dart';
import 'supabase_service.dart';

class FactureService {
  final SupabaseClient _supabase = SupabaseService.client;

  /// Create a new facture using RPC function
  Future<int> creerFacture({
    required int clientId,
    String? numero,
    int delaiJours = AppConstants.defaultDelaiJours,
  }) async {
    try {
      final response = await _supabase.rpc(
        SupabaseConfig.rpcCreerFacture,
        params: {
          'p_client_id': clientId,
          'p_numero': numero,
          'p_delai_jours': delaiJours,
        },
      );
      return response as int;
    } catch (e) {
      print('Error creating facture: $e');
      rethrow;
    }
  }

  /// Add a line to facture using RPC
  Future<void> ajouterLigneFacture({
    required int factureId,
    required int produitId,
    required double quantite,
    required double prix,
  }) async {
    try {
      await _supabase.rpc(
        SupabaseConfig.rpcAjouterLigneFacture,
        params: {
          'p_facture_id': factureId,
          'p_produit_id': produitId,
          'p_quantite': quantite,
          'p_prix': prix,
        },
      );
    } catch (e) {
      print('Error adding ligne facture: $e');
      rethrow;
    }
  }

  /// Add a line to facture by barcode using RPC
  Future<void> ajouterLigneByBarcode({
    required int factureId,
    required String barcode,
    required double quantite,
  }) async {
    try {
      await _supabase.rpc(
        SupabaseConfig.rpcAjouterLigneByBarcode,
        params: {
          'p_facture_id': factureId,
          'p_barcode': barcode,
          'p_quantite': quantite,
        },
      );
    } catch (e) {
      print('Error adding ligne by barcode: $e');
      rethrow;
    }
  }

  /// Recalculate facture total using RPC
  Future<void> recalculerFacture(int factureId) async {
    try {
      await _supabase.rpc(
        SupabaseConfig.rpcRecalculerFacture,
        params: {'p_facture_id': factureId},
      );
    } catch (e) {
      print('Error recalculating facture: $e');
      rethrow;
    }
  }

  /// Close facture using RPC
  Future<void> fermerFacture(int factureId) async {
    try {
      await _supabase.rpc(
        SupabaseConfig.rpcFermerFacture,
        params: {'p_facture_id': factureId},
      );
    } catch (e) {
      print('Error closing facture: $e');
      rethrow;
    }
  }

  /// Record payment using RPC
  Future<void> enregistrerPaiement(int factureId) async {
    try {
      await _supabase.rpc(
        SupabaseConfig.rpcEnregistrerPaiement,
        params: {'p_facture_id': factureId},
      );
    } catch (e) {
      print('Error recording payment: $e');
      rethrow;
    }
  }

  /// Get all factures with complete information from view
  Future<List<Facture>> getFacturesComplet() async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.viewFacturesComplet)
          .select()
          .order('date_facture', ascending: false);
      
      return (response as List)
          .map((e) => Facture.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting factures complet: $e');
      rethrow;
    }
  }

  /// Get facture by ID with complete information
  Future<Facture?> getFactureById(int id) async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.viewFacturesComplet)
          .select()
          .eq('id', id)
          .single();
      
      final facture = Facture.fromJson(response as Map<String, dynamic>);
      
      // Load lines separately
      final lignesResponse = await _supabase
          .from(SupabaseConfig.tableLignesFacture)
          .select('''
            *,
            produit:produit_id (
              code,
              designation
            )
          ''')
          .eq('facture_id', id)
          .order('date_ajout', ascending: true);
      
      final lignes = (lignesResponse as List).map((e) {
        final ligne = LigneFacture.fromJson(e as Map<String, dynamic>);
        if (e['produit'] != null) {
          final produit = e['produit'] as Map<String, dynamic>;
          ligne.produitCode = produit['code'] as String?;
          ligne.produitDesignation = produit['designation'] as String?;
        }
        return ligne;
      }).toList();
      
      return facture.copyWith(lignes: lignes);
    } catch (e) {
      print('Error getting facture by ID: $e');
      return null;
    }
  }

  /// Get factures to notify (due soon)
  Future<List<Facture>> getFacturesANotifier() async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.viewFacturesANotifier)
          .select();
      
      return (response as List)
          .map((e) => Facture.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting factures to notify: $e');
      rethrow;
    }
  }

  /// Get factures by status
  Future<List<Facture>> getFacturesByStatut(String statut) async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.viewFacturesComplet)
          .select()
          .eq('statut', statut)
          .order('date_facture', ascending: false);
      
      return (response as List)
          .map((e) => Facture.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting factures by statut: $e');
      rethrow;
    }
  }

  /// Get factures by client
  Future<List<Facture>> getFacturesByClient(int clientId) async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.viewFacturesComplet)
          .select()
          .eq('client_id', clientId)
          .order('date_facture', ascending: false);
      
      return (response as List)
          .map((e) => Facture.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting factures by client: $e');
      rethrow;
    }
  }

  /// Delete a facture line
  Future<void> deleteLigneFacture(int ligneId, int factureId) async {
    try {
      await _supabase
          .from(SupabaseConfig.tableLignesFacture)
          .delete()
          .eq('id', ligneId);
      
      // Recalculate total
      await recalculerFacture(factureId);
    } catch (e) {
      print('Error deleting ligne facture: $e');
      rethrow;
    }
  }

  /// Get lines for a specific facture
  Future<List<LigneFacture>> getLignesFacture(int factureId) async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.tableLignesFacture)
          .select('''
            *,
            produit:produit_id (
              code,
              designation
            )
          ''')
          .eq('facture_id', factureId)
          .order('date_ajout', ascending: true);
      
      return (response as List).map((e) {
        final ligne = LigneFacture.fromJson(e as Map<String, dynamic>);
        if (e['produit'] != null) {
          final produit = e['produit'] as Map<String, dynamic>;
          ligne.produitCode = produit['code'] as String?;
          ligne.produitDesignation = produit['designation'] as String?;
        }
        return ligne;
      }).toList();
    } catch (e) {
      print('Error getting lignes facture: $e');
      rethrow;
    }
  }
}
