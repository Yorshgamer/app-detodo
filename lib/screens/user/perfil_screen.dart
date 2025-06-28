import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  final picker = ImagePicker();

  String? imagenBase64;
  File? imagenSeleccionada;

  // Controladores para editar campos
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController celularController = TextEditingController();
  final TextEditingController direccionController = TextEditingController();

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

      final data = snapshot.data();

      setState(() {
        user = currentUser;
        nombreController.text = data?['nombre'] ?? '';
        celularController.text = data?['celular'] ?? '';
        direccionController.text = data?['direccion'] ?? '';
        fechaRegistro = currentUser.metadata.creationTime?.toLocal();
        imagenBase64 = data?['fotoPerfilBase64'];
      });
    }
  }

  Future<void> seleccionarImagen(ImageSource source) async {
    final picked = await picker.pickImage(source: source, imageQuality: 50);
    if (picked == null) return;

    setState(() {
      imagenSeleccionada = File(picked.path);
    });
  }

  Future<void> subirImagen() async {
    if (user == null || imagenSeleccionada == null) return;

    final bytes = await imagenSeleccionada!.readAsBytes();
    final base64Image = base64Encode(bytes);

    await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user!.uid)
        .set({'fotoPerfilBase64': base64Image}, SetOptions(merge: true));

    setState(() {
      imagenBase64 = base64Image;
      imagenSeleccionada = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Imagen de perfil actualizada')),
    );
  }

  Future<void> guardarDatos() async {
    if (nombreController.text.trim().isEmpty ||
        celularController.text.trim().isEmpty ||
        direccionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa todos los campos')),
      );
      return;
    }

    await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user!.uid)
        .set({
      'nombre': nombreController.text.trim(),
      'celular': celularController.text.trim(),
      'direccion': direccionController.text.trim(),
    }, SetOptions(merge: true));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Datos actualizados con éxito')),
    );
  }

  Widget _buildPerfil() {
    ImageProvider? imageProvider;

    if (imagenSeleccionada != null) {
      imageProvider = FileImage(imagenSeleccionada!);
    } else if (imagenBase64 != null) {
      try {
        final bytes = base64Decode(imagenBase64!);
        imageProvider = MemoryImage(bytes);
      } catch (_) {}
    }

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 70,
                backgroundImage: imageProvider,
                backgroundColor: Colors.white10,
                child: imageProvider == null
                    ? const Icon(Icons.person, size: 70, color: Colors.cyanAccent)
                    : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => seleccionarImagen(ImageSource.gallery),
                icon: const Icon(Icons.image),
                label: const Text("Desde galería"),
              ),
              ElevatedButton.icon(
                onPressed: () => seleccionarImagen(ImageSource.camera),
                icon: const Icon(Icons.camera_alt),
                label: const Text("Desde cámara"),
              ),
              if (imagenSeleccionada != null)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  onPressed: subirImagen,
                  icon: const Icon(Icons.check),
                  label: const Text("Guardar imagen"),
                ),
              const SizedBox(height: 30),

              _campoEditable('Nombre completo', nombreController),
              _campoEditable('Celular', celularController, tipo: TextInputType.phone),
              _campoEditable('Dirección', direccionController),

              _datoCentrado(
                'Miembro desde',
                fechaRegistro != null
                    ? '${fechaRegistro!.day}/${fechaRegistro!.month}/${fechaRegistro!.year}'
                    : 'Desconocido',
              ),

              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: guardarDatos,
                icon: const Icon(Icons.save),
                label: const Text('Guardar cambios'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyanAccent,
                  foregroundColor: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/historial'),
                icon: const Icon(Icons.history),
                label: const Text('Ver Historial de Compras'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.logout),
                label: const Text('Cerrar sesión'),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  if (!mounted) return;
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
        Positioned(
          right: 10,
          bottom: 10,
          child: Opacity(
            opacity: 0.3,
            child: Text(
              'UID: ${user?.uid ?? ""}',
              style: const TextStyle(fontSize: 10, color: Colors.white),
            ),
          ),
        )
      ],
    );
  }

  Widget _campoEditable(String label, TextEditingController controller,
      {TextInputType tipo = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        keyboardType: tipo,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white24)),
          focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.cyanAccent)),
        ),
      ),
    );
  }

  Widget _datoCentrado(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          Text(titulo,
              style: const TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 4),
          Text(valor,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 16)),
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
          child: const Text('¿No tienes cuenta? Regístrate',
              style: TextStyle(color: Colors.white70)),
        ),
      ],
    );
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
}
