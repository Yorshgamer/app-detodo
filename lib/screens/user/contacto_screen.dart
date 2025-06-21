import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactoScreen extends StatefulWidget {
  const ContactoScreen({super.key});

  @override
  State<ContactoScreen> createState() => _ContactoScreenState();
}

class _ContactoScreenState extends State<ContactoScreen> {
  GoogleMapController? mapController;
  LatLng? userLocation;

  final LatLng localLocation = const LatLng(-12.0684, -75.2105); // Dirección de tu tienda

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) return;

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      userLocation = LatLng(position.latitude, position.longitude);
    });
  }

  void _abrirRutaEnMaps() async {
    if (userLocation != null) {
      final url = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&origin=${userLocation!.latitude},${userLocation!.longitude}&destination=${localLocation.latitude},${localLocation.longitude}&travelmode=driving',
      );
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      }
    }
  }

  Widget _infoContacto() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Column(
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.phone, color: Colors.green),
              title: const Text('Llámanos'),
              subtitle: const Text('+51 964605500'),
              onTap: () => launchUrl(Uri.parse('tel:+51964605500')),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.email, color: Colors.red),
              title: const Text('Correo'),
              subtitle: const Text('yorshyo123@gmail.com'),
              onTap: () => launchUrl(Uri.parse('mailto:yorshyo123@gmail.com')),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.location_on, color: Colors.blue),
              title: const Text('Dirección'),
              subtitle: const Text('Jr. Junin 1915, Huancayo 12006'),
              onTap: _abrirRutaEnMaps,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text('Contáctanos')),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              'Ubícanos en nuestra tienda física o escríbenos por redes sociales para más info.',
              style: TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ),
          _infoContacto(),
          const SizedBox(height: 10),
          Expanded(
            child: userLocation == null
                ? const Center(child: CircularProgressIndicator(color: Colors.cyanAccent))
                : GoogleMap(
                    onMapCreated: (controller) => mapController = controller,
                    initialCameraPosition: CameraPosition(
                      target: localLocation,
                      zoom: 15,
                    ),
                    markers: {
                      Marker(
                        markerId: const MarkerId('local'),
                        position: localLocation,
                        infoWindow: const InfoWindow(title: 'Nuestro Local'),
                      ),
                      Marker(
                        markerId: const MarkerId('user'),
                        position: userLocation!,
                        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
                        infoWindow: const InfoWindow(title: 'Tú'),
                      ),
                    },
                  ),
          ),
          ElevatedButton.icon(
            onPressed: _abrirRutaEnMaps,
            icon: const Icon(Icons.directions, color: Colors.black),
            label: const Text("Cómo llegar", style: TextStyle(color: Colors.black)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyanAccent,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
