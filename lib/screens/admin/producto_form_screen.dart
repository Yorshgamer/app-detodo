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
      const SnackBar(content: Text('✅ Producto guardado con éxito')),
    );

    Navigator.pop(context);
  }

  InputDecoration _inputStyle(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.cyanAccent),
      filled: true,
      fillColor: Colors.white12,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.cyanAccent),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.isNew ? "Nuevo Producto" : "Editar Producto"),
        backgroundColor: Colors.cyanAccent,
        foregroundColor: Colors.black,
      ),
      body: Center(
        child: Container(
          width: 600,
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: ListView(
              shrinkWrap: true,
              children: [
                TextFormField(
                  initialValue: nombre,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputStyle('Nombre'),
                  onSaved: (val) => nombre = val!.trim(),
                  validator: (val) =>
                      val == null || val.trim().isEmpty ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: precio.toString(),
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputStyle('Precio'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onSaved: (val) => precio = double.parse(val!),
                  validator: (val) {
                    final n = double.tryParse(val ?? '');
                    if (n == null || n <= 0) return 'Precio inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: tipo,
                  items: tipos
                      .map((t) => DropdownMenuItem(
                            value: t,
                            child: Text(t),
                          ))
                      .toList(),
                  onChanged: (val) => setState(() => tipo = val!),
                  decoration: _inputStyle('Tipo'),
                  dropdownColor: Colors.black,
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: imagenURL,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputStyle('URL Imagen'),
                  onSaved: (val) => imagenURL = val!.trim(),
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'URL requerida';
                    if (!val.startsWith('http')) return 'Debe ser una URL válida';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: descripcion,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputStyle('Descripción (opcional)'),
                  onSaved: (val) => descripcion = val ?? '',
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _guardarProducto,
                  icon: const Icon(Icons.save),
                  label: const Text('Guardar Producto'),
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
