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

  void _mostrarResumenCompra(BuildContext context) {
    String metodoPago = 'Efectivo';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text(
            'Resumen de compra',
            style: TextStyle(color: Colors.cyanAccent),
          ),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...widget.carrito.map((item) {
                    final cantidad = item['cantidad'] ?? 1;
                    final totalItem = (item['precio'] ?? 0) * cantidad;
                    return ListTile(
                      title: Text(
                        item['nombre'],
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        'Cantidad: $cantidad x S/ ${item['precio']}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      trailing: Text(
                        'S/ ${totalItem.toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.cyanAccent),
                      ),
                    );
                  }).toList(),
                  const Divider(color: Colors.white24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total:',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'S/ ${calcularTotal().toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.cyanAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: metodoPago,
                    dropdownColor: Colors.grey[850],
                    decoration: const InputDecoration(
                      labelText: 'Método de Pago',
                      labelStyle: TextStyle(color: Colors.white),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white54),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                    items:
                        ['Efectivo', 'Yape'].map((m) {
                          return DropdownMenuItem(
                            value: m,
                            child: Text(
                              m,
                              style: const TextStyle(color: Colors.white),
                            ),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        metodoPago = value!;
                      });
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await guardarCompraEnFirestoreConMetodo(metodoPago);
                if (mounted) {
                  setState(() => widget.carrito.clear());
                  Navigator.pop(context); // cerrar modal
                  Navigator.pop(context); // volver al catálogo
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Compra registrada con éxito'),
                    ),
                  );
                }
              },
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
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

  Future<void> guardarCompraEnFirestoreConMetodo(String metodoPago) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

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
      'metodo_pago': metodoPago,
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
                      onPressed: () => _mostrarResumenCompra(context),
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
