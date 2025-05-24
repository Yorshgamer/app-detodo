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

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _verificarEstado();
  }

  Future<void> _verificarEstado() async {
    await Future.delayed(const Duration(seconds: 2)); // un splash chill

    final prefs = await SharedPreferences.getInstance();
    final primeraVez = prefs.getBool('primera_vez') ?? true;

    if (primeraVez) {
      await prefs.setBool('primera_vez', false);
      Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (_) => const CatalogoScreen(modoInvitado: true)),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } else {
      final snap = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .get();

      final data = snap.data();
      if (data == null) {
        Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
        return;
      }

      final userModel = UserModel.fromMap(user.uid, data);

      if (userModel.esAdmin) {
        Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const AdminHomeScreen()),
        );
      } else {
        Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const UserHomeScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
