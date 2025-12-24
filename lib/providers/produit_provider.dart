import 'package:flutter/foundation.dart';
import '../models/produit.dart';
import '../services/produit_service.dart';

class ProduitProvider extends ChangeNotifier {
  final ProduitService _service = ProduitService();
  
  List<Produit> _produits = [];
  List<Produit> _produitsStockFaible = [];
  bool _isLoading = false;
  String? _error;
  
  List<Produit> get produits => _produits;
  List<Produit> get produitsStockFaible => _produitsStockFaible;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  Future<void> loadProduits() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _produits = await _service.getProduits();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> loadProduitsStockFaible() async {
    try {
      _produitsStockFaible = await _service.getProduitsStockFaible();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
  
  Future<void> addProduit(Produit produit) async {
    try {
      final newProduit = await _service.createProduit(produit);
      _produits.insert(0, newProduit);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
  
  Future<void> updateProduit(Produit produit) async {
    try {
      final updatedProduit = await _service.updateProduit(produit);
      final index = _produits.indexWhere((p) => p.id == produit.id);
      if (index != -1) {
        _produits[index] = updatedProduit;
      }
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
  
  Future<void> deleteProduit(int id) async {
    try {
      await _service.deleteProduit(id);
      _produits.removeWhere((p) => p.id == id);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
  
  Future<void> searchProduits(String query) async {
    if (query.isEmpty) {
      await loadProduits();
      return;
    }
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _produits = await _service.searchProduits(query);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
