import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 🔐 Registro de usuario
  Future<UserModel?> registrarUsuario({
    required String nombre,
    required String email,
    required String password,
    bool esAdmin = false,
  }) async {
    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      UserModel newUser = UserModel(
        uid: cred.user!.uid,
        nombre: nombre,
        email: email,
        esAdmin: esAdmin,
      );

      await _db.collection('usuarios').doc(newUser.uid).set(newUser.toMap());

      return newUser;
    } catch (e) {
      print("🧨 Error al registrar: $e");
      return null;
    }
  }

  // ✅ Login de usuario
  Future<UserModel?> loginUsuario(String email, String password) async {
    try {
      UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      DocumentSnapshot snap =
          await _db.collection('usuarios').doc(cred.user!.uid).get();

      if (!snap.exists) return null;

      return UserModel.fromMap(cred.user!.uid, snap.data() as Map<String, dynamic>);
    } catch (e) {
      print("🧨 Error al loguear: $e");
      return null;
    }
  }

  // 🚪 Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  // 📄 Obtener usuario actual
  Future<UserModel?> getUsuarioActual() async {
    User? user = _auth.currentUser;
    if (user == null) return null;

    DocumentSnapshot snap = await _db.collection('usuarios').doc(user.uid).get();

    if (!snap.exists) return null;

    return UserModel.fromMap(user.uid, snap.data() as Map<String, dynamic>);
  }

  // 🔍 Ver si hay sesión activa
  bool estaLogueado() {
    return _auth.currentUser != null;
  }
}
