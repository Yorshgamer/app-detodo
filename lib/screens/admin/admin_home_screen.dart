import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../user/catalogo_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final CollectionReference productosRef =
      FirebaseFirestore.instance.collection('productos');

  final _formKey = GlobalKey<FormState>();
  String? _nombre;
  double? _precio;
  String? _tipo;
  String? _imagenURL;
  String? _descripcion;
  String? _editingDocId;

  final List<String> tipos = ['ropa', 'comida', 'accesorio', 'papeleria'];

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const CatalogoScreen(modoInvitado: true)),
      (route) => false,
    );
  }

  void _showForm([DocumentSnapshot? doc]) {
    if (doc != null) {
      _editingDocId = doc.id;
      _nombre = doc['nombre'];
      _precio = (doc['precio'] as num).toDouble();
      _tipo = doc['tipo'];
      _imagenURL = doc['imagenURL'];
      _descripcion = doc.data().toString().contains('descripcion') ? doc['descripcion'] : '';
    } else {
      _editingDocId = null;
      _nombre = null;
      _precio = null;
      _tipo = null;
      _imagenURL = null;
      _descripcion = null;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(_editingDocId == null ? 'Crear Producto' : 'Editar Producto'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: _nombre,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  validator: (val) => val == null || val.isEmpty ? 'Nombre requerido' : null,
                  onSaved: (val) => _nombre = val,
                ),
                TextFormField(
                  initialValue: _precio != null ? _precio.toString() : null,
                  decoration: const InputDecoration(labelText: 'Precio'),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Precio requerido';
                    final p = double.tryParse(val);
                    if (p == null || p <= 0) return 'Precio inválido';
                    return null;
                  },
                  onSaved: (val) => _precio = double.tryParse(val!),
                ),
                DropdownButtonFormField<String>(
                  value: _tipo,
                  decoration: const InputDecoration(labelText: 'Tipo'),
                  items: tipos
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  validator: (val) => val == null ? 'Seleccione un tipo' : null,
                  onChanged: (val) => _tipo = val,
                ),
                TextFormField(
                  initialValue: _imagenURL,
                  decoration: const InputDecoration(labelText: 'URL de Imagen'),
                  validator: (val) => val == null || val.isEmpty ? 'URL requerida' : null,
                  onSaved: (val) => _imagenURL = val,
                ),
                TextFormField(
                  initialValue: _descripcion,
                  decoration: const InputDecoration(labelText: 'Descripción (opcional)'),
                  maxLines: 2,
                  onSaved: (val) => _descripcion = val,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();

                final data = {
                  'nombre': _nombre,
                  'precio': _precio,
                  'tipo': _tipo,
                  'imagenURL': _imagenURL,
                  'descripcion': _descripcion ?? '',
                };

                if (_editingDocId == null) {
                  await productosRef.add(data);
                } else {
                  await productosRef.doc(_editingDocId).update(data);
                }

                Navigator.pop(context);
              }
            },
            child: Text(_editingDocId == null ? 'Crear' : 'Guardar'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteProduct(String id) async {
    await productosRef.doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Admin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: productosRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No hay productos'));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final prod = docs[index];
              return ListTile(
                leading: prod['imagenURL'] != null
                    ? Image.network(prod['imagenURL'],
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.broken_image))
                    : const Icon(Icons.image_not_supported),
                title: Text(prod['nombre']),
                subtitle: Text('\$${prod['precio'].toString()} - ${prod['tipo']}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showForm(prod),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Eliminar producto'),
                            content:
                                const Text('¿Seguro que quieres eliminar este producto?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancelar'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Eliminar'),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await _deleteProduct(prod.id);
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}