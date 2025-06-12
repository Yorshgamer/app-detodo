import 'package:flutter/material.dart';
import 'catalogo_screen.dart'; // ya existente
import 'contacto_screen.dart'; // por crear
import 'perfil_screen.dart';   // por crear

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
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Colors.deepPurple,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.contact_phone), label: 'Contacto'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
