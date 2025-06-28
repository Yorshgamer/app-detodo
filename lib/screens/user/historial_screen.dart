import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HistorialScreen extends StatelessWidget {
  const HistorialScreen({super.key});

  String convertirEnlaceDriveADirecto(String enlaceDrive) {
    final regExp = RegExp(r'/d/([a-zA-Z0-9_-]+)');
    final match = regExp.firstMatch(enlaceDrive);
    if (match != null && match.groupCount >= 1) {
      final id = match.group(1);
      return 'https://drive.google.com/uc?export=view&id=$id';
    } else {
      return enlaceDrive;
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            "Debes iniciar sesión para ver el historial",
            style: TextStyle(color: Colors.white70),
          ),
        ),
        backgroundColor: Colors.black,
      );
    }

    final comprasRef = FirebaseFirestore.instance
        .collection('historial_compras')
        .doc(uid)
        .collection('compras')
        .orderBy('fecha', descending: true);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Compras'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: StreamBuilder<QuerySnapshot>(
        stream: comprasRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.cyanAccent),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'Aún no tienes compras 🛒',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(10),
            children: snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final productos = List<Map<String, dynamic>>.from(data['productos']);
              final total = data['total'];
              final fecha = (data['fecha'] as Timestamp).toDate();

              return Card(
                color: Colors.grey[900],
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ExpansionTile(
                  iconColor: Colors.cyanAccent,
                  collapsedIconColor: Colors.cyanAccent,
                  title: Text(
                    'Compra - S/ ${total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.cyanAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    'Fecha: ${fecha.day}/${fecha.month}/${fecha.year} ${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  children: productos.map((prod) {
                    final imagenUrl = convertirEnlaceDriveADirecto(prod['imagenURL'] ?? '');

                    return ListTile(
                      leading: imagenUrl.isNotEmpty
                          ? Image.network(
                              imagenUrl,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.broken_image, color: Colors.white54),
                            )
                          : const Icon(Icons.image, color: Colors.white54),
                      title: Text(
                        prod['nombre'] ?? '',
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        'S/ ${(prod['precio'] ?? 0).toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.cyanAccent),
                      ),
                      trailing: prod['cantidad'] != null
                          ? Text(
                              'x${prod['cantidad']}',
                              style: const TextStyle(color: Colors.white),
                            )
                          : null,
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
