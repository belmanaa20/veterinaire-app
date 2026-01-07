import 'package:flutter/material.dart';
import '../../models/produit.dart';
import '../../services/produit_service.dart';
import '../../config/app_constants.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_button.dart';

class ProduitFormScreen extends StatefulWidget {
  final Produit? produit;

  const ProduitFormScreen({super.key, this.produit});

  @override
  State<ProduitFormScreen> createState() => _ProduitFormScreenState();
}

class _ProduitFormScreenState extends State<ProduitFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ProduitService _produitService = ProduitService();

  late TextEditingController _codeController;
  late TextEditingController _barcodeController;
  late TextEditingController _designationController;
  late TextEditingController _prixController;
  late TextEditingController _stockController;
  late TextEditingController _stockMinController;
  String? _selectedCategorie;
  String? _selectedUnite;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(text: widget.produit?.code);
    _barcodeController = TextEditingController(text: widget.produit?.barcode);
    _designationController =
        TextEditingController(text: widget.produit?.designation);
    _prixController = TextEditingController(
        text: widget.produit?.prixUnitaire.toString() ?? '');
    _stockController =
        TextEditingController(text: widget.produit?.stock.toString() ?? '');
    _stockMinController =
        TextEditingController(text: widget.produit?.stockMin.toString() ?? '');
    _selectedCategorie = widget.produit?.categorie;
    _selectedUnite = widget.produit?.unite;
  }

  @override
  void dispose() {
    _codeController.dispose();
    _barcodeController.dispose();
    _designationController.dispose();
    _prixController.dispose();
    _stockController.dispose();
    _stockMinController.dispose();
    super.dispose();
  }

  Future<void> _saveProduit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final produit = Produit(
        id: widget.produit?.id ?? 0,
        code: _codeController.text.trim(),
        barcode: _barcodeController.text.trim(),
        designation: _designationController.text.trim(),
        prixUnitaire: double.parse(_prixController.text.trim()),
        stock: double.parse(_stockController.text.trim()),
        stockMin: double.parse(_stockMinController.text.trim()),
        categorie: _selectedCategorie,
        unite: _selectedUnite,
        createdAt: widget.produit?.createdAt ?? DateTime.now(),
      );

      if (widget.produit == null) {
        await _produitService.createProduit(produit);
      } else {
        await _produitService.updateProduit(widget.produit!.id, produit);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.produit == null
                  ? AppConstants.successCreate
                  : AppConstants.successUpdate,
            ),
          ),
        );
        Navigator.pop(context, true);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.produit == null ? 'Nouveau Produit' : 'Modifier Produit',
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Code
            TextFormField(
              controller: _codeController,
              decoration: const InputDecoration(
                labelText: 'Code *',
                hintText: 'Code du produit',
                prefixIcon: Icon(Icons.tag),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return AppConstants.validationRequired;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Barcode
            TextFormField(
              controller: _barcodeController,
              decoration: const InputDecoration(
                labelText: 'Barcode *',
                hintText: 'Code-barres du produit',
                prefixIcon: Icon(Icons.qr_code),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return AppConstants.validationRequired;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Désignation
            TextFormField(
              controller: _designationController,
              decoration: const InputDecoration(
                labelText: 'Désignation *',
                hintText: 'Nom du produit',
                prefixIcon: Icon(Icons.inventory),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return AppConstants.validationRequired;
                }
                return null;
              },
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            // Prix unitaire
            TextFormField(
              controller: _prixController,
              decoration: InputDecoration(
                labelText: 'Prix unitaire (${AppConstants.currency}) *',
                hintText: '0.00',
                prefixIcon: const Icon(Icons.attach_money),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return AppConstants.validationRequired;
                }
                final prix = double.tryParse(value.trim());
                if (prix == null) {
                  return AppConstants.validationNumber;
                }
                if (prix < 0) {
                  return AppConstants.validationPositive;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Stock
            TextFormField(
              controller: _stockController,
              decoration: const InputDecoration(
                labelText: 'Stock *',
                hintText: '0',
                prefixIcon: Icon(Icons.storage),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return AppConstants.validationRequired;
                }
                final stock = double.tryParse(value.trim());
                if (stock == null) {
                  return AppConstants.validationNumber;
                }
                if (stock < 0) {
                  return AppConstants.validationPositive;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Stock min
            TextFormField(
              controller: _stockMinController,
              decoration: const InputDecoration(
                labelText: 'Stock minimum *',
                hintText: '0',
                prefixIcon: Icon(Icons.warning),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return AppConstants.validationRequired;
                }
                final stock = double.tryParse(value.trim());
                if (stock == null) {
                  return AppConstants.validationNumber;
                }
                if (stock < 0) {
                  return AppConstants.validationPositive;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Catégorie
            DropdownButtonFormField<String>(
              value: _selectedCategorie,
              decoration: const InputDecoration(
                labelText: 'Catégorie',
                prefixIcon: Icon(Icons.category),
              ),
              items: AppConstants.productCategories
                  .map((categorie) => DropdownMenuItem(
                        value: categorie,
                        child: Text(categorie),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() => _selectedCategorie = value);
              },
            ),
            const SizedBox(height: 16),
            // Unité
            DropdownButtonFormField<String>(
              value: _selectedUnite,
              decoration: const InputDecoration(
                labelText: 'Unité',
                prefixIcon: Icon(Icons.straighten),
              ),
              items: AppConstants.productUnits
                  .map((unite) => DropdownMenuItem(
                        value: unite,
                        child: Text(unite),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() => _selectedUnite = value);
              },
            ),
            const SizedBox(height: 32),
            // Submit button
            CustomButton(
              text: widget.produit == null ? 'Créer' : 'Modifier',
              icon: widget.produit == null ? Icons.add : Icons.save,
              onPressed: _saveProduit,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
