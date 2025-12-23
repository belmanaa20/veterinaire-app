import 'package:flutter/material.dart';
import '../../models/client.dart';
import '../../repositories/client_repository.dart';
import '../../utils/platform_utils.dart';
import '../../config/theme_config.dart';
import 'client_form_screen.dart';
import 'client_details_screen.dart';

class ClientsListScreen extends StatefulWidget {
  const ClientsListScreen({super.key});

  @override
  State<ClientsListScreen> createState() => _ClientsListScreenState();
}

class _ClientsListScreenState extends State<ClientsListScreen> {
  final ClientRepository _repository = ClientRepository();
  List<Client> _clients = [];
  List<Client> _filteredClients = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadClients();
  }

  Future<void> _loadClients() async {
    setState(() => _isLoading = true);
    try {
      final clients = await _repository.getAllClients();
      if (mounted) {
        setState(() {
          _clients = clients;
          _filteredClients = clients;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de chargement: $e'),
            backgroundColor: ThemeConfig.errorColor,
          ),
        );
      }
    }
  }

  void _filterClients(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredClients = _clients;
      } else {
        _filteredClients = _clients.where((client) {
          final nameLower = client.nom.toLowerCase();
          final phoneLower = client.telephone?.toLowerCase() ?? '';
          final queryLower = query.toLowerCase();
          return nameLower.contains(queryLower) ||
              phoneLower.contains(queryLower);
        }).toList();
      }
    });
  }

  Future<void> _deleteClient(Client client) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Êtes-vous sûr de vouloir supprimer ${client.nom}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: ThemeConfig.errorColor,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final success = await _repository.deleteClient(client.id);
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Client supprimé avec succès'),
              backgroundColor: ThemeConfig.successColor,
            ),
          );
          _loadClients();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur de suppression: $e'),
              backgroundColor: ThemeConfig.errorColor,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWideScreen = PlatformUtils.isWideScreen(context);

    return Scaffold(
      body: Column(
        children: [
          // Header with search and actions
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Rechercher par nom ou téléphone...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: _filterClients,
                  ),
                ),
                const SizedBox(width: 16),
                FilledButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ClientFormScreen(),
                      ),
                    );
                    if (result == true) {
                      _loadClients();
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Nouveau Client'),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredClients.isEmpty
                    ? _buildEmptyState()
                    : isWideScreen
                        ? _buildDataTable()
                        : _buildMobileList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _searchQuery.isEmpty ? Icons.people_outline : Icons.search_off,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 24),
          Text(
            _searchQuery.isEmpty ? 'Aucun client' : 'Aucun résultat',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty
                ? 'Ajoutez votre premier client pour commencer'
                : 'Essayez une autre recherche',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
          ),
          if (_searchQuery.isEmpty) ...[
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ClientFormScreen(),
                  ),
                );
                if (result == true) {
                  _loadClients();
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Ajouter un client'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDataTable() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Card(
        child: DataTable(
          headingRowHeight: 56,
          dataRowHeight: 64,
          columns: const [
            DataColumn(label: Text('Nom')),
            DataColumn(label: Text('Téléphone')),
            DataColumn(label: Text('Type d\'élevage')),
            DataColumn(label: Text('Adresse')),
            DataColumn(label: Text('Actions')),
          ],
          rows: _filteredClients.map((client) {
            return DataRow(
              cells: [
                DataCell(
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: ThemeConfig.primaryColor,
                        child: Text(
                          client.nom.substring(0, 1).toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          client.nom,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  onTap: () => _navigateToDetails(client),
                ),
                DataCell(
                  Text(client.telephone ?? '-'),
                  onTap: () => _navigateToDetails(client),
                ),
                DataCell(
                  Text(client.culture ?? '-'),
                  onTap: () => _navigateToDetails(client),
                ),
                DataCell(
                  Text(
                    client.adresse ?? '-',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () => _navigateToDetails(client),
                ),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.visibility_outlined),
                        tooltip: 'Voir détails',
                        onPressed: () => _navigateToDetails(client),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        tooltip: 'Modifier',
                        onPressed: () => _navigateToEdit(client),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        tooltip: 'Supprimer',
                        color: ThemeConfig.errorColor,
                        onPressed: () => _deleteClient(client),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMobileList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredClients.length,
      itemBuilder: (context, index) {
        final client = _filteredClients[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: ThemeConfig.primaryColor,
              child: Text(
                client.nom.substring(0, 1).toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(
              client.nom,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                if (client.telephone != null)
                  Row(
                    children: [
                      const Icon(Icons.phone, size: 16),
                      const SizedBox(width: 4),
                      Text(client.telephone!),
                    ],
                  ),
                if (client.culture != null) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.pets, size: 16),
                      const SizedBox(width: 4),
                      Text(client.culture!),
                    ],
                  ),
                ],
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'view') {
                  _navigateToDetails(client);
                } else if (value == 'edit') {
                  _navigateToEdit(client);
                } else if (value == 'delete') {
                  _deleteClient(client);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'view',
                  child: Row(
                    children: [
                      Icon(Icons.visibility_outlined),
                      SizedBox(width: 12),
                      Text('Voir détails'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined),
                      SizedBox(width: 12),
                      Text('Modifier'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, color: ThemeConfig.errorColor),
                      SizedBox(width: 12),
                      Text(
                        'Supprimer',
                        style: TextStyle(color: ThemeConfig.errorColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            onTap: () => _navigateToDetails(client),
          ),
        );
      },
    );
  }

  void _navigateToDetails(Client client) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClientDetailsScreen(client: client),
      ),
    );
  }

  Future<void> _navigateToEdit(Client client) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClientFormScreen(client: client),
      ),
    );
    if (result == true) {
      _loadClients();
    }
  }
}
