import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme_config.dart';
import '../../providers/facture_provider.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/status_badge.dart';
import '../../utils/formatters.dart';
import 'facture_form_screen.dart';

class FacturesListScreen extends StatefulWidget {
  const FacturesListScreen({super.key});

  @override
  State<FacturesListScreen> createState() => _FacturesListScreenState();
}

class _FacturesListScreenState extends State<FacturesListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FactureProvider>().loadFactures();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Gestion des Factures'),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<FactureProvider>().loadFactures(),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: () => _showFactureForm(context),
            icon: const Icon(Icons.add),
            label: const Text('Nouvelle Facture'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Consumer<FactureProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const LoadingIndicator(message: 'Chargement des factures...');
          }

          if (provider.error != null) {
            return ErrorDisplay(
              message: provider.error!,
              onRetry: () => provider.loadFactures(),
            );
          }

          if (provider.factures.isEmpty) {
            return const EmptyState(
              message: 'Aucune facture trouvée',
              icon: Icons.receipt_long,
            );
          }

          return Card(
            margin: const EdgeInsets.all(AppSpacing.sm),
            child: ListView.separated(
              itemCount: provider.factures.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final facture = provider.factures[index];

                return ListTile(
                  leading: const Icon(Icons.receipt),
                  title: Text(facture.numeroFacture ?? 'N/A'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Client: ${facture.clientFullName}'),
                      Text('Date: ${Formatters.formatDate(facture.dateFacture)}'),
                      Row(
                        children: [
                          Text('Total: ${Formatters.formatCurrency(facture.totalTtc)}'),
                          const SizedBox(width: 8),
                          if (facture.resteAPayer > 0)
                            Text(
                              'Reste: ${Formatters.formatCurrency(facture.resteAPayer)}',
                              style: const TextStyle(color: Colors.red),
                            ),
                        ],
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      StatusBadge(statut: facture.statut),
                      if (facture.isDraft) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _showFactureForm(context, factureId: facture.id),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _showFactureForm(BuildContext context, {int? factureId}) {
    showDialog(
      context: context,
      builder: (context) => FactureFormScreen(factureId: factureId),
    ).then((_) {
      // Reload invoices after dialog closes
      context.read<FactureProvider>().loadFactures();
    });
  }
}
