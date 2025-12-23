import 'package:flutter/material.dart';
import '../../models/facture.dart';
import '../../services/facture_service.dart';
import '../../services/pdf_service.dart';
import '../../config/app_constants.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/facture_card.dart';
import 'nouvelle_facture_screen.dart';
import 'facture_details_screen.dart';

class FacturesListScreen extends StatefulWidget {
  const FacturesListScreen({super.key});

  @override
  State<FacturesListScreen> createState() => _FacturesListScreenState();
}

class _FacturesListScreenState extends State<FacturesListScreen> {
  final FactureService _factureService = FactureService();
  final PdfService _pdfService = PdfService();
  List<Facture> _factures = [];
  List<Facture> _filteredFactures = [];
  bool _isLoading = true;
  String _selectedStatut = 'Tous';

  final List<String> _statutFilters = [
    'Tous',
    AppConstants.statutOuverte,
    AppConstants.statutFermee,
    AppConstants.statutPayee,
    AppConstants.statutEnRetard,
  ];

  @override
  void initState() {
    super.initState();
    _loadFactures();
  }

  Future<void> _loadFactures() async {
    setState(() => _isLoading = true);
    try {
      final factures = await _factureService.getFacturesComplet();
      setState(() {
        _factures = factures;
        _applyFilter();
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

  void _applyFilter() {
    if (_selectedStatut == 'Tous') {
      _filteredFactures = _factures;
    } else {
      _filteredFactures = _factures.where((f) => f.statut == _selectedStatut).toList();
    }
    setState(() {});
  }

  Future<void> _printFacture(Facture facture) async {
    try {
      await _pdfService.printFacturePDF(facture);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur d\'impression: $e')),
        );
      }
    }
  }

  Future<void> _payFacture(Facture facture) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer le paiement'),
        content: Text(
          'Enregistrer le paiement de ${facture.montantTotal.toStringAsFixed(2)} ${AppConstants.currency}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _factureService.enregistrerPaiement(facture.id);
        _loadFactures();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Paiement enregistré')),
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
        title: 'Factures',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFactures,
          ),
        ],
      ),
      body: Column(
        children: [
          // Status filter
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _statutFilters.length,
              itemBuilder: (context, index) {
                final statut = _statutFilters[index];
                final isSelected = statut == _selectedStatut;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(statut),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedStatut = statut;
                        _applyFilter();
                      });
                    },
                  ),
                );
              },
            ),
          ),
          // List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredFactures.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.receipt_long_outlined,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Aucune facture',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _selectedStatut == 'Tous'
                                  ? 'Créez votre première facture'
                                  : 'Aucune facture avec le statut "$_selectedStatut"',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadFactures,
                        child: ListView.builder(
                          itemCount: _filteredFactures.length,
                          itemBuilder: (context, index) {
                            final facture = _filteredFactures[index];
                            return FactureCard(
                              facture: facture,
                              onTap: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        FactureDetailsScreen(factureId: facture.id),
                                  ),
                                );
                                if (result == true) {
                                  _loadFactures();
                                }
                              },
                              onPrint: () => _printFacture(facture),
                              onPay: facture.statut != AppConstants.statutPayee
                                  ? () => _payFacture(facture)
                                  : null,
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NouvelleFactureScreen(),
            ),
          );
          if (result == true) {
            _loadFactures();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle Facture'),
      ),
    );
  }
}
