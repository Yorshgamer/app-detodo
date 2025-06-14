import 'package:flutter/material.dart';
import 'catalogo_screen.dart';
import 'contacto_screen.dart';
import 'perfil_screen.dart';

class MainNavScreen extends StatefulWidget {
  final bool modoInvitado;
  const MainNavScreen({super.key, required this.modoInvitado});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final paginas = [
      CatalogoScreen(modoInvitado: widget.modoInvitado),
      const ContactoScreen(),
      const PerfilScreen(),
    ];

    return Scaffold(
      body: paginas[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: _getSelectedColor(_currentIndex),
        unselectedItemColor: Colors.white70,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.contact_phone),
            label: 'Contacto',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }

  /// Retorna el color según el ítem seleccionado
  Color _getSelectedColor(int index) {
    switch (index) {
      case 0:
        return Colors.cyanAccent; // Inicio
      case 1:
        return Colors.amberAccent; // Contacto
      case 2:
        return Colors.deepPurpleAccent; // Perfil
      default:
        return Colors.cyanAccent;
    }
  }
}