import 'package:flutter/material.dart';
import '../config/app_constants.dart';
import '../widgets/responsive_scaffold.dart';
import 'clients/clients_list_screen.dart';
import 'produits/produits_list_screen.dart';
import 'factures/factures_list_screen.dart';
import 'factures/nouvelle_facture_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardTab(),
    const ClientsListScreen(),
    const ProduitsListScreen(),
    const FacturesListScreen(),
    const SettingsTab(),
  ];

  final List<String> _titles = [
    'Tableau de bord',
    'Gestion des Clients',
    'Gestion des Produits',
    'Gestion des Factures',
    'Paramètres',
  ];

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: _titles[_selectedIndex],
      selectedIndex: _selectedIndex,
      onDestinationSelected: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          tooltip: 'Notifications',
          onPressed: () {
            // TODO: Show notifications
          },
        ),
        const SizedBox(width: 8),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            if (value == 'about') {
              _showAboutDialog();
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'about',
              child: Row(
                children: [
                  Icon(Icons.info_outline),
                  SizedBox(width: 12),
                  Text('À propos'),
                ],
              ),
            ),
          ],
        ),
      ],
      body: _screens[_selectedIndex],
      floatingActionButton: _selectedIndex == 3
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NouvelleFactureScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Nouvelle Facture'),
            )
          : null,
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: AppConstants.appName,
      applicationVersion: AppConstants.appVersion,
      applicationLegalese: '© 2025 Pharmacie Vétérinaire',
      children: [
        const SizedBox(height: 16),
        const Text(
          'Application de gestion pour pharmacie vétérinaire avec système de facturation sur 45 jours.',
        ),
      ],
    );
  }
}

// Settings Tab
class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: ListTile(
            leading: const Icon(Icons.business),
            title: const Text('Informations du magasin'),
            subtitle: const Text('Nom, adresse, téléphone, NIF'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Navigate to store settings
            },
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.image),
            title: const Text('Logo et signatures'),
            subtitle: const Text('Logo, signature, cachet'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Navigate to branding settings
            },
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.sync),
            title: const Text('Synchronisation'),
            subtitle: const Text('Synchroniser les données avec le serveur'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Trigger manual sync
            },
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.delete_outline),
            title: const Text('Effacer le cache'),
            subtitle: const Text('Supprimer les données locales'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Clear cache with confirmation
            },
          ),
        ),
      ],
    );
  }
}

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Cards Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 1366 ? 4 : (constraints.maxWidth >= 768 ? 2 : 1);
              return GridView.count(
                crossAxisCount: columns,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.5,
                children: [
                  _buildStatCard(
                    context,
                    title: 'Factures ouvertes',
                    value: '0',
                    icon: Icons.receipt_long,
                    color: const Color(0xFF1976D2), // Trust Blue
                    trend: '+0%',
                  ),
                  _buildStatCard(
                    context,
                    title: 'Factures à échéance',
                    value: '0',
                    icon: Icons.warning_amber,
                    color: const Color(0xFFF9A825), // Warning Yellow
                    trend: '+0%',
                  ),
                  _buildStatCard(
                    context,
                    title: 'Stock faible',
                    value: '0',
                    icon: Icons.inventory_2_outlined,
                    color: const Color(0xFFD32F2F), // Error Red
                    trend: '0',
                  ),
                  _buildStatCard(
                    context,
                    title: 'Clients actifs',
                    value: '0',
                    icon: Icons.people_outline,
                    color: const Color(0xFF388E3C), // Success Green
                    trend: '+0%',
                  ),
                ],
              );
            },
          ),
          
          const SizedBox(height: 32),
          
          // Quick Actions
          Text(
            'Actions rapides',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 768;
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _buildQuickActionCard(
                    context,
                    label: 'Nouvelle Facture',
                    icon: Icons.add_circle_outline,
                    color: const Color(0xFF2E7D32),
                    width: isWide ? 200 : null,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NouvelleFactureScreen(),
                        ),
                      );
                    },
                  ),
                  _buildQuickActionCard(
                    context,
                    label: 'Nouveau Client',
                    icon: Icons.person_add_outlined,
                    color: const Color(0xFF1976D2),
                    width: isWide ? 200 : null,
                    onTap: () {
                      // TODO: Navigate to client form
                    },
                  ),
                  _buildQuickActionCard(
                    context,
                    label: 'Nouveau Produit',
                    icon: Icons.add_box_outlined,
                    color: const Color(0xFFF57C00),
                    width: isWide ? 200 : null,
                    onTap: () {
                      // TODO: Navigate to product form
                    },
                  ),
                  _buildQuickActionCard(
                    context,
                    label: 'Voir Stock Faible',
                    icon: Icons.warning_amber_outlined,
                    color: const Color(0xFFD32F2F),
                    width: isWide ? 200 : null,
                    onTap: () {
                      // TODO: Show low stock products
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String trend,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 32),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    trend,
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    double? width,
  }) {
    return SizedBox(
      width: width,
      child: Card(
        elevation: 1,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisSize: width == null ? MainAxisSize.min : MainAxisSize.max,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Flexible(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
