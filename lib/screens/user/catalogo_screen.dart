import 'package:flutter/material.dart';
import '../auth/login_screen.dart'; // Asegúrate de importar esto
import 'package:cloud_firestore/cloud_firestore.dart';

class CatalogoScreen extends StatefulWidget {
  final bool modoInvitado;

  const CatalogoScreen({super.key, required this.modoInvitado});

  @override
  State<CatalogoScreen> createState() => _CatalogoScreenState();
}

class _CatalogoScreenState extends State<CatalogoScreen> {
  String _busqueda = '';
  String _filtroTipo = 'Todos';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Catálogo (${widget.modoInvitado ? 'Invitado' : 'Usuario'})',
        ),
        actions: [
          if (widget.modoInvitado)
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
      body: Column(
        children: [
          // 🔍 Barra de búsqueda
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Buscar producto...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _busqueda = value.toLowerCase();
                });
              },
            ),
          ),
          // 🔘 Filtro por tipo
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButton<String>(
              value: _filtroTipo,
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: 'Todos', child: Text('Todos')),
                DropdownMenuItem(value: 'ropa', child: Text('Ropa')),
                DropdownMenuItem(value: 'comida', child: Text('Comida')),
                DropdownMenuItem(value: 'accesorio', child: Text('Accesorio')),
              ],
              onChanged: (value) {
                setState(() {
                  _filtroTipo = value!;
                });
              },
            ),
          ),

          // 📦 Productos
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('productos')
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No hay productos aún 😢'));
                }

                final productosFiltrados =
                    snapshot.data!.docs.where((doc) {
                      final nombre = doc['nombre'].toString().toLowerCase();
                      final tipo = doc['tipo'].toString().toLowerCase();

                      final coincideBusqueda = nombre.contains(_busqueda);
                      final coincideFiltro =
                          _filtroTipo == 'Todos' ||
                          tipo == _filtroTipo.toLowerCase();

                      return coincideBusqueda && coincideFiltro;
                    }).toList();

                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 2 / 2.5,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: productosFiltrados.length,
                  itemBuilder: (context, index) {
                    final prod = productosFiltrados[index];
                    final nombre = prod['nombre'];
                    final precio = prod['precio'];
                    final imagenUrl =
                        prod.data().toString().contains('imagenURL')
                            ? prod['imagenURL']
                            : '';

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                            child:
                                imagenUrl.isNotEmpty
                                    ? Image.network(
                                      imagenUrl,
                                      height: 130,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (
                                        context,
                                        child,
                                        loadingProgress,
                                      ) {
                                        if (loadingProgress == null)
                                          return child;
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      },
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(
                                                Icons.broken_image,
                                                size: 100,
                                              ),
                                    )
                                    : const Icon(
                                      Icons.image_not_supported,
                                      size: 100,
                                    ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  nombre,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '\$${precio.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    color: Colors.deepPurple,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          '$nombre agregado al carrito',
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Text('Agregar'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
