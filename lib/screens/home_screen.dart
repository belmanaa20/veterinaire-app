import 'package:flutter/material.dart';
import '../config/app_constants.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/connection_status_widget.dart';
import '../services/sync_service.dart';
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
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: AppConstants.appName,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              final syncService = SyncService();
              await syncService.syncAll();
              
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✅ Synchronisé!')),
                );
              }
            },
            tooltip: 'Synchroniser',
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // TODO: Show notifications
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'settings') {
                // TODO: Navigate to settings
              } else if (value == 'about') {
                _showAboutDialog();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 8),
                    Text('Paramètres'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'about',
                child: Row(
                  children: [
                    Icon(Icons.info),
                    SizedBox(width: 8),
                    Text('À propos'),
                  ],
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.only(right: 16, left: 8),
            child: ConnectionStatusWidget(),
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard),
            label: 'Tableau de bord',
          ),
          NavigationDestination(
            icon: Icon(Icons.people),
            label: 'Clients',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory),
            label: 'Produits',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long),
            label: 'Factures',
          ),
        ],
      ),
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

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tableau de bord',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 24),
          // Quick stats cards
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildStatCard(
                context,
                title: 'Factures ouvertes',
                value: '0',
                icon: Icons.receipt_long,
                color: Colors.blue,
              ),
              _buildStatCard(
                context,
                title: 'Factures à échéance',
                value: '0',
                icon: Icons.warning,
                color: Colors.orange,
              ),
              _buildStatCard(
                context,
                title: 'Produits stock faible',
                value: '0',
                icon: Icons.inventory,
                color: Colors.red,
              ),
              _buildStatCard(
                context,
                title: 'Clients actifs',
                value: '0',
                icon: Icons.people,
                color: Colors.green,
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Quick actions
          Text(
            'Actions rapides',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildQuickAction(
                context,
                label: 'Nouvelle Facture',
                icon: Icons.add_circle,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NouvelleFactureScreen(),
                    ),
                  );
                },
              ),
              _buildQuickAction(
                context,
                label: 'Nouveau Client',
                icon: Icons.person_add,
                onTap: () {
                  // TODO: Navigate to client form
                },
              ),
              _buildQuickAction(
                context,
                label: 'Nouveau Produit',
                icon: Icons.add_box,
                onTap: () {
                  // TODO: Navigate to product form
                },
              ),
              _buildQuickAction(
                context,
                label: 'Stock Faible',
                icon: Icons.warning_amber,
                onTap: () {
                  // TODO: Show low stock products
                },
              ),
            ],
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
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context, {
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 120,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
