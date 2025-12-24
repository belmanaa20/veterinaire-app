import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme_config.dart';
import '../../providers/produit_provider.dart';
import '../../widgets/common_widgets.dart';
import '../../utils/formatters.dart';
import '../../models/produit.dart';
import 'produit_form_screen.dart';

class ProduitsListScreen extends StatefulWidget {
  const ProduitsListScreen({super.key});

  @override
  State<ProduitsListScreen> createState() => _ProduitsListScreenState();
}

class _ProduitsListScreenState extends State<ProduitsListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProduitProvider>().loadProduits();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Gestion des Produits'),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<ProduitProvider>().loadProduits(),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: () => _showProduitForm(context),
            icon: const Icon(Icons.add),
            label: const Text('Nouveau Produit'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Consumer<ProduitProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const LoadingIndicator(message: 'Chargement des produits...');
          }

          if (provider.error != null) {
            return ErrorDisplay(
              message: provider.error!,
              onRetry: () => provider.loadProduits(),
            );
          }

          if (provider.produits.isEmpty) {
            return const EmptyState(
              message: 'Aucun produit trouvé',
              icon: Icons.inventory,
            );
          }

          return Card(
            margin: const EdgeInsets.all(AppSpacing.sm),
            child: ListView.separated(
              itemCount: provider.produits.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final produit = provider.produits[index];
                final stockColor = produit.stockActuel <= produit.stockMinimum
                    ? Colors.red
                    : produit.stockActuel <= produit.stockMinimum * 1.5
                        ? Colors.orange
                        : Colors.green;

                return ListTile(
                  leading: Icon(Icons.inventory_2, color: stockColor),
                  title: Text(produit.designation),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (produit.codeBarre != null)
                        Text('Code-barres: ${produit.codeBarre}'),
                      Text('Stock: ${produit.stockActuel} ${produit.unite}'),
                      if (produit.categorie != null)
                        Text('Catégorie: ${produit.categorie}'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            Formatters.formatCurrency(produit.prixUnitaire),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: stockColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              produit.actif ? 'Actif' : 'Inactif',
                              style: TextStyle(
                                fontSize: 12,
                                color: stockColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showProduitForm(context, produit: produit),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteProduit(context, produit),
                      ),
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

  void _showProduitForm(BuildContext context, {Produit? produit}) {
    showDialog(
      context: context,
      builder: (context) => ProduitFormScreen(produit: produit),
    );
  }

  Future<void> _deleteProduit(BuildContext context, Produit produit) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Voulez-vous vraiment supprimer le produit ${produit.designation}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await context.read<ProduitProvider>().deleteProduit(produit.id!);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Produit supprimé avec succès'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
