import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme_config.dart';
import '../../models/client.dart';
import '../../providers/client_provider.dart';
import '../../utils/validators.dart';
import '../../utils/constants.dart';

class ClientFormScreen extends StatefulWidget {
  final Client? client;

  const ClientFormScreen({super.key, this.client});

  @override
  State<ClientFormScreen> createState() => _ClientFormScreenState();
}

class _ClientFormScreenState extends State<ClientFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomController;
  late final TextEditingController _prenomController;
  late final TextEditingController _telephoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _adresseController;
  late final TextEditingController _notesController;
  late final TextEditingController _nomAnimalController;
  late final TextEditingController _raceAnimalController;
  String? _typeAnimal;
  DateTime? _dateNaissanceAnimal;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController(text: widget.client?.nom);
    _prenomController = TextEditingController(text: widget.client?.prenom);
    _telephoneController = TextEditingController(text: widget.client?.telephone);
    _emailController = TextEditingController(text: widget.client?.email);
    _adresseController = TextEditingController(text: widget.client?.adresse);
    _notesController = TextEditingController(text: widget.client?.notes);
    _nomAnimalController = TextEditingController(text: widget.client?.nomAnimal);
    _raceAnimalController = TextEditingController(text: widget.client?.raceAnimal);
    _typeAnimal = widget.client?.typeAnimal;
    _dateNaissanceAnimal = widget.client?.dateNaissanceAnimal;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 800,
        constraints: const BoxConstraints(maxHeight: 700),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              color: AppColors.primaryGreen,
              child: Row(
                children: [
                  const Icon(Icons.person, color: Colors.white),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    widget.client == null ? 'Nouveau Client' : 'Modifier Client',
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
                      Text(
                        'Informations du propriétaire',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _nomController,
                              decoration: const InputDecoration(
                                labelText: 'Nom *',
                                prefixIcon: Icon(Icons.person),
                              ),
                              validator: (v) => Validators.required(v, fieldName: 'Le nom'),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: TextFormField(
                              controller: _prenomController,
                              decoration: const InputDecoration(
                                labelText: 'Prénom',
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _telephoneController,
                              decoration: const InputDecoration(
                                labelText: 'Téléphone',
                                prefixIcon: Icon(Icons.phone),
                              ),
                              validator: Validators.phone,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: TextFormField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                prefixIcon: Icon(Icons.email),
                              ),
                              validator: Validators.email,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextFormField(
                        controller: _adresseController,
                        decoration: const InputDecoration(
                          labelText: 'Adresse',
                          prefixIcon: Icon(Icons.location_on),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Informations de l\'animal',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _nomAnimalController,
                              decoration: const InputDecoration(
                                labelText: 'Nom de l\'animal',
                                prefixIcon: Icon(Icons.pets),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _typeAnimal,
                              decoration: const InputDecoration(
                                labelText: 'Type d\'animal',
                                prefixIcon: Icon(Icons.category),
                              ),
                              items: AppConstants.typesAnimaux
                                  .map((type) => DropdownMenuItem(
                                        value: type,
                                        child: Text(type),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _typeAnimal = value;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _raceAnimalController,
                              decoration: const InputDecoration(
                                labelText: 'Race',
                                prefixIcon: Icon(Icons.pets),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: _dateNaissanceAnimal ?? DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime.now(),
                                );
                                if (date != null) {
                                  setState(() {
                                    _dateNaissanceAnimal = date;
                                  });
                                }
                              },
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Date de naissance',
                                  prefixIcon: Icon(Icons.calendar_today),
                                ),
                                child: Text(
                                  _dateNaissanceAnimal != null
                                      ? '${_dateNaissanceAnimal!.day}/${_dateNaissanceAnimal!.month}/${_dateNaissanceAnimal!.year}'
                                      : 'Sélectionner une date',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          labelText: 'Notes',
                          prefixIcon: Icon(Icons.note),
                        ),
                        maxLines: 3,
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
                    onPressed: _isLoading ? null : _saveClient,
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

  Future<void> _saveClient() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final client = Client(
        id: widget.client?.id,
        nom: _nomController.text,
        prenom: _prenomController.text.isEmpty ? null : _prenomController.text,
        telephone: _telephoneController.text.isEmpty ? null : _telephoneController.text,
        email: _emailController.text.isEmpty ? null : _emailController.text,
        adresse: _adresseController.text.isEmpty ? null : _adresseController.text,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        nomAnimal: _nomAnimalController.text.isEmpty ? null : _nomAnimalController.text,
        typeAnimal: _typeAnimal,
        raceAnimal: _raceAnimalController.text.isEmpty ? null : _raceAnimalController.text,
        dateNaissanceAnimal: _dateNaissanceAnimal,
      );

      if (widget.client == null) {
        await context.read<ClientProvider>().addClient(client);
      } else {
        await context.read<ClientProvider>().updateClient(client);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.client == null
                ? 'Client ajouté avec succès'
                : 'Client modifié avec succès'),
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
    _nomController.dispose();
    _prenomController.dispose();
    _telephoneController.dispose();
    _emailController.dispose();
    _adresseController.dispose();
    _notesController.dispose();
    _nomAnimalController.dispose();
    _raceAnimalController.dispose();
    super.dispose();
  }
}
