import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/facture.dart';
import '../models/ligne_facture.dart';

class FactureService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<int> creerFacture(int clientId, DateTime date) async {
    try {
      final response = await _supabase.rpc('creer_facture', params: {
        'p_client_id': clientId,
        'p_date_facture': date.toIso8601String(),
      });
      return response as int;
    } catch (e) {
      throw Exception('Erreur lors de la création de la facture: $e');
    }
  }

  Future<int> ajouterLigne(
    int factureId,
    int produitId,
    double quantite,
    double prixUnitaire,
    double remise,
  ) async {
    try {
      final response = await _supabase.rpc('ajouter_ligne_facture', params: {
        'p_facture_id': factureId,
        'p_produit_id': produitId,
        'p_quantite': quantite,
        'p_prix_unitaire': prixUnitaire,
        'p_remise': remise,
      });
      return response as int;
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout de la ligne: $e');
    }
  }

  Future<int> ajouterLigneByBarcode(
    int factureId,
    String codeBarre,
    double quantite,
  ) async {
    try {
      final response = await _supabase.rpc('ajouter_ligne_by_barcode', params: {
        'p_facture_id': factureId,
        'p_code_barre': codeBarre,
        'p_quantite': quantite,
      });
      return response as int;
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout de la ligne par code-barres: $e');
    }
  }

  Future<void> recalculerFacture(int factureId) async {
    try {
      await _supabase.rpc('recalculer_facture', params: {
        'p_facture_id': factureId,
      });
    } catch (e) {
      throw Exception('Erreur lors du recalcul de la facture: $e');
    }
  }

  Future<void> fermerFacture(int factureId) async {
    try {
      await _supabase.rpc('fermer_facture', params: {
        'p_facture_id': factureId,
      });
    } catch (e) {
      throw Exception('Erreur lors de la fermeture de la facture: $e');
    }
  }

  Future<void> enregistrerPaiement(
    int factureId,
    double montant,
    String modePaiement,
  ) async {
    try {
      await _supabase.rpc('enregistrer_paiement', params: {
        'p_facture_id': factureId,
        'p_montant': montant,
        'p_mode_paiement': modePaiement,
      });
    } catch (e) {
      throw Exception('Erreur lors de l\'enregistrement du paiement: $e');
    }
  }

  Future<List<Facture>> getFactures() async {
    try {
      final data = await _supabase
          .from('v_factures_complet')
          .select()
          .order('date_facture', ascending: false);
      return (data as List).map((e) => Facture.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des factures: $e');
    }
  }

  Future<Facture> getFactureById(int id) async {
    try {
      final data = await _supabase
          .from('v_factures_complet')
          .select()
          .eq('id', id)
          .single();
      return Facture.fromJson(data);
    } catch (e) {
      throw Exception('Erreur lors de la récupération de la facture: $e');
    }
  }

  Future<List<LigneFacture>> getLignesFacture(int factureId) async {
    try {
      final data = await _supabase
          .from('lignes_facture')
          .select()
          .eq('facture_id', factureId)
          .order('created_at');
      return (data as List).map((e) => LigneFacture.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des lignes de facture: $e');
    }
  }

  Future<void> supprimerLigne(int ligneId) async {
    try {
      await _supabase.from('lignes_facture').delete().eq('id', ligneId);
    } catch (e) {
      throw Exception('Erreur lors de la suppression de la ligne: $e');
    }
  }

  Future<void> annulerFacture(int factureId) async {
    try {
      await _supabase
          .from('factures')
          .update({'statut': 'annulee'})
          .eq('id', factureId);
    } catch (e) {
      throw Exception('Erreur lors de l\'annulation de la facture: $e');
    }
  }

  Future<List<Facture>> getFacturesByClient(int clientId) async {
    try {
      final data = await _supabase
          .from('v_factures_complet')
          .select()
          .eq('client_id', clientId)
          .order('date_facture', ascending: false);
      return (data as List).map((e) => Facture.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des factures du client: $e');
    }
  }

  Future<List<Facture>> getFacturesANotifier() async {
    try {
      final data = await _supabase
          .from('v_factures_a_notifier')
          .select();
      return (data as List).map((e) => Facture.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des factures à notifier: $e');
    }
  }
}
