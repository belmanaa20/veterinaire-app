import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/facture.dart';
import '../../models/ligne_facture.dart';
import '../../services/facture_service.dart';
import '../../services/pdf_service.dart';
import '../../config/app_constants.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_button.dart';

class FactureDetailsScreen extends StatefulWidget {
  final int factureId;

  const FactureDetailsScreen({super.key, required this.factureId});

  @override
  State<FactureDetailsScreen> createState() => _FactureDetailsScreenState();
}

class _FactureDetailsScreenState extends State<FactureDetailsScreen> {
  final FactureService _factureService = FactureService();
  final PdfService _pdfService = PdfService();
  final DateFormat _dateFormat = DateFormat(AppConstants.dateFormat);

  Facture? _facture;
  List<LigneFacture> _lignes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFacture();
  }

  Future<void> _loadFacture() async {
    setState(() => _isLoading = true);
    try {
      final facture = await _factureService.getFactureById(widget.factureId);
      if (facture != null) {
        setState(() {
          _facture = facture;
          _lignes = facture.lignes ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  Future<void> _printFacture() async {
    if (_facture == null) return;

    try {
      await _pdfService.printFacturePDF(_facture!);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur d\'impression: $e')),
        );
      }
    }
  }

  Future<void> _payFacture() async {
    if (_facture == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer le paiement'),
        content: Text(
          'Enregistrer le paiement de ${_facture!.montantTotal.toStringAsFixed(2)} ${AppConstants.currency}?',
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
        await _factureService.enregistrerPaiement(_facture!.id);
        await _loadFacture();
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
        title: _facture?.numero ?? 'Facture',
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: _printFacture,
            tooltip: 'Imprimer',
          ),
          if (_facture != null && _facture!.statut != AppConstants.statutPayee)
            IconButton(
              icon: const Icon(Icons.payment),
              onPressed: _payFacture,
              tooltip: 'Enregistrer paiement',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _facture == null
              ? const Center(child: Text('Facture introuvable'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Facture info card
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _facture!.numero,
                                    style: Theme.of(context).textTheme.headlineMedium,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatutColor().withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: _getStatutColor()),
                                    ),
                                    child: Text(
                                      _facture!.statut,
                                      style: TextStyle(
                                        color: _getStatutColor(),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 24),
                              Text(
                                'Informations client',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 12),
                              _buildInfoRow('Nom', _facture!.client?.nom ?? 'N/A'),
                              if (_facture!.client?.adresse != null)
                                _buildInfoRow('Adresse', _facture!.client!.adresse!),
                              if (_facture!.client?.telephone != null)
                                _buildInfoRow('Téléphone', _facture!.client!.telephone!),
                              if (_facture!.client?.culture != null)
                                _buildInfoRow('Culture', _facture!.client!.culture!),
                              const Divider(height: 24),
                              Text(
                                'Informations facture',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 12),
                              _buildInfoRow(
                                'Date facture',
                                _dateFormat.format(_facture!.dateFacture),
                              ),
                              _buildInfoRow(
                                'Date échéance',
                                _dateFormat.format(_facture!.dateEcheance),
                              ),
                              if (_facture!.datePaiement != null)
                                _buildInfoRow(
                                  'Date paiement',
                                  _dateFormat.format(_facture!.datePaiement!),
                                ),
                              _buildInfoRow(
                                'Jours restants',
                                _facture!.joursRestants.toString(),
                              ),
                              if (_facture!.procheEcheance || _facture!.estEnRetard) ...[
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: _facture!.estEnRetard
                                        ? Colors.red.shade50
                                        : Colors.orange.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: _facture!.estEnRetard
                                          ? Colors.red
                                          : Colors.orange,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.warning,
                                        color: _facture!.estEnRetard
                                            ? Colors.red
                                            : Colors.orange,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          _facture!.estEnRetard
                                              ? 'Cette facture est en retard!'
                                              : 'Cette facture est proche de l\'échéance (${_facture!.joursRestants} jours)',
                                          style: TextStyle(
                                            color: _facture!.estEnRetard
                                                ? Colors.red
                                                : Colors.orange,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Products table
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Produits',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(
                            '${_lignes.length} article(s)',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (_lignes.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: Text('Aucun produit'),
                          ),
                        )
                      else
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('N°')),
                              DataColumn(label: Text('DÉSIGNATION')),
                              DataColumn(label: Text('DATE AJOUT')),
                              DataColumn(label: Text('QTÉ')),
                              DataColumn(label: Text('P.U')),
                              DataColumn(label: Text('MONTANT')),
                            ],
                            rows: _lignes.asMap().entries.map((entry) {
                              final index = entry.key + 1;
                              final ligne = entry.value;
                              return DataRow(
                                cells: [
                                  DataCell(Text(index.toString())),
                                  DataCell(
                                    Text(ligne.produitDesignation ?? 'N/A'),
                                  ),
                                  DataCell(
                                    Text(_dateFormat.format(ligne.dateAjout)),
                                  ),
                                  DataCell(
                                    Text(ligne.quantite.toStringAsFixed(2)),
                                  ),
                                  DataCell(
                                    Text(
                                      '${ligne.prixUnitaire.toStringAsFixed(2)} DA',
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      '${ligne.montant.toStringAsFixed(2)} DA',
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      const SizedBox(height: 24),
                      // Total
                      Card(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'TOTAL',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Text(
                                '${_facture!.montantTotal.toStringAsFixed(2)} ${AppConstants.currency}',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      color: Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Actions
                      Row(
                        children: [
                          Expanded(
                            child: CustomButton(
                              text: 'Imprimer',
                              icon: Icons.print,
                              onPressed: _printFacture,
                            ),
                          ),
                          if (_facture!.statut != AppConstants.statutPayee) ...[
                            const SizedBox(width: 12),
                            Expanded(
                              child: CustomButton(
                                text: 'Enregistrer paiement',
                                icon: Icons.payment,
                                onPressed: _payFacture,
                                backgroundColor: Colors.green,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
    );
  }

  Color _getStatutColor() {
    if (_facture == null) return Colors.grey;
    
    switch (_facture!.statut) {
      case AppConstants.statutOuverte:
        return Colors.blue;
      case AppConstants.statutFermee:
        return Colors.orange;
      case AppConstants.statutPayee:
        return Colors.green;
      default:
        return Colors.red;
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(value),
        ],
      ),
    );
  }
}
