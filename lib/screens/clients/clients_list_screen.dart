import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme_config.dart';
import '../../providers/client_provider.dart';
import '../../widgets/common_widgets.dart';
import '../../models/client.dart';
import 'client_form_screen.dart';

class ClientsListScreen extends StatefulWidget {
  const ClientsListScreen({super.key});

  @override
  State<ClientsListScreen> createState() => _ClientsListScreenState();
}

class _ClientsListScreenState extends State<ClientsListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClientProvider>().loadClients();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Gestion des Clients'),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<ClientProvider>().loadClients(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Rechercher un client...',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      if (value.isEmpty) {
                        context.read<ClientProvider>().loadClients();
                      } else {
                        context.read<ClientProvider>().searchClients(value);
                      }
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                ElevatedButton.icon(
                  onPressed: () => _showClientForm(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Nouveau Client'),
                ),
              ],
            ),
          ),

          // Client List
          Expanded(
            child: Consumer<ClientProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const LoadingIndicator(message: 'Chargement des clients...');
                }

                if (provider.error != null) {
                  return ErrorDisplay(
                    message: provider.error!,
                    onRetry: () => provider.loadClients(),
                  );
                }

                if (provider.clients.isEmpty) {
                  return EmptyState(
                    message: 'Aucun client trouvé.\nAjoutez votre premier client!',
                    icon: Icons.people,
                    actionLabel: 'Ajouter un client',
                    onAction: () => _showClientForm(context),
                  );
                }

                return Card(
                  margin: const EdgeInsets.all(AppSpacing.sm),
                  child: ListView.separated(
                    itemCount: provider.clients.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final client = provider.clients[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primaryGreen,
                          child: Text(
                            client.nom[0].toUpperCase(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(client.fullName),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (client.nomAnimal != null)
                              Text('🐾 ${client.nomAnimal} (${client.typeAnimal ?? 'N/A'})'),
                            if (client.telephone != null)
                              Text('📞 ${client.telephone}'),
                            if (client.email != null)
                              Text('📧 ${client.email}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _showClientForm(context, client: client),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteClient(context, client),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showClientForm(BuildContext context, {Client? client}) {
    showDialog(
      context: context,
      builder: (context) => ClientFormScreen(client: client),
    );
  }

  Future<void> _deleteClient(BuildContext context, Client client) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Voulez-vous vraiment supprimer le client ${client.fullName}?'),
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
        await context.read<ClientProvider>().deleteClient(client.id!);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Client supprimé avec succès'),
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
