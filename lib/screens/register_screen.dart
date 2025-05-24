import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'user_home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nombreController = TextEditingController();

  bool cargando = false;
  String error = '';

  Future<void> registrar() async {
    setState(() {
      cargando = true;
      error = '';
    });

    try {
      // Crear usuario en Firebase Auth
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Guardar datos extra en Firestore
      final userDoc = FirebaseFirestore.instance.collection('usuarios').doc(cred.user!.uid);

      await userDoc.set({
        'nombre': nombreController.text.trim(),
        'email': emailController.text.trim(),
        'esAdmin': false, // Siempre falso en registro normal
      });

      // Redirigir a home usuario
      Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (_) => const UserHomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() => error = e.message ?? 'Error desconocido');
    } finally {
      setState(() => cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: nombreController, decoration: const InputDecoration(labelText: 'Nombre')),
            TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Correo')),
            TextField(controller: passwordController, decoration: const InputDecoration(labelText: 'Contraseña'), obscureText: true),
            const SizedBox(height: 16),
            if (error.isNotEmpty) Text(error, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            cargando
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: registrar,
                  child: const Text('Registrarse'),
                ),
          ],
        ),
      ),
    );
  }
}
