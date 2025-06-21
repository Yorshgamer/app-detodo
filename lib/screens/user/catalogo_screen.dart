import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../auth/login_screen.dart';

class CatalogoScreen extends StatefulWidget {
  final bool modoInvitado;

  const CatalogoScreen({super.key, required this.modoInvitado});

  @override
  State<CatalogoScreen> createState() => _CatalogoScreenState();
}

class _CatalogoScreenState extends State<CatalogoScreen> with TickerProviderStateMixin {
  String _busqueda = '';
  String _filtroTipo = 'Todos';

  List<Map<String, dynamic>> carrito = [];

  late AnimationController _iconAnimationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _iconAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _iconAnimationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _iconAnimationController.dispose();
    super.dispose();
  }

  void agregarAlCarrito(Map<String, dynamic> producto) {
    setState(() {
      carrito.add(producto);
    });

    _iconAnimationController.forward().then((_) {
      _iconAnimationController.reverse();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${producto['nombre']} añadido al carrito'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
        margin: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void irAlCarrito() async {
    await Navigator.pushNamed(context, '/carrito', arguments: carrito);
    setState(() {});
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
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Catálogo (${widget.modoInvitado ? 'Invitado' : 'Usuario'})',
          style: const TextStyle(color: Colors.cyanAccent),
        ),
        actions: [
          if (widget.modoInvitado)
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
              },
              child: const Text('Iniciar sesión', style: TextStyle(color: Colors.white)),
            ),
          Stack(
            children: [
              IconButton(
                icon: ScaleTransition(
                  scale: _scaleAnimation,
                  child: const Icon(Icons.shopping_cart, color: Colors.cyanAccent),
                ),
                onPressed: irAlCarrito,
              ),
              if (carrito.isNotEmpty)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                    child: Text(
                      '${carrito.length}',
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Buscar producto...',
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Colors.cyanAccent),
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.cyanAccent),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.cyanAccent, width: 2),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _busqueda = value.toLowerCase();
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButtonFormField<String>(
              dropdownColor: Colors.grey[900],
              value: _filtroTipo,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Filtrar por tipo',
                labelStyle: const TextStyle(color: Colors.cyanAccent),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.cyanAccent),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.cyanAccent, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
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
          const SizedBox(height: 10),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('productos').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.cyanAccent));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No hay productos aún 😢', style: TextStyle(color: Colors.white70)));
                }

                final productosFiltrados = snapshot.data!.docs.where((doc) {
                  final nombre = doc['nombre'].toString().toLowerCase();
                  final tipo = doc['tipo'].toString().toLowerCase();

                  final coincideBusqueda = nombre.contains(_busqueda);
                  final coincideFiltro = _filtroTipo == 'Todos' || tipo == _filtroTipo.toLowerCase();

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
                    final imagenOriginal = prod['imagenURL'];
                    final imagenUrl = convertirEnlaceDriveADirecto(imagenOriginal);

                    return Card(
                      color: Colors.grey[900],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            child: imagenUrl.isNotEmpty
                                ? Image.network(
                                    imagenUrl,
                                    height: 130,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, progress) =>
                                        progress == null ? child : const Center(child: CircularProgressIndicator()),
                                    errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.white54, size: 100),
                                  )
                                : const Icon(Icons.image_not_supported, size: 100, color: Colors.white24),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  nombre,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'S/ ${precio.toStringAsFixed(2)}',
                                  style: const TextStyle(fontSize: 20, color: Colors.cyanAccent, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.cyanAccent,
                                    foregroundColor: Colors.black,
                                  ),
                                  onPressed: () {
                                    agregarAlCarrito({
                                      'id': prod.id,
                                      'nombre': nombre,
                                      'precio': precio,
                                      'imagenURL': imagenOriginal,
                                    });
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