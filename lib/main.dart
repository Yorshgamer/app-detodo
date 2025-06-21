import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'config/firebase_options.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/user/carrito_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'PasseroOne', // Asegúrate que este está en pubspec.yaml
      ),
      home: const SplashScreen(),

      // ✅ Aquí registramos rutas nombradas
      onGenerateRoute: (settings) {
        if (settings.name == '/carrito') {
          final carrito = settings.arguments as List<Map<String, dynamic>>;
          return MaterialPageRoute(
            builder: (context) => CarritoScreen(carrito: carrito),
          );
        }
        return null;
      },
    );
  }
}