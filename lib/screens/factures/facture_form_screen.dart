import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme_config.dart';
import '../../providers/facture_provider.dart';
import '../../providers/client_provider.dart';
import '../../providers/produit_provider.dart';
import '../../models/client.dart';
import '../../models/produit.dart';
import '../../utils/formatters.dart';
import '../../utils/validators.dart';

class FactureFormScreen extends StatefulWidget {
  final int? factureId;

  const FactureFormScreen({super.key, this.factureId});

  @override
  State<FactureFormScreen> createState() => _FactureFormScreenState();
}

class _FactureFormScreenState extends State<FactureFormScreen> {
  final _formKey = GlobalKey<FormState>();
  Client? _selectedClient;
  Produit? _selectedProduit;
  DateTime _dateFacture = DateTime.now();
  final TextEditingController _quantiteController = TextEditingController(text: '1');
  final TextEditingController _prixController = TextEditingController();
  final TextEditingController _remiseController = TextEditingController(text: '0');
  bool _isLoading = false;
  int? _currentFactureId;

  @override
  void initState() {
    super.initState();
    _currentFactureId = widget.factureId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClientProvider>().loadClients();
      context.read<ProduitProvider>().loadProduits();
      if (_currentFactureId != null) {
        _loadFacture();
      }
    });
  }

  Future<void> _loadFacture() async {
    await context.read<FactureProvider>().loadFactureById(_currentFactureId!);
    await context.read<FactureProvider>().loadLignesFacture(_currentFactureId!);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 900,
        constraints: const BoxConstraints(maxHeight: 700),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              color: AppColors.primaryGreen,
              child: Row(
                children: [
                  const Icon(Icons.receipt_long, color: Colors.white),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    _currentFactureId == null ? 'Nouvelle Facture' : 'Modifier Facture',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Client and Date Selection
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Consumer<ClientProvider>(
                              builder: (context, provider, _) {
                                return DropdownButtonFormField<Client>(
                                  value: _selectedClient,
                                  decoration: const InputDecoration(
                                    labelText: 'Client *',
                                    prefixIcon: Icon(Icons.person),
                                  ),
                                  items: provider.clients
                                      .map((client) => DropdownMenuItem(
                                            value: client,
                                            child: Text(client.fullName),
                                          ))
                                      .toList(),
                                  onChanged: _handleClientChange,
                                  validator: (v) => v == null ? 'Sélectionnez un client' : null,
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: InkWell(
                              onTap: _currentFactureId == null
                                  ? () async {
                                      final date = await showDatePicker(
                                        context: context,
                                        initialDate: _dateFacture,
                                        firstDate: DateTime(2020),
                                        lastDate: DateTime.now().add(const Duration(days: 365)),
                                      );
                                      if (date != null) {
                                        setState(() {
                                          _dateFacture = date;
                                        });
                                      }
                                    }
                                  : null,
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Date Facture',
                                  prefixIcon: Icon(Icons.calendar_today),
                                ),
                                child: Text(Formatters.formatDate(_dateFacture)),
                              ),
                            ),
                          ),
                        ],
                      ),

                      if (_currentFactureId == null) ...[
                        const SizedBox(height: AppSpacing.md),
                        ElevatedButton.icon(
                          onPressed: _selectedClient != null ? _createFacture : null,
                          icon: const Icon(Icons.add),
                          label: const Text('Créer la facture'),
                        ),
                      ],

                      if (_currentFactureId != null) ...[
                        const SizedBox(height: AppSpacing.md),
                        const Divider(),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Ajouter un produit',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Consumer<ProduitProvider>(
                                builder: (context, provider, _) {
                                  return DropdownButtonFormField<Produit>(
                                    value: _selectedProduit,
                                    decoration: const InputDecoration(
                                      labelText: 'Produit',
                                      prefixIcon: Icon(Icons.inventory),
                                    ),
                                    items: provider.produits
                                        .where((p) => p.actif)
                                        .map((produit) => DropdownMenuItem(
                                              value: produit,
                                              child: Text(
                                                '${produit.designation} - ${Formatters.formatCurrency(produit.prixUnitaire)}',
                                              ),
                                            ))
                                        .toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedProduit = value;
                                        _prixController.text = value?.prixUnitaire.toString() ?? '0';
                                      });
                                    },
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Expanded(
                              child: TextFormField(
                                controller: _quantiteController,
                                decoration: const InputDecoration(
                                  labelText: 'Quantité',
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Expanded(
                              child: TextFormField(
                                controller: _prixController,
                                decoration: const InputDecoration(
                                  labelText: 'Prix',
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Expanded(
                              child: TextFormField(
                                controller: _remiseController,
                                decoration: const InputDecoration(
                                  labelText: 'Remise',
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle),
                              color: AppColors.primaryGreen,
                              onPressed: _selectedProduit != null ? _addLigne : null,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Consumer<FactureProvider>(
                          builder: (context, provider, _) {
                            if (provider.currentFacture == null) {
                              return const SizedBox.shrink();
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Lignes de facture',
                                  style: Theme.of(context).textTheme.headlineSmall,
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Card(
                                  child: Column(
                                    children: [
                                      ...provider.lignesFacture.map((ligne) => ListTile(
                                            title: Text(ligne.designation),
                                            subtitle: Text(
                                              'Qté: ${ligne.quantite} x ${Formatters.formatCurrency(ligne.prixUnitaire)}',
                                            ),
                                            trailing: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  Formatters.formatCurrency(ligne.totalLigne),
                                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.delete, color: Colors.red),
                                                  onPressed: () => _deleteLigne(ligne.id!),
                                                ),
                                              ],
                                            ),
                                          )),
                                      const Divider(),
                                      Padding(
                                        padding: const EdgeInsets.all(AppSpacing.sm),
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                const Text('Total HT:'),
                                                Text(
                                                  Formatters.formatCurrency(provider.currentFacture!.totalHt),
                                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                const Text('TVA:'),
                                                Text(
                                                  Formatters.formatCurrency(provider.currentFacture!.tva),
                                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                const Text('Total TTC:'),
                                                Text(
                                                  Formatters.formatCurrency(provider.currentFacture!.totalTtc),
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                    color: AppColors.primaryGreen,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // Footer
            if (_currentFactureId != null)
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  border: Border(top: BorderSide(color: Colors.grey[300]!)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Fermer'),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    ElevatedButton.icon(
                      onPressed: _validateFacture,
                      icon: const Icon(Icons.check),
                      label: const Text('Valider la facture'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _createFacture() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final factureId = await context.read<FactureProvider>().creerFacture(
            _selectedClient!.id!,
            _dateFacture,
          );

      setState(() {
        _currentFactureId = factureId;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Facture créée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        await _loadFacture();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _addLigne() async {
    try {
      await context.read<FactureProvider>().ajouterLigne(
            _currentFactureId!,
            _selectedProduit!.id!,
            double.parse(_quantiteController.text),
            double.parse(_prixController.text),
            double.parse(_remiseController.text),
          );

      setState(() {
        _selectedProduit = null;
        _quantiteController.text = '1';
        _prixController.clear();
        _remiseController.text = '0';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ligne ajoutée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteLigne(int ligneId) async {
    try {
      await context.read<FactureProvider>().supprimerLigne(ligneId, _currentFactureId!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ligne supprimée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _validateFacture() async {
    try {
      await context.read<FactureProvider>().fermerFacture(_currentFactureId!);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Facture validée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _quantiteController.dispose();
    _prixController.dispose();
    _remiseController.dispose();
    super.dispose();
  }

  void _handleClientChange(Client? value) {
    if (_currentFactureId == null) {
      setState(() {
        _selectedClient = value;
      });
    }
  }
}
