import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HistorialScreen extends StatelessWidget {
  const HistorialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text("Debes iniciar sesión para ver el historial")),
      );
    }

    final comprasRef = FirebaseFirestore.instance
        .collection('historial_compras')
        .doc(uid)
        .collection('compras')
        .orderBy('fecha', descending: true);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Compras')),
      backgroundColor: Colors.black,
      body: StreamBuilder<QuerySnapshot>(
        stream: comprasRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.cyanAccent));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('Aún no tienes compras', style: TextStyle(color: Colors.white70)),
            );
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final productos = List<Map<String, dynamic>>.from(data['productos']);
              final total = data['total'];
              final fecha = (data['fecha'] as Timestamp).toDate();

              return Card(
                color: Colors.grey[900],
                margin: const EdgeInsets.all(10),
                child: ExpansionTile(
                  title: Text(
                    'Compra - S/ ${total.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Fecha: ${fecha.day}/${fecha.month}/${fecha.year} ${fecha.hour}:${fecha.minute}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  children: productos.map((prod) {
                    return ListTile(
                      title: Text(prod['nombre'], style: const TextStyle(color: Colors.white)),
                      subtitle: Text('S/ ${prod['precio']}', style: const TextStyle(color: Colors.cyanAccent)),
                      leading: Image.network(
                        prod['imagenURL'],
                        width: 40,
                        errorBuilder: (_, __, ___) => const Icon(Icons.image),
                      ),
                    );
                  }).toList(),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}