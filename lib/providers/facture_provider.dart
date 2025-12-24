import 'package:flutter/foundation.dart';
import '../models/facture.dart';
import '../models/ligne_facture.dart';
import '../services/facture_service.dart';

class FactureProvider extends ChangeNotifier {
  final FactureService _service = FactureService();
  
  List<Facture> _factures = [];
  List<LigneFacture> _lignesFacture = [];
  Facture? _currentFacture;
  bool _isLoading = false;
  String? _error;
  
  List<Facture> get factures => _factures;
  List<LigneFacture> get lignesFacture => _lignesFacture;
  Facture? get currentFacture => _currentFacture;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  Future<void> loadFactures() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _factures = await _service.getFactures();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<int> creerFacture(int clientId, DateTime date) async {
    try {
      final factureId = await _service.creerFacture(clientId, date);
      await loadFactures();
      _error = null;
      return factureId;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
  
  Future<void> loadLignesFacture(int factureId) async {
    try {
      _lignesFacture = await _service.getLignesFacture(factureId);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
  
  Future<void> ajouterLigne(
    int factureId,
    int produitId,
    double quantite,
    double prixUnitaire,
    double remise,
  ) async {
    try {
      await _service.ajouterLigne(
        factureId,
        produitId,
        quantite,
        prixUnitaire,
        remise,
      );
      await loadLignesFacture(factureId);
      await loadFactureById(factureId);
      _error = null;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
  
  Future<void> supprimerLigne(int ligneId, int factureId) async {
    try {
      await _service.supprimerLigne(ligneId);
      await loadLignesFacture(factureId);
      await loadFactureById(factureId);
      _error = null;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
  
  Future<void> fermerFacture(int factureId) async {
    try {
      await _service.fermerFacture(factureId);
      await loadFactures();
      _error = null;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
  
  Future<void> enregistrerPaiement(
    int factureId,
    double montant,
    String modePaiement,
  ) async {
    try {
      await _service.enregistrerPaiement(factureId, montant, modePaiement);
      await loadFactures();
      _error = null;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
  
  Future<void> annulerFacture(int factureId) async {
    try {
      await _service.annulerFacture(factureId);
      await loadFactures();
      _error = null;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
  
  Future<void> loadFactureById(int factureId) async {
    try {
      _currentFacture = await _service.getFactureById(factureId);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
  
  void clearCurrentFacture() {
    _currentFacture = null;
    _lignesFacture = [];
    notifyListeners();
  }
}
