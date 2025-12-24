import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';
import 'dashboard/dashboard_screen.dart';
import 'clients/clients_list_screen.dart';
import 'produits/produits_list_screen.dart';
import 'factures/factures_list_screen.dart';
import 'parametres/parametres_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const ClientsListScreen(),
    const ProduitsListScreen(),
    const FacturesListScreen(),
    const ParametresScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          AppSidebar(
            selectedIndex: _selectedIndex,
            onItemSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
          Expanded(
            child: _screens[_selectedIndex],
          ),
        ],
      ),
    );
  }
}
