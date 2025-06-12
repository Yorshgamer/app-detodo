import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../auth/login_screen.dart';
import '../auth/register_screen.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    final bool estaLogueado = user != null;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: estaLogueado ? _buildPerfil(context, user) : _buildInvitado(context),
      ),
    );
  }

  Widget _buildPerfil(BuildContext context, User user) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.account_circle, size: 100, color: Colors.cyanAccent),
        const SizedBox(height: 20),
        Text(
          user.email ?? 'Usuario',
          style: const TextStyle(color: Colors.white, fontSize: 20),
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
          ),
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
          child: const Text('Cerrar sesión'),
        ),
      ],
    );
  }

  Widget _buildInvitado(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.person_outline, size: 100, color: Colors.white70),
        const SizedBox(height: 20),
        const Text(
          'Estás navegando como invitado',
          style: TextStyle(color: Colors.white70, fontSize: 18),
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.cyanAccent,
            foregroundColor: Colors.black,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          },
          child: const Text('Iniciar Sesión'),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RegisterScreen()),
            );
          },
          child: const Text(
            '¿No tienes cuenta? Regístrate',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      ],
    );
  }
}
