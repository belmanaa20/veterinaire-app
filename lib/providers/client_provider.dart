import 'package:flutter/foundation.dart';
import '../models/client.dart';
import '../services/client_service.dart';

class ClientProvider extends ChangeNotifier {
  final ClientService _service = ClientService();
  
  List<Client> _clients = [];
  bool _isLoading = false;
  String? _error;
  
  List<Client> get clients => _clients;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  Future<void> loadClients() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _clients = await _service.getClients();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> addClient(Client client) async {
    try {
      final newClient = await _service.createClient(client);
      _clients.insert(0, newClient);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
  
  Future<void> updateClient(Client client) async {
    try {
      final updatedClient = await _service.updateClient(client);
      final index = _clients.indexWhere((c) => c.id == client.id);
      if (index != -1) {
        _clients[index] = updatedClient;
      }
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
  
  Future<void> deleteClient(int id) async {
    try {
      await _service.deleteClient(id);
      _clients.removeWhere((c) => c.id == id);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
  
  Future<void> searchClients(String query) async {
    if (query.isEmpty) {
      await loadClients();
      return;
    }
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _clients = await _service.searchClients(query);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
