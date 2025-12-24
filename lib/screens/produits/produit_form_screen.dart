import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme_config.dart';
import '../../models/produit.dart';
import '../../providers/produit_provider.dart';
import '../../utils/validators.dart';
import '../../utils/constants.dart';

class ProduitFormScreen extends StatefulWidget {
  final Produit? produit;

  const ProduitFormScreen({super.key, this.produit});

  @override
  State<ProduitFormScreen> createState() => _ProduitFormScreenState();
}

class _ProduitFormScreenState extends State<ProduitFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _designationController;
  late final TextEditingController _codeBarreController;
  late final TextEditingController _prixUnitaireController;
  late final TextEditingController _stockActuelController;
  late final TextEditingController _stockMinimumController;
  late final TextEditingController _descriptionController;
  String? _categorie;
  String _unite = 'Unité';
  bool _actif = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _designationController = TextEditingController(text: widget.produit?.designation);
    _codeBarreController = TextEditingController(text: widget.produit?.codeBarre);
    _prixUnitaireController = TextEditingController(
      text: widget.produit?.prixUnitaire.toString() ?? '0',
    );
    _stockActuelController = TextEditingController(
      text: widget.produit?.stockActuel.toString() ?? '0',
    );
    _stockMinimumController = TextEditingController(
      text: widget.produit?.stockMinimum.toString() ?? '5',
    );
    _descriptionController = TextEditingController(text: widget.produit?.description);
    _categorie = widget.produit?.categorie;
    _unite = widget.produit?.unite ?? 'Unité';
    _actif = widget.produit?.actif ?? true;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 700,
        constraints: const BoxConstraints(maxHeight: 700),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              color: AppColors.primaryGreen,
              child: Row(
                children: [
                  const Icon(Icons.inventory, color: Colors.white),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    widget.produit == null ? 'Nouveau Produit' : 'Modifier Produit',
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
                      TextFormField(
                        controller: _designationController,
                        decoration: const InputDecoration(
                          labelText: 'Désignation *',
                          prefixIcon: Icon(Icons.title),
                        ),
                        validator: (v) => Validators.required(v, fieldName: 'La désignation'),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _codeBarreController,
                              decoration: const InputDecoration(
                                labelText: 'Code-barres',
                                prefixIcon: Icon(Icons.qr_code),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: TextFormField(
                              controller: _prixUnitaireController,
                              decoration: const InputDecoration(
                                labelText: 'Prix Unitaire *',
                                prefixIcon: Icon(Icons.attach_money),
                                suffixText: 'DH',
                              ),
                              keyboardType: TextInputType.number,
                              validator: (v) => Validators.positiveNumber(v, fieldName: 'Le prix'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _stockActuelController,
                              decoration: const InputDecoration(
                                labelText: 'Stock Actuel *',
                                prefixIcon: Icon(Icons.inventory_2),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (v) => Validators.number(v, fieldName: 'Le stock'),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: TextFormField(
                              controller: _stockMinimumController,
                              decoration: const InputDecoration(
                                labelText: 'Stock Minimum *',
                                prefixIcon: Icon(Icons.warning),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (v) => Validators.positiveNumber(v, fieldName: 'Le stock minimum'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _unite,
                              decoration: const InputDecoration(
                                labelText: 'Unité *',
                                prefixIcon: Icon(Icons.straighten),
                              ),
                              items: AppConstants.unitesMesure
                                  .map((unite) => DropdownMenuItem(
                                        value: unite,
                                        child: Text(unite),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _unite = value!;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _categorie,
                              decoration: const InputDecoration(
                                labelText: 'Catégorie',
                                prefixIcon: Icon(Icons.category),
                              ),
                              items: AppConstants.categoriesProduits
                                  .map((cat) => DropdownMenuItem(
                                        value: cat,
                                        child: Text(cat),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _categorie = value;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          prefixIcon: Icon(Icons.description),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      SwitchListTile(
                        title: const Text('Produit actif'),
                        value: _actif,
                        onChanged: (value) {
                          setState(() {
                            _actif = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Footer
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
                    child: const Text('Annuler'),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveProduit,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Enregistrer'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProduit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final produit = Produit(
        id: widget.produit?.id,
        designation: _designationController.text,
        codeBarre: _codeBarreController.text.isEmpty ? null : _codeBarreController.text,
        prixUnitaire: double.parse(_prixUnitaireController.text),
        stockActuel: int.parse(_stockActuelController.text),
        stockMinimum: int.parse(_stockMinimumController.text),
        unite: _unite,
        categorie: _categorie,
        description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
        actif: _actif,
      );

      if (widget.produit == null) {
        await context.read<ProduitProvider>().addProduit(produit);
      } else {
        await context.read<ProduitProvider>().updateProduit(produit);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.produit == null
                ? 'Produit ajouté avec succès'
                : 'Produit modifié avec succès'),
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
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _designationController.dispose();
    _codeBarreController.dispose();
    _prixUnitaireController.dispose();
    _stockActuelController.dispose();
    _stockMinimumController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
