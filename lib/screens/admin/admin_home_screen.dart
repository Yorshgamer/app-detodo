import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../user/catalogo_screen.dart';
import 'dashboard_screen.dart';
import 'productos_list_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _selectedIndex = 0;

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const CatalogoScreen(modoInvitado: true)),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pantallas = const [
      DashboardScreen(),
      ProductosListScreen(),
    ];

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            backgroundColor: Colors.black,
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() => _selectedIndex = index);
            },
            labelType: NavigationRailLabelType.all,
            leading: Column(
              children: [
                const SizedBox(height: 16),
                Image.asset(
                  'assets/images/logo.png',
                  height: 60,
                ),
                const SizedBox(height: 24),
              ],
            ),
            trailing: Column(
              children: [
                const SizedBox(height: 20),
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.redAccent),
                  onPressed: _logout,
                  tooltip: 'Cerrar sesión',
                ),
              ],
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard_outlined, color: Colors.white),
                selectedIcon: Icon(Icons.dashboard, color: Colors.cyanAccent),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.inventory_2_outlined, color: Colors.white),
                selectedIcon: Icon(Icons.inventory_2, color: Colors.cyanAccent),
                label: Text('Productos'),
              ),
            ],
            selectedIconTheme: const IconThemeData(color: Colors.cyanAccent),
            unselectedIconTheme: const IconThemeData(color: Colors.white70),
            selectedLabelTextStyle: const TextStyle(color: Colors.cyanAccent),
            unselectedLabelTextStyle: const TextStyle(color: Colors.white54),
          ),
          const VerticalDivider(thickness: 1, width: 1, color: Colors.white24),
          Expanded(
            child: Container(
              color: Colors.black,
              padding: const EdgeInsets.all(16),
              child: IndexedStack(
                index: _selectedIndex,
                children: pantallas,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
