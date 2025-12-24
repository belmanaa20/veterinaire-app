import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme_config.dart';
import '../../providers/client_provider.dart';
import '../../providers/produit_provider.dart';
import '../../providers/facture_provider.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/common_widgets.dart';
import '../../utils/formatters.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final clientProvider = context.read<ClientProvider>();
    final produitProvider = context.read<ProduitProvider>();
    final factureProvider = context.read<FactureProvider>();

    await Future.wait([
      clientProvider.loadClients(),
      produitProvider.loadProduits(),
      produitProvider.loadProduitsStockFaible(),
      factureProvider.loadFactures(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Consumer3<ClientProvider, ProduitProvider, FactureProvider>(
        builder: (context, clientProvider, produitProvider, factureProvider, _) {
          if (clientProvider.isLoading || produitProvider.isLoading || factureProvider.isLoading) {
            return const LoadingIndicator(message: 'Chargement des données...');
          }

          final totalClients = clientProvider.clients.length;
          final totalProduits = produitProvider.produits.length;
          final totalFactures = factureProvider.factures.length;
          final totalRevenu = factureProvider.factures
              .where((f) => f.isPaid)
              .fold(0.0, (sum, f) => sum + f.totalTtc);
          final produitsStockFaible = produitProvider.produitsStockFaible;
          final recentFactures = factureProvider.factures.take(10).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Statistics Cards
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        title: 'Total Clients',
                        value: totalClients.toString(),
                        icon: Icons.people,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: StatCard(
                        title: 'Total Produits',
                        value: totalProduits.toString(),
                        icon: Icons.inventory,
                        color: AppColors.secondaryBlue,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: StatCard(
                        title: 'Total Factures',
                        value: totalFactures.toString(),
                        icon: Icons.receipt_long,
                        color: AppColors.accentOrange,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: StatCard(
                        title: 'Revenu Total',
                        value: Formatters.formatCurrency(totalRevenu),
                        icon: Icons.attach_money,
                        color: AppColors.successGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                // Low Stock Alerts
                if (produitsStockFaible.isNotEmpty) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.warning, color: AppColors.warningYellow),
                              const SizedBox(width: 8),
                              Text(
                                'Alertes Stock Faible (${produitsStockFaible.length})',
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          ...produitsStockFaible.take(5).map((produit) => ListTile(
                                leading: Icon(Icons.inventory_2, color: AppColors.errorRed),
                                title: Text(produit.designation),
                                subtitle: Text(
                                  'Stock: ${produit.stockActuel} ${produit.unite} (Min: ${produit.stockMinimum})',
                                ),
                                trailing: Chip(
                                  label: const Text('Stock Faible'),
                                  backgroundColor: AppColors.errorRed.withOpacity(0.1),
                                ),
                              )),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],

                // Recent Invoices
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Factures Récentes',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        if (recentFactures.isEmpty)
                          const EmptyState(
                            message: 'Aucune facture trouvée',
                            icon: Icons.receipt_long,
                          )
                        else
                          ...recentFactures.map((facture) => ListTile(
                                leading: const Icon(Icons.receipt),
                                title: Text(facture.numeroFacture ?? 'N/A'),
                                subtitle: Text(
                                  '${facture.clientFullName} - ${Formatters.formatDate(facture.dateFacture)}',
                                ),
                                trailing: Text(
                                  Formatters.formatCurrency(facture.totalTtc),
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              )),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
