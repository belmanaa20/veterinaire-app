import 'package:flutter/material.dart';
import '../../models/client.dart';
import '../../models/facture.dart';
import '../../services/facture_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/facture_card.dart';
import 'client_form_screen.dart';

class ClientDetailsScreen extends StatefulWidget {
  final Client client;

  const ClientDetailsScreen({super.key, required this.client});

  @override
  State<ClientDetailsScreen> createState() => _ClientDetailsScreenState();
}

class _ClientDetailsScreenState extends State<ClientDetailsScreen> {
  final FactureService _factureService = FactureService();
  List<Facture> _factures = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFactures();
  }

  Future<void> _loadFactures() async {
    setState(() => _isLoading = true);
    try {
      final factures =
          await _factureService.getFacturesByClient(widget.client.id);
      setState(() {
        _factures = factures;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Détails Client',
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ClientFormScreen(client: widget.client),
                ),
              );
              if (result == true && mounted) {
                Navigator.pop(context, true);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Client info card
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          child: Text(
                            widget.client.nom.substring(0, 1).toUpperCase(),
                            style: const TextStyle(fontSize: 32),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.client.nom,
                                style: Theme.of(context).textTheme.headlineMedium,
                              ),
                              if (widget.client.culture != null) ...[
                                const SizedBox(height: 4),
                                Chip(
                                  label: Text(widget.client.culture!),
                                  avatar: const Icon(
                                    Icons.agriculture,
                                    size: 16,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    if (widget.client.adresse != null) ...[
                      _buildInfoRow(
                        Icons.location_on,
                        'Adresse',
                        widget.client.adresse!,
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (widget.client.telephone != null) ...[
                      _buildInfoRow(
                        Icons.phone,
                        'Téléphone',
                        widget.client.telephone!,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            // Factures section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Factures (${_factures.length})',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  TextButton.icon(
                    onPressed: _loadFactures,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Actualiser'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Factures list
            _isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : _factures.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
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
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _factures.length,
                        itemBuilder: (context, index) {
                          return FactureCard(
                            facture: _factures[index],
                            onTap: () {
                              // TODO: Navigate to facture details
                            },
                          );
                        },
                      ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
