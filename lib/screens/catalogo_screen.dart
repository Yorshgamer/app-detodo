import 'package:flutter/material.dart';
import 'login_screen.dart'; // Asegúrate de importar esto
import 'package:cloud_firestore/cloud_firestore.dart';

class CatalogoScreen extends StatelessWidget {
  final bool modoInvitado;

  const CatalogoScreen({super.key, required this.modoInvitado});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Catálogo (${modoInvitado ? 'Invitado' : 'Usuario'})'),
        actions: [
          if (modoInvitado)
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              child: const Text(
                'Iniciar sesión',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('productos').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No hay productos aún 😢'));
          }

          final productos = snapshot.data!.docs;

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3 / 4,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: productos.length,
            itemBuilder: (context, index) {
              final prod = productos[index];
              final nombre = prod['nombre'];
              final precio = prod['precio'];
              final tipo = prod['tipo'];

              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.shopping_bag, size: 40),
                      const SizedBox(height: 12),
                      Text(nombre, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text('Precio: \$${precio.toStringAsFixed(2)}'),
                      Text('Tipo: $tipo'),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () {
                          // Aquí va lógica de agregar al carrito (después lo hacemos)
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('¡Agregado al carrito!')),
                          );
                        },
                        child: const Text('Agregar'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
