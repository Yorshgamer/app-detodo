import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int totalProductos = 0;
  int totalVentas = 0;

  @override
  void initState() {
    super.initState();
    cargarEstadisticas();
  }

  Future<void> cargarEstadisticas() async {
    final productos = await FirebaseFirestore.instance.collection('productos').get();
    final ventas = await FirebaseFirestore.instance.collection('ventas').get();

    setState(() {
      totalProductos = productos.docs.length;
      totalVentas = ventas.docs.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Wrap(
          spacing: 40,
          runSpacing: 20,
          children: [
            _buildCard("Total Productos", totalProductos.toString()),
            _buildCard("Ventas Realizadas", totalVentas.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(String title, String value) {
    return Card(
      color: Colors.white12,
      elevation: 4,
      child: SizedBox(
        width: 250,
        height: 140,
        child: Center(
          child: ListTile(
            title: Text(title,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.cyanAccent, fontSize: 16)),
            subtitle: Text(value,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 28)),
          ),
        ),
      ),
    );
  }
}
