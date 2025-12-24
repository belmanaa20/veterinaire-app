import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme_config.dart';
import '../../providers/parametre_provider.dart';
import '../../widgets/common_widgets.dart';
import '../../models/parametre.dart';
import '../../utils/validators.dart';

class ParametresScreen extends StatefulWidget {
  const ParametresScreen({super.key});

  @override
  State<ParametresScreen> createState() => _ParametresScreenState();
}

class _ParametresScreenState extends State<ParametresScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomEntrepriseController;
  late final TextEditingController _adresseController;
  late final TextEditingController _telephoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _tvaDefautController;
  late final TextEditingController _delaiNotificationController;
  late final TextEditingController _seuilStockController;

  bool _isLoading = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _nomEntrepriseController = TextEditingController();
    _adresseController = TextEditingController();
    _telephoneController = TextEditingController();
    _emailController = TextEditingController();
    _tvaDefautController = TextEditingController();
    _delaiNotificationController = TextEditingController();
    _seuilStockController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ParametreProvider>().loadParametres();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Paramètres'),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          if (_isInitialized)
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _saveParametres,
              icon: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: const Text('Enregistrer'),
            ),
          const SizedBox(width: 16),
        ],
      ),
      body: Consumer<ParametreProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const LoadingIndicator(message: 'Chargement des paramètres...');
          }

          if (provider.error != null) {
            return ErrorDisplay(
              message: provider.error!,
              onRetry: () => provider.loadParametres(),
            );
          }

          if (provider.parametres == null) {
            return const EmptyState(
              message: 'Aucun paramètre trouvé',
              icon: Icons.settings,
            );
          }

          // Initialize form with loaded data
          if (!_isInitialized) {
            final p = provider.parametres!;
            _nomEntrepriseController.text = p.nomEntreprise;
            _adresseController.text = p.adresse ?? '';
            _telephoneController.text = p.telephone ?? '';
            _emailController.text = p.email ?? '';
            _tvaDefautController.text = p.tvaDefaut.toString();
            _delaiNotificationController.text = p.delaiNotificationRappel.toString();
            _seuilStockController.text = p.seuilStockFaible.toString();
            _isInitialized = true;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Informations de l\'entreprise',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextFormField(
                        controller: _nomEntrepriseController,
                        decoration: const InputDecoration(
                          labelText: 'Nom de l\'entreprise *',
                          prefixIcon: Icon(Icons.business),
                        ),
                        validator: (v) => Validators.required(v, fieldName: 'Le nom de l\'entreprise'),
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
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Paramètres généraux',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _tvaDefautController,
                              decoration: const InputDecoration(
                                labelText: 'TVA par défaut (%)',
                                prefixIcon: Icon(Icons.percent),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (v) => Validators.positiveNumber(v, fieldName: 'La TVA'),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: TextFormField(
                              controller: _delaiNotificationController,
                              decoration: const InputDecoration(
                                labelText: 'Délai de notification (jours)',
                                prefixIcon: Icon(Icons.notifications),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (v) => Validators.positiveNumber(v, fieldName: 'Le délai'),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: TextFormField(
                              controller: _seuilStockController,
                              decoration: const InputDecoration(
                                labelText: 'Seuil de stock faible',
                                prefixIcon: Icon(Icons.inventory),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (v) => Validators.positiveNumber(v, fieldName: 'Le seuil'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _saveParametres() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<ParametreProvider>();
    if (provider.parametres == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedParametres = provider.parametres!.copyWith(
        nomEntreprise: _nomEntrepriseController.text,
        adresse: _adresseController.text.isEmpty ? null : _adresseController.text,
        telephone: _telephoneController.text.isEmpty ? null : _telephoneController.text,
        email: _emailController.text.isEmpty ? null : _emailController.text,
        tvaDefaut: double.parse(_tvaDefautController.text),
        delaiNotificationRappel: int.parse(_delaiNotificationController.text),
        seuilStockFaible: int.parse(_seuilStockController.text),
        updatedAt: DateTime.now(),
      );

      await provider.updateParametres(updatedParametres);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Paramètres enregistrés avec succès'),
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
    _nomEntrepriseController.dispose();
    _adresseController.dispose();
    _telephoneController.dispose();
    _emailController.dispose();
    _tvaDefautController.dispose();
    _delaiNotificationController.dispose();
    _seuilStockController.dispose();
    super.dispose();
  }
}
