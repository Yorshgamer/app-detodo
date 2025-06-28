import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'config/firebase_options.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/user/carrito_screen.dart';
import 'screens/user/historial_screen.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with WidgetsBindingObserver {
  Timer? _inactivityTimer;

  void _startInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(const Duration(minutes: 5), () {
      FirebaseAuth.instance.signOut();
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startInactivityTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _inactivityTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _startInactivityTimer();
    } else if (state == AppLifecycleState.paused) {
      _inactivityTimer?.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      // 🔥 Detecta interacción táctil
      onPointerDown: (_) => _startInactivityTimer(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'PasseroOne',
        ),
        home: const SplashScreen(),
        onGenerateRoute: (settings) {
          if (settings.name == '/carrito') {
            final carrito = settings.arguments as List<Map<String, dynamic>>;
            return MaterialPageRoute(
              builder: (context) => CarritoScreen(carrito: carrito),
            );
          }

          if (settings.name == '/historial') {
            return MaterialPageRoute(
              builder: (context) => const HistorialScreen(),
            );
          }

          return null;
        },
      ),
    );
  }
}
