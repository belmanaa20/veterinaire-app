import 'package:flutter/material.dart';
import '../../models/client.dart';
import '../../services/client_service.dart';
import '../../config/app_constants.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_button.dart';

class ClientFormScreen extends StatefulWidget {
  final Client? client;

  const ClientFormScreen({super.key, this.client});

  @override
  State<ClientFormScreen> createState() => _ClientFormScreenState();
}

class _ClientFormScreenState extends State<ClientFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ClientService _clientService = ClientService();

  late TextEditingController _nomController;
  late TextEditingController _adresseController;
  late TextEditingController _telephoneController;
  String? _selectedCulture;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController(text: widget.client?.nom);
    _adresseController = TextEditingController(text: widget.client?.adresse);
    _telephoneController =
        TextEditingController(text: widget.client?.telephone);
    _selectedCulture = widget.client?.culture;
  }

  @override
  void dispose() {
    _nomController.dispose();
    _adresseController.dispose();
    _telephoneController.dispose();
    super.dispose();
  }

  Future<void> _saveClient() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final client = Client(
        id: widget.client?.id ?? 0,
        nom: _nomController.text.trim(),
        adresse: _adresseController.text.trim().isEmpty
            ? null
            : _adresseController.text.trim(),
        telephone: _telephoneController.text.trim().isEmpty
            ? null
            : _telephoneController.text.trim(),
        culture: _selectedCulture,
        createdAt: widget.client?.createdAt ?? DateTime.now(),
      );

      if (widget.client == null) {
        await _clientService.createClient(client);
      } else {
        await _clientService.updateClient(widget.client!.id, client);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.client == null
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
        title: widget.client == null ? 'Nouveau Client' : 'Modifier Client',
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Nom
            TextFormField(
              controller: _nomController,
              decoration: const InputDecoration(
                labelText: 'Nom *',
                hintText: 'Nom du client',
                prefixIcon: Icon(Icons.person),
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
            // Adresse
            TextFormField(
              controller: _adresseController,
              decoration: const InputDecoration(
                labelText: 'Adresse',
                hintText: 'Adresse du client',
                prefixIcon: Icon(Icons.location_on),
              ),
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),
            // Téléphone
            TextFormField(
              controller: _telephoneController,
              decoration: const InputDecoration(
                labelText: 'Téléphone',
                hintText: '0X XX XX XX XX',
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            // Culture
            DropdownButtonFormField<String>(
              value: _selectedCulture,
              decoration: const InputDecoration(
                labelText: 'Type d\'élevage',
                hintText: 'Sélectionner le type',
                prefixIcon: Icon(Icons.agriculture),
              ),
              items: AppConstants.cultureTypes
                  .map((culture) => DropdownMenuItem(
                        value: culture,
                        child: Text(culture),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() => _selectedCulture = value);
              },
            ),
            const SizedBox(height: 32),
            // Submit button
            CustomButton(
              text: widget.client == null ? 'Créer' : 'Modifier',
              icon: widget.client == null ? Icons.add : Icons.save,
              onPressed: _saveClient,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }
}
