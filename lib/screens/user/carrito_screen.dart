import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CarritoScreen extends StatefulWidget {
  final List<Map<String, dynamic>> carrito;

  const CarritoScreen({super.key, required this.carrito});

  @override
  State<CarritoScreen> createState() => _CarritoScreenState();
}

class _CarritoScreenState extends State<CarritoScreen> {
  double calcularTotal() {
    return widget.carrito.fold(
      0,
      (suma, item) => suma + ((item['precio'] ?? 0) * (item['cantidad'] ?? 1)),
    );
  }

  void eliminarProducto(int index) {
    setState(() {
      widget.carrito.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Producto eliminado del carrito')),
    );
  }

  void aumentarCantidad(int index) {
    setState(() {
      widget.carrito[index]['cantidad'] =
          (widget.carrito[index]['cantidad'] ?? 1) + 1;
    });
  }

  void disminuirCantidad(int index) {
    setState(() {
      final cantidad = widget.carrito[index]['cantidad'] ?? 1;
      if (cantidad > 1) {
        widget.carrito[index]['cantidad'] = cantidad - 1;
      }
    });
  }

  Future<void> guardarCompraEnFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inicia sesión para continuar')),
      );
      return;
    }

    final uid = user.uid;
    final comprasRef = FirebaseFirestore.instance
        .collection('historial_compras')
        .doc(uid)
        .collection('compras');

    final total = calcularTotal();
    final fecha = DateTime.now();

    final productos =
        widget.carrito
            .map(
              (prod) => {
                'id': prod['id'],
                'nombre': prod['nombre'],
                'precio': prod['precio'],
                'cantidad': prod['cantidad'] ?? 1,
                'imagenURL': prod['imagenURL'],
              },
            )
            .toList();

    await comprasRef.add({
      'productos': productos,
      'total': total,
      'fecha': fecha,
    });
  }

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
    final total = calcularTotal();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Carrito de Compras',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body:
          widget.carrito.isEmpty
              ? const Center(
                child: Text(
                  'Tu carrito está vacío 🛒',
                  style: TextStyle(color: Colors.white70, fontSize: 18),
                ),
              )
              : ListView.builder(
                itemCount: widget.carrito.length,
                itemBuilder: (context, index) {
                  final producto = widget.carrito[index];
                  final cantidad = producto['cantidad'] ?? 1;
                  return Card(
                    color: Colors.grey[900],
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: ListTile(
                      leading:
                          producto['imagenURL'] != null
                              ? Image.network(
                                convertirEnlaceDriveADirecto(
                                  producto['imagenURL'],
                                ),
                                width: 60,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (_, __, ___) => const Icon(
                                      Icons.broken_image,
                                      color: Colors.white54,
                                    ),
                              )
                              : const Icon(Icons.image, color: Colors.white54),
                      title: Text(
                        producto['nombre'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'S/ ${(producto['precio'] * cantidad).toStringAsFixed(2)}',
                            style: const TextStyle(color: Colors.cyanAccent),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.remove,
                                  color: Colors.white54,
                                ),
                                onPressed: () => disminuirCantidad(index),
                              ),
                              Text(
                                '$cantidad',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.add,
                                  color: Colors.white54,
                                ),
                                onPressed: () => aumentarCantidad(index),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => eliminarProducto(index),
                      ),
                    ),
                  );
                },
              ),
      bottomNavigationBar:
          widget.carrito.isEmpty
              ? null
              : Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                color: Colors.grey[900],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total: S/ ${total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () async {
                        await guardarCompraEnFirestore();
                        setState(() {
                          widget.carrito.clear();
                        });
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Compra registrada exitosamente'),
                            ),
                          );
                          Navigator.pop(context); // Vuelve al catálogo
                        }
                      },
                      icon: const Icon(Icons.shopping_bag),
                      label: const Text('Pagar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyanAccent,
                        foregroundColor: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
