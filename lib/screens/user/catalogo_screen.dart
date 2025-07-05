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
  List<Map<String, dynamic>> productos = [];
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

    _iconAnimationController.forward().then((_) => _iconAnimationController.reverse());

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

  List<Map<String, dynamic>> obtenerRecomendadosPorNombre(String nombreReferencia) {
    final referencia = nombreReferencia.toLowerCase();
    final similares = productos.where((producto) {
      final nombre = producto['nombre']?.toLowerCase() ?? '';
      return nombre != referencia && _similitud(nombre, referencia) > 0;
    }).toList();

    similares.sort((a, b) {
      final nombreA = a['nombre'].toLowerCase();
      final nombreB = b['nombre'].toLowerCase();
      return _similitud(nombreB, referencia) - _similitud(nombreA, referencia);
    });

    return similares.take(3).toList();
  }

  int _similitud(String a, String b) {
    final minLength = a.length < b.length ? a.length : b.length;
    int score = 0;
    for (int i = 0; i < minLength; i++) {
      if (a[i] == b[i]) {
        score++;
      } else {
        break;
      }
    }
    return score;
  }

  void mostrarDetallesProducto(Map<String, dynamic> producto) {
    final recomendados = obtenerRecomendadosPorNombre(producto['nombre']);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        builder: (_, controller) => Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            controller: controller,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Text(
                producto['nombre'],
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('Precio: S/ ${producto['precio']}'),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  agregarAlCarrito(producto);
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text('Agregar al carrito'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              const Divider(height: 32),
              const Text(
                'Productos recomendados:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              ...recomendados.map((prod) => ListTile(
                    title: Text(prod['nombre']),
                    subtitle: Text('S/ ${prod['precio']}'),
                  )),
            ],
          ),
        ),
      ),
    );
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
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
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
            padding: const EdgeInsets.all(12),
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
              onChanged: (value) => setState(() => _busqueda = value.toLowerCase()),
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
                DropdownMenuItem(value: 'Papeleria', child: Text('Papeleria')),
                DropdownMenuItem(value: 'Manualidades', child: Text('Manualidades')),
              ],
              onChanged: (value) => setState(() => _filtroTipo = value!),
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

                productos = snapshot.data!.docs.map((doc) => {
                      'id': doc.id,
                      'nombre': doc['nombre'],
                      'precio': doc['precio'],
                      'tipo': doc['tipo'],
                      'imagenURL': doc['imagenURL'],
                    }).toList();

                final productosFiltrados = productos.where((prod) {
                  final nombre = prod['nombre'].toLowerCase();
                  final tipo = prod['tipo'].toLowerCase();
                  return nombre.contains(_busqueda) &&
                      (_filtroTipo == 'Todos' || tipo == _filtroTipo.toLowerCase());
                }).toList();

                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.5,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: productosFiltrados.length,
                  itemBuilder: (context, index) {
                    final prod = productosFiltrados[index];
                    final imagenUrl = convertirEnlaceDriveADirecto(prod['imagenURL']);

                    return GestureDetector(
                      onTap: () => mostrarDetallesProducto(prod),
                      child: Card(
                        color: Colors.grey[900],
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AspectRatio(
                              aspectRatio: 1,
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                child: imagenUrl.isNotEmpty
                                    ? Image.network(
                                        imagenUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.white54, size: 60),
                                      )
                                    : const Icon(Icons.image_not_supported, size: 60, color: Colors.white24),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        prod['nombre'],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      'S/ ${prod['precio'].toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        color: Colors.cyanAccent,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 36,
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.cyanAccent,
                                          foregroundColor: Colors.black,
                                          padding: EdgeInsets.zero,
                                        ),
                                        onPressed: () => agregarAlCarrito(prod),
                                        child: const Text('Agregar'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
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
