import 'package:flutter/material.dart';
import '../config/theme_config.dart';
import '../utils/connectivity_monitor.dart';

class DesktopSidebar extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const DesktopSidebar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  State<DesktopSidebar> createState() => _DesktopSidebarState();
}

class _DesktopSidebarState extends State<DesktopSidebar> {
  final _connectivityMonitor = ConnectivityMonitor();
  bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    _isOnline = _connectivityMonitor.isOnline;
    
    // Listen to connectivity changes
    _connectivityMonitor.onlineStream.listen((isOnline) {
      if (mounted) {
        setState(() {
          _isOnline = isOnline;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Logo/Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ThemeConfig.primaryColor,
                  ThemeConfig.primaryColor.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.medical_services,
                    size: 36,
                    color: ThemeConfig.primaryColor,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'PHARMACIE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const Text(
                  'VÉTÉRINAIRE',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _buildNavItem(
                  context,
                  icon: Icons.dashboard,
                  label: 'Tableau de bord',
                  index: 0,
                ),
                _buildNavItem(
                  context,
                  icon: Icons.people,
                  label: 'Clients',
                  index: 1,
                ),
                _buildNavItem(
                  context,
                  icon: Icons.inventory,
                  label: 'Produits',
                  index: 2,
                ),
                _buildNavItem(
                  context,
                  icon: Icons.receipt_long,
                  label: 'Factures',
                  index: 3,
                ),
                const Divider(height: 32),
                _buildNavItem(
                  context,
                  icon: Icons.settings,
                  label: 'Paramètres',
                  index: 4,
                  isSecondary: true,
                ),
              ],
            ),
          ),
          
          // Footer with connectivity status
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Divider(),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: (_isOnline ? ThemeConfig.successColor : ThemeConfig.errorColor)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isOnline ? Icons.cloud_done : Icons.cloud_off,
                        size: 16,
                        color: _isOnline ? ThemeConfig.successColor : ThemeConfig.errorColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isOnline ? 'En ligne' : 'Hors ligne',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _isOnline ? ThemeConfig.successColor : ThemeConfig.errorColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int index,
    bool isSecondary = false,
  }) {
    final isSelected = widget.selectedIndex == index;
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => widget.onDestinationSelected(index),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? ThemeConfig.primaryColor.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: isSelected
                  ? Border.all(
                      color: ThemeConfig.primaryColor,
                      width: 2,
                    )
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isSelected
                      ? ThemeConfig.primaryColor
                      : (isSecondary
                          ? theme.textTheme.bodySmall?.color
                          : theme.textTheme.bodyMedium?.color),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isSelected
                          ? ThemeConfig.primaryColor
                          : (isSecondary
                              ? theme.textTheme.bodySmall?.color
                              : theme.textTheme.bodyMedium?.color),
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      fontSize: 14,
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
