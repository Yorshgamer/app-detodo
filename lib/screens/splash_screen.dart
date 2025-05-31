import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';
import '../screens/user_home_screen.dart';
import '../screens/admin_home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/catalogo_screen.dart'; // La crearás después

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();

    Future.delayed(const Duration(seconds: 3), () {
      _verificarEstado();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _verificarEstado() async {
    await Future.delayed(const Duration(seconds: 3)); // Splash chill

    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        final snap = await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user.uid)
            .get();

        final data = snap.data();

        if (data != null) {
          final userModel = UserModel.fromMap(user.uid, data);

          if (userModel.esAdmin) {
            // Admin detectado
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const AdminHomeScreen()),
            );
            return;
          }
        }

        // Usuario logueado normal
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const CatalogoScreen(modoInvitado: false),
          ),
        );
      } catch (e) {
        // Si falla algo, lo manda como invitado al catálogo
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const CatalogoScreen(modoInvitado: true),
          ),
        );
      }
    } else {
      // No logueado => catálogo como invitado
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const CatalogoScreen(modoInvitado: true),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFBC02D),
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/logo.png', width: 150, height: 150),
              const SizedBox(height: 20),
              const CircularProgressIndicator(
                color: Colors.deepPurple, // o tu color principal
              ),
              const SizedBox(height: 10),
              const Text(
                "Cargando DeTodo...",
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
