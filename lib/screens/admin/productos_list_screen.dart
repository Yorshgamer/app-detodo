import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'producto_form_screen.dart';

class ProductosListScreen extends StatelessWidget {
  const ProductosListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 👉 Botón para crear nuevo producto
            ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => const Dialog(
                    child: ProductoFormScreen(
                      isNew: true, // 👈 Se añade este parámetro obligatorio
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text("Nuevo Producto"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyanAccent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 👇 Tabla de productos
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('productos').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final productos = snapshot.data!.docs;

                  return SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Nombre', style: TextStyle(color: Colors.cyanAccent))),
                        DataColumn(label: Text('Precio', style: TextStyle(color: Colors.cyanAccent))),
                        DataColumn(label: Text('Tipo', style: TextStyle(color: Colors.cyanAccent))),
                        DataColumn(label: Text('Acciones', style: TextStyle(color: Colors.cyanAccent))),
                      ],
                      rows: productos.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return DataRow(cells: [
                          DataCell(Text(data['nombre'] ?? '', style: const TextStyle(color: Colors.white))),
                          DataCell(Text('\$${data['precio']}', style: const TextStyle(color: Colors.white))),
                          DataCell(Text(data['tipo'] ?? '', style: const TextStyle(color: Colors.white))),
                          DataCell(Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.orangeAccent),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => Dialog(
                                      child: ProductoFormScreen(
                                        isNew: false,
                                        productoId: doc.id,
                                        productoData: data,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.redAccent),
                                onPressed: () async {
                                  await FirebaseFirestore.instance
                                      .collection('productos')
                                      .doc(doc.id)
                                      .delete();
                                },
                              ),
                            ],
                          )),
                        ]);
                      }).toList(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
