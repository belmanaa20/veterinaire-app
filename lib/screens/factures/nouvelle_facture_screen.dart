import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/client.dart';
import '../../models/produit.dart';
import '../../models/facture.dart';
import '../../models/ligne_facture.dart';
import '../../services/client_service.dart';
import '../../services/produit_service.dart';
import '../../services/facture_service.dart';
import '../../config/app_constants.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_button.dart';
import 'barcode_scanner_screen.dart';

class NouvelleFactureScreen extends StatefulWidget {
  final int? factureId;

  const NouvelleFactureScreen({super.key, this.factureId});

  @override
  State<NouvelleFactureScreen> createState() => _NouvelleFactureScreenState();
}

class _NouvelleFactureScreenState extends State<NouvelleFactureScreen> {
  final ClientService _clientService = ClientService();
  final ProduitService _produitService = ProduitService();
  final FactureService _factureService = FactureService();
  final DateFormat _dateFormat = DateFormat(AppConstants.dateFormat);

  List<Client> _clients = [];
  List<Produit> _produits = [];
  Client? _selectedClient;
  Facture? _facture;
  List<LigneFacture> _lignes = [];
  bool _isLoading = true;
  bool _isLoadingLignes = false;
  bool _isCreatingFacture = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final clients = await _clientService.getAllClients();
      final produits = await _produitService.getAllProduits();
      
      setState(() {
        _clients = clients;
        _produits = produits;
        _isLoading = false;
      });

