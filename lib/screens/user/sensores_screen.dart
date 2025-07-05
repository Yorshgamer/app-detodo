import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class SensoresScreen extends StatefulWidget {
  const SensoresScreen({super.key});

  @override
  State<SensoresScreen> createState() => _SensoresScreenState();
}

class _SensoresScreenState extends State<SensoresScreen> {
  String acelerometro = '';
  String giroscopio = '';
  String magnetometro = '';
  String userAccel = '';

  @override
  void initState() {
    super.initState();

    SensorsPlatform.instance.accelerometerEventStream().listen((e) {
      setState(() {
        acelerometro = '📌 Acelerómetro:\nX: ${e.x.toStringAsFixed(2)}\nY: ${e.y.toStringAsFixed(2)}\nZ: ${e.z.toStringAsFixed(2)}';
      });
    });

    SensorsPlatform.instance.gyroscopeEventStream().listen((e) {
      setState(() {
        giroscopio = '🌀 Giroscopio:\nX: ${e.x.toStringAsFixed(2)}\nY: ${e.y.toStringAsFixed(2)}\nZ: ${e.z.toStringAsFixed(2)}';
      });
    });

    SensorsPlatform.instance.magnetometerEventStream().listen((e) {
      setState(() {
        magnetometro = '🧲 Magnetómetro:\nX: ${e.x.toStringAsFixed(2)}\nY: ${e.y.toStringAsFixed(2)}\nZ: ${e.z.toStringAsFixed(2)}';
      });
    });

    SensorsPlatform.instance.userAccelerometerEventStream().listen((e) {
      setState(() {
        userAccel = '👤 User Accelerometer:\nX: ${e.x.toStringAsFixed(2)}\nY: ${e.y.toStringAsFixed(2)}\nZ: ${e.z.toStringAsFixed(2)}';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Sensores del Móvil'),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildSensorBox(acelerometro),
            _buildSensorBox(giroscopio),
            _buildSensorBox(magnetometro),
            _buildSensorBox(userAccel),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorBox(String text) {
    return Card(
      color: Colors.white10,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          text.isEmpty ? 'Cargando...' : text,
          style: const TextStyle(fontSize: 16, color: Colors.cyanAccent),
        ),
      ),
    );
  }
}
