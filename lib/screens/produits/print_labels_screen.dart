import 'package:flutter/material.dart';
import '../../models/produit.dart';
import '../../services/produit_service.dart';
import '../../services/label_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_button.dart';

class PrintLabelsScreen extends StatefulWidget {
  const PrintLabelsScreen({super.key});

  @override
  State<PrintLabelsScreen> createState() => _PrintLabelsScreenState();
}

class _PrintLabelsScreenState extends State<PrintLabelsScreen> {
  final ProduitService _produitService = ProduitService();
  final LabelService _labelService = LabelService();
  List<Produit> _produits = [];
  final Set<int> _selectedProduits = {};
  bool _isLoading = true;

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

  Future<void> _printSelected() async {
    if (_selectedProduits.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sélectionnez au moins un produit')),
      );
      return;
    }

    try {
      final selectedProducts = _produits
          .where((p) => _selectedProduits.contains(p.id))
          .toList();
      
      await _labelService.printMultipleLabels(selectedProducts);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${selectedProducts.length} étiquette(s) envoyée(s) à l\'impression'),
          ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Impression d\'étiquettes',
        actions: [
          if (_selectedProduits.isNotEmpty)
            TextButton(
              onPressed: () {
                setState(() => _selectedProduits.clear());
              },
              child: const Text('Tout déselectionner'),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Info banner
                Container(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Sélectionnez les produits pour lesquels vous souhaitez imprimer des étiquettes (80×50mm)',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Selected count
                if (_selectedProduits.isNotEmpty)
                  Container(
                    color: Colors.green.shade50,
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green),
                        const SizedBox(width: 8),
                        Text(
                          '${_selectedProduits.length} produit(s) sélectionné(s)',
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                // Products list
                Expanded(
                  child: _produits.isEmpty
                      ? const Center(
                          child: Text('Aucun produit disponible'),
                        )
                      : ListView.builder(
                          itemCount: _produits.length,
                          itemBuilder: (context, index) {
                            final produit = _produits[index];
                            final isSelected = _selectedProduits.contains(produit.id);
                            
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                                  : null,
                              child: CheckboxListTile(
                                value: isSelected,
                                onChanged: (value) {
                                  setState(() {
                                    if (value == true) {
                                      _selectedProduits.add(produit.id);
                                    } else {
                                      _selectedProduits.remove(produit.id);
                                    }
                                  });
                                },
                                title: Text(produit.designation),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Code: ${produit.code}'),
                                    Text('Barcode: ${produit.barcode}'),
                                    Text('Prix: ${produit.prixUnitaire.toStringAsFixed(2)} DA'),
                                  ],
                                ),
                                secondary: const Icon(Icons.label),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      bottomNavigationBar: _selectedProduits.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: CustomButton(
                text: 'Imprimer ${_selectedProduits.length} étiquette(s)',
                icon: Icons.print,
                onPressed: _printSelected,
              ),
            ),
    );
  }
}
