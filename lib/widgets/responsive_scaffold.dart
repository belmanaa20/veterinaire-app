import 'package:flutter/material.dart';
import '../utils/platform_utils.dart';
import 'desktop_sidebar.dart';

class ResponsiveScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<Widget>? actions;
  final FloatingActionButton? floatingActionButton;

  const ResponsiveScaffold({
    super.key,
    required this.title,
    required this.body,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.actions,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    final isWideScreen = PlatformUtils.isWideScreen(context);

    if (isWideScreen) {
      // Desktop layout with sidebar
      return Scaffold(
        body: Row(
          children: [
            DesktopSidebar(
              selectedIndex: selectedIndex,
              onDestinationSelected: onDestinationSelected,
            ),
            Expanded(
              child: Column(
                children: [
                  _buildDesktopAppBar(context),
                  Expanded(child: body),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: floatingActionButton,
      );
    } else {
      // Mobile layout with bottom navigation
      return Scaffold(
        appBar: AppBar(
          title: Text(title),
          actions: actions,
        ),
        body: body,
        bottomNavigationBar: NavigationBar(
          selectedIndex: selectedIndex < 4 ? selectedIndex : 0,
          onDestinationSelected: onDestinationSelected,
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
        floatingActionButton: floatingActionButton,
      );
    }
  }

  Widget _buildDesktopAppBar(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
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
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const Spacer(),
          if (actions != null) ...actions!,
        ],
      ),
    );
  }
}
