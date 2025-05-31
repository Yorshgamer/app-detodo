import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../widgets/custom_textfield.dart';
import 'user_home_screen.dart';
import 'admin_home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool cargando = false;
  String error = '';

  Future<void> login() async {
    setState(() {
      cargando = true;
      error = '';
    });

    try {
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final uid = cred.user!.uid;
      final userDoc =
          await FirebaseFirestore.instance.collection('usuarios').doc(uid).get();

      if (!userDoc.exists) {
        setState(() => error = 'El usuario no existe en la base de datos.');
        return;
      }

      final data = userDoc.data()!;
      final esAdmin = data['esAdmin'] ?? false;

      if (esAdmin) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminHomeScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const UserHomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() => error = e.message ?? 'Error desconocido');
    } finally {
      setState(() => cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          children: [
            const SizedBox(height: 30),
            Center(
              child: Image.asset(
                'assets/images/logo.png',
                width: 130,
                height: 130,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Iniciar Sesión',
              style: TextStyle(
                color: Colors.cyanAccent,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 32),
            CustomTextField(
              hint: 'Correo',
              controller: emailController,
              hintColor: Colors.white70,
              textColor: Colors.white,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              hint: 'Contraseña',
              controller: passwordController,
              obscureText: true,
              hintColor: Colors.white70,
              textColor: Colors.white,
            ),
            const SizedBox(height: 20),
            if (error.isNotEmpty)
              Text(
                error,
                style: const TextStyle(color: Colors.redAccent),
              ),
            const SizedBox(height: 20),
            cargando
                ? const CircularProgressIndicator(color: Colors.cyanAccent)
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyanAccent,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: login,
                      child: const Text('Entrar'),
                    ),
                  ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                );
              },
              child: const Text(
                '¿No tienes cuenta? Regístrate aquí',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }
}