import 'package:flutter/material.dart';
import '../../models/produit.dart';
import '../../services/produit_service.dart';
import '../../services/label_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/produit_card.dart';
import 'produit_form_screen.dart';
import 'print_labels_screen.dart';

class ProduitsListScreen extends StatefulWidget {
  const ProduitsListScreen({super.key});

  @override
  State<ProduitsListScreen> createState() => _ProduitsListScreenState();
}

class _ProduitsListScreenState extends State<ProduitsListScreen> {
  final ProduitService _produitService = ProduitService();
  final LabelService _labelService = LabelService();
  List<Produit> _produits = [];
  List<Produit> _filteredProduits = [];
  bool _isLoading = true;
  String _searchQuery = '';
  bool _showStockFaibleOnly = false;

  @override
  void initState() {
    super.initState();
    _loadProduits();
  }

  Future<void> _loadProduits() async {
    setState(() => _isLoading = true);
    try {
      final produits = await _produitService.getAllProduits();
      setState(() {
        _produits = produits;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  void _applyFilters() {
    var filtered = _produits;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final queryLower = _searchQuery.toLowerCase();
      filtered = filtered.where((produit) {
        return produit.designation.toLowerCase().contains(queryLower) ||
            produit.code.toLowerCase().contains(queryLower) ||
            produit.barcode.toLowerCase().contains(queryLower);
      }).toList();
    }

    // Apply stock faible filter
    if (_showStockFaibleOnly) {
      filtered = filtered.where((p) => p.isStockFaible).toList();
    }

    setState(() {
      _filteredProduits = filtered;
    });
  }

  void _filterProduits(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void _toggleStockFaibleFilter() {
    setState(() {
      _showStockFaibleOnly = !_showStockFaibleOnly;
      _applyFilters();
    });
  }

  Future<void> _deleteProduit(Produit produit) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content:
            Text('Êtes-vous sûr de vouloir supprimer ${produit.designation}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _produitService.deleteProduit(produit.id);
        _loadProduits();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Produit supprimé')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: $e')),
          );
        }
      }
    }
  }

  Future<void> _printLabel(Produit produit) async {
    final copies = await showDialog<int>(
      context: context,
      builder: (context) => _PrintLabelDialog(),
    );

    if (copies != null && copies > 0) {
      try {
        await _labelService.printLabel(produit, copies: copies);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$copies étiquette(s) envoyée(s) à l\'impression')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Produits',
        actions: [
          IconButton(
            icon: Icon(
              _showStockFaibleOnly ? Icons.filter_alt : Icons.filter_alt_outlined,
              color: _showStockFaibleOnly ? Colors.red : null,
            ),
            onPressed: _toggleStockFaibleFilter,
            tooltip: 'Stock faible uniquement',
          ),
          IconButton(
            icon: const Icon(Icons.label),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PrintLabelsScreen(),
                ),
              );
            },
            tooltip: 'Impression d\'étiquettes',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProduitFormScreen(),
                ),
              );
              if (result == true) {
                _loadProduits();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Rechercher par nom, code ou barcode...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: _filterProduits,
            ),
          ),
          // Filter info
          if (_showStockFaibleOnly)
            Container(
              color: Colors.red.shade50,
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  const Icon(Icons.filter_alt, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Stock faible uniquement',
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _toggleStockFaibleFilter,
                    child: const Text('Effacer'),
                  ),
                ],
              ),
            ),
          // List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredProduits.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _searchQuery.isEmpty
                                  ? Icons.inventory_outlined
                                  : Icons.search_off,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'Aucun produit'
                                  : 'Aucun résultat',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'Ajoutez votre premier produit'
                                  : 'Essayez une autre recherche',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            if (_searchQuery.isEmpty) ...[
                              const SizedBox(height: 24),
                              CustomButton(
                                text: 'Ajouter un produit',
                                icon: Icons.add,
                                onPressed: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ProduitFormScreen(),
                                    ),
                                  );
                                  if (result == true) {
                                    _loadProduits();
                                  }
                                },
                              ),
                            ],
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredProduits.length,
                        itemBuilder: (context, index) {
                          final produit = _filteredProduits[index];
                          return ProduitCard(
                            produit: produit,
                            onEdit: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ProduitFormScreen(produit: produit),
                                ),
                              );
                              if (result == true) {
                                _loadProduits();
                              }
                            },
                            onDelete: () => _deleteProduit(produit),
                            onPrintLabel: () => _printLabel(produit),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _PrintLabelDialog extends StatefulWidget {
  @override
  State<_PrintLabelDialog> createState() => _PrintLabelDialogState();
}

class _PrintLabelDialogState extends State<_PrintLabelDialog> {
  int _copies = 1;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Imprimer étiquette'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Nombre de copies:'),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: _copies > 1
                    ? () => setState(() => _copies--)
                    : null,
                icon: const Icon(Icons.remove_circle_outline),
              ),
              Container(
                width: 60,
                alignment: Alignment.center,
                child: Text(
                  _copies.toString(),
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _copies++),
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _copies),
          child: const Text('Imprimer'),
        ),
      ],
    );
  }
}
