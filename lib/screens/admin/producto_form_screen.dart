import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductoFormScreen extends StatefulWidget {
  final bool isNew;
  final String? productoId;
  final Map<String, dynamic>? productoData;

  const ProductoFormScreen({
    super.key,
    required this.isNew,
    this.productoId,
    this.productoData,
  });

  @override
  State<ProductoFormScreen> createState() => _ProductoFormScreenState();
}

class _ProductoFormScreenState extends State<ProductoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late String nombre;
  late String tipo;
  late double precio;
  late String imagenURL;
  String descripcion = '';

  final List<String> tipos = ['ropa', 'comida', 'accesorio', 'papeleria'];

  @override
  void initState() {
    super.initState();
    final data = widget.productoData ?? {};
    nombre = data['nombre'] ?? '';
    tipo = data['tipo'] ?? tipos.first;
    precio = (data['precio'] ?? 0).toDouble();
    imagenURL = data['imagenURL'] ?? '';
    descripcion = data['descripcion'] ?? '';
  }

  Future<void> _guardarProducto() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    final data = {
      'nombre': nombre,
      'precio': precio,
      'tipo': tipo,
      'imagenURL': imagenURL,
      'descripcion': descripcion,
    };

    final productosRef = FirebaseFirestore.instance.collection('productos');

    if (widget.isNew) {
      await productosRef.add(data);
    } else if (widget.productoId != null) {
      await productosRef.doc(widget.productoId).update(data);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Producto guardado con éxito')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Container(
          width: 600,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white12,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Form(
            key: _formKey,
            child: ListView(
              shrinkWrap: true,
              children: [
                TextFormField(
                  initialValue: nombre,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  onSaved: (val) => nombre = val!,
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: precio.toString(),
                  decoration: const InputDecoration(labelText: 'Precio'),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  onSaved: (val) => precio = double.parse(val!),
                  validator: (val) {
                    final n = double.tryParse(val ?? '');
                    if (n == null || n <= 0) return 'Precio inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField(
                  value: tipo,
                  items: tipos
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (val) => setState(() => tipo = val!),
                  decoration: const InputDecoration(labelText: 'Tipo'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: imagenURL,
                  decoration: const InputDecoration(labelText: 'URL Imagen'),
                  onSaved: (val) => imagenURL = val!,
                  validator: (val) =>
                      val == null || val.isEmpty ? 'URL requerida' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: descripcion,
                  decoration:
                      const InputDecoration(labelText: 'Descripción (opcional)'),
                  onSaved: (val) => descripcion = val ?? '',
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _guardarProducto,
                  icon: const Icon(Icons.save),
                  label: const Text('Guardar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyanAccent,
                    foregroundColor: Colors.black,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