      // If editing existing facture
      if (widget.factureId != null) {
        await _loadFacture(widget.factureId!);
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

  Future<void> _loadFacture(int factureId) async {
    try {
      final facture = await _factureService.getFactureById(factureId);
      if (facture != null) {
        setState(() {
          _facture = facture;
          _selectedClient = facture.client;
          _lignes = facture.lignes ?? [];
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  Future<void> _createFacture() async {
    if (_selectedClient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner un client')),
      );
      return;
    }

    setState(() => _isCreatingFacture = true);
    try {
      final factureId = await _factureService.creerFacture(
        clientId: _selectedClient!.id,
      );
      
      await _loadFacture(factureId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Facture créée')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    } finally {
      setState(() => _isCreatingFacture = false);
    }
  }

  Future<void> _ajouterProduit() async {
    if (_facture == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez d\'abord créer la facture')),
      );
      return;
    }

    Produit? selectedProduit;
    double? quantite;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _AjouterProduitDialog(produits: _produits),
    );

    if (result != null) {
      selectedProduit = result['produit'] as Produit;
      quantite = result['quantite'] as double;

      try {
        await _factureService.ajouterLigneFacture(
          factureId: _facture!.id,
          produitId: selectedProduit.id,
          quantite: quantite,
          prix: selectedProduit.prixUnitaire,
        );
        
        await _loadFacture(_facture!.id);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Produit ajouté')),
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

  Future<void> _scanBarcode() async {
    if (_facture == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez d\'abord créer la facture')),
      );
      return;
    }

    final barcode = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => const BarcodeScannerScreen(),
      ),
    );

    if (barcode != null) {
      final quantite = await showDialog<double>(
        context: context,
        builder: (context) => _QuantiteDialog(),
      );

      if (quantite != null) {
        try {
          await _factureService.ajouterLigneByBarcode(
            factureId: _facture!.id,
            barcode: barcode,
            quantite: quantite,
          );
          
          await _loadFacture(_facture!.id);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Produit ajouté par scan')),
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
  }

  Future<void> _supprimerLigne(LigneFacture ligne) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text('Êtes-vous sûr de vouloir supprimer ce produit?'),
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
        await _factureService.deleteLigneFacture(ligne.id, _facture!.id);
        await _loadFacture(_facture!.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ligne supprimée')),
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

  Future<void> _fermerFacture() async {
    if (_facture == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la fermeture'),
        content: const Text(
          'Êtes-vous sûr de vouloir fermer cette facture? Vous ne pourrez plus ajouter de produits.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _factureService.fermerFacture(_facture!.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Facture fermée')),
          );
          Navigator.pop(context, true);
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
        title: _facture == null ? 'Nouvelle Facture' : _facture!.numero,
        actions: [
          if (_facture != null && _facture!.estModifiable)
            IconButton(
              icon: const Icon(Icons.lock),
              onPressed: _fermerFacture,
              tooltip: 'Fermer la facture',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Client selection
                  if (_facture == null) ...[
                    Text(
                      'Sélectionner le client',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<Client>(
                      value: _selectedClient,
                      decoration: const InputDecoration(
                        labelText: 'Client *',
                        prefixIcon: Icon(Icons.person),
                      ),
                      items: _clients
                          .map((client) => DropdownMenuItem(
                                value: client,
                                child: Text(client.nom),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() => _selectedClient = value);
                      },
                    ),
                    const SizedBox(height: 24),
                    CustomButton(
                      text: 'Créer la facture',
                      icon: Icons.add_circle,
                      onPressed: _createFacture,
                      isLoading: _isCreatingFacture,
                    ),
                  ] else ...[
                    // Facture info
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
                                Chip(
                                  label: Text(_facture!.statut),
                                  backgroundColor: _facture!.estOuverte
                                      ? Colors.blue.shade100
                                      : Colors.grey.shade300,
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            _buildInfoRow('Client', _facture!.client?.nom ?? 'N/A'),
                            _buildInfoRow('Culture', _facture!.client?.culture ?? 'N/A'),
                            _buildInfoRow('Date facture', _dateFormat.format(_facture!.dateFacture)),
                            _buildInfoRow('Date échéance', _dateFormat.format(_facture!.dateEcheance)),
                            if (_facture!.procheEcheance || _facture!.estEnRetard) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: _facture!.estEnRetard
                                      ? Colors.red.shade50
                                      : Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.warning,
                                      color: _facture!.estEnRetard ? Colors.red : Colors.orange,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _facture!.estEnRetard
                                          ? 'Facture en retard!'
                                          : 'Proche de l\'échéance (${_facture!.joursRestants} jours)',
                                      style: TextStyle(
                                        color: _facture!.estEnRetard ? Colors.red : Colors.orange,
                                        fontWeight: FontWeight.bold,
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
                    // Actions
                    if (_facture!.estModifiable) ...[
                      Row(
                        children: [
                          Expanded(
                            child: CustomButton(
                              text: 'Ajouter produit',
                              icon: Icons.add,
                              onPressed: _ajouterProduit,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomButton(
                              text: 'Scanner',
                              icon: Icons.qr_code_scanner,
                              onPressed: _scanBarcode,
                              backgroundColor: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                    // Products table
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Produits (${_lignes.length})',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          'Total: ${_facture!.montantTotal.toStringAsFixed(2)} ${AppConstants.currency}',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_lignes.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            children: [
                              Icon(
                                Icons.shopping_cart_outlined,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Aucun produit',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: Colors.grey,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              const Text('Ajoutez des produits à cette facture'),
                            ],
                          ),
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
                            DataColumn(label: Text('Actions')),
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
                                  Text('${ligne.prixUnitaire.toStringAsFixed(2)} DA'),
                                ),
                                DataCell(
                                  Text('${ligne.montant.toStringAsFixed(2)} DA'),
                                ),
                                DataCell(
                                  _facture!.estModifiable
                                      ? IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.red),
                                          onPressed: () => _supprimerLigne(ligne),
                                        )
                                      : const SizedBox.shrink(),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                  ],
                ],
              ),
            ),
    );
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

// Dialog for adding product
class _AjouterProduitDialog extends StatefulWidget {
  final List<Produit> produits;

  const _AjouterProduitDialog({required this.produits});

  @override
  State<_AjouterProduitDialog> createState() => _AjouterProduitDialogState();
}

class _AjouterProduitDialogState extends State<_AjouterProduitDialog> {
  Produit? _selectedProduit;
  final TextEditingController _quantiteController = TextEditingController(text: '1');

  @override
  void dispose() {
    _quantiteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ajouter un produit'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<Produit>(
            value: _selectedProduit,
            decoration: const InputDecoration(
              labelText: 'Produit',
              prefixIcon: Icon(Icons.inventory),
            ),
            items: widget.produits
                .map((produit) => DropdownMenuItem(
                      value: produit,
                      child: Text('${produit.designation} (${produit.prixUnitaire} DA)'),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() => _selectedProduit = value);
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _quantiteController,
            decoration: const InputDecoration(
              labelText: 'Quantité',
              prefixIcon: Icon(Icons.numbers),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_selectedProduit != null) {
              final quantite = double.tryParse(_quantiteController.text) ?? 1.0;
              Navigator.pop(context, {
                'produit': _selectedProduit,
                'quantite': quantite,
              });
            }
          },
          child: const Text('Ajouter'),
        ),
      ],
    );
  }
}

// Dialog for entering quantity
class _QuantiteDialog extends StatefulWidget {
  @override
  State<_QuantiteDialog> createState() => _QuantiteDialogState();
}

class _QuantiteDialogState extends State<_QuantiteDialog> {
  final TextEditingController _controller = TextEditingController(text: '1');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Quantité'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          labelText: 'Quantité',
          prefixIcon: Icon(Icons.numbers),
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () {
            final quantite = double.tryParse(_controller.text) ?? 1.0;
            Navigator.pop(context, quantite);
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}
