import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../auth/login_screen.dart';
import '../auth/register_screen.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  User? user;
  String? nombreUsuario;
  String? proveedor;
  DateTime? fechaRegistro;

  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();
  }

  Future<void> _cargarDatosUsuario() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(currentUser.uid)
          .get();

      setState(() {
        user = currentUser;
        nombreUsuario = snapshot.data()?['nombre'] ?? 'Sin nombre';
        proveedor = currentUser.providerData.isNotEmpty
            ? currentUser.providerData[0].providerId
            : 'Firebase';
        fechaRegistro = currentUser.metadata.creationTime?.toLocal();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final estaLogueado = user != null;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: estaLogueado ? _buildPerfil() : _buildInvitado(context),
        ),
      ),
    );
  }

  Widget _buildPerfil() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.account_circle, size: 100, color: Colors.cyanAccent),
        const SizedBox(height: 20),
        Text(
          nombreUsuario ?? 'Cargando...',
          style: const TextStyle(
            color: Colors.cyanAccent,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 20),
        _datoCentrado('Correo', user?.email ?? ''),
        _datoCentrado('UID', user?.uid ?? ''),
        _datoCentrado('Proveedor', proveedor ?? ''),
        _datoCentrado(
          'Desde',
          fechaRegistro != null
              ? '${fechaRegistro!.day}/${fechaRegistro!.month}/${fechaRegistro!.year}'
              : 'Desconocido',
        ),
        const SizedBox(height: 30),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          icon: const Icon(Icons.logout),
          label: const Text('Cerrar sesión'),
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
      ],
    );
  }

  Widget _datoCentrado(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      child: Column(
        children: [
          Text(
            titulo,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            valor,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
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
        ElevatedButton.icon(
          icon: const Icon(Icons.login),
          label: const Text('Iniciar Sesión'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.cyanAccent,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          },
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