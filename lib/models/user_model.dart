class UserModel {
  final String uid;
  final String nombre;
  final String email;
  final bool esAdmin;

  UserModel({
    required this.uid,
    required this.nombre,
    required this.email,
    required this.esAdmin,
  });

  factory UserModel.fromMap(String uid, Map<String, dynamic> map) {
    return UserModel(
      uid: uid,
      nombre: map['nombre'] ?? '',
      email: map['email'] ?? '',
      esAdmin: map['esAdmin'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'email': email,
      'esAdmin': esAdmin,
    };
  }
}