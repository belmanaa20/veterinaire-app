import 'package:flutter/foundation.dart';
import '../models/parametre.dart';
import '../services/parametre_service.dart';

class ParametreProvider extends ChangeNotifier {
  final ParametreService _service = ParametreService();
  
  Parametre? _parametres;
  bool _isLoading = false;
  String? _error;
  
  Parametre? get parametres => _parametres;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  Future<void> loadParametres() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _parametres = await _service.getParametres();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> updateParametres(Parametre parametre) async {
    try {
      _parametres = await _service.updateParametres(parametre);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}
