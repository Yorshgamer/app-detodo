# 📱 App Flutter - DeTodo

Una aplicación móvil desarrollada con **Flutter** para gestionar un catálogo de productos, carrito de compras, ubicación del local y opciones de contacto directo. Perfecta para tiendas como "DeTodo", "FarmaVida", o cualquier negocio que quiera digitalizarse rápido y fácil.

---

## ✨ Funcionalidades principales

- 🛍️ Visualización del **catálogo** con búsqueda y filtro por tipo.
- 🛒 **Carrito de compras** con opciones de agregar, eliminar, y calcular totales.
- 🔐 **Inicio de sesión / registro** para clientes.
- 🗺️ **Mapa interactivo** con la ubicación del usuario y la tienda (Google Maps).
- 🚗 Ruta automática desde tu ubicación hasta el local.
- 📞 **Contacto rápido** (llamada, email y dirección).
- 📸 Carga de **imágenes desde Google Drive** en los productos.
- ☁️ **Firebase Firestore** como backend en tiempo real.

---

## 🔧 Tecnologías utilizadas

| Tecnología         | Uso                                       |
|-------------------|-------------------------------------------|
| Flutter            | Framework principal de la app             |
| Firebase Firestore | Base de datos en tiempo real              |
| Google Maps        | Mapa y rutas del local                    |
| Geolocator         | Ubicación actual del usuario              |
| URL Launcher       | Abrir links externos, llamadas y correos  |
| Google Drive       | Hosting de imágenes para productos        |

---

## 📁 Estructura del proyecto

/lib
├── auth/ # Pantallas de login y registro
├── screens/ # Pantallas principales (Catálogo, Contacto, etc.)
├── widgets/ # Widgets reutilizables como tarjetas o modales
├── models/ # (Opcional) Estructura de datos
└── main.dart # Punto de entrada principal

---

## 🗂️ Firestore - Ubicación de la tienda

La ubicación de la tienda se guarda en Firestore en la colección `tienda`, documento `principal`, campo `ubicacion` como tipo **GeoPoint**:

json
{
  "ubicacion": {
    "_latitude": -12.0540694,
    "_longitude": -75.2241093
  }
}

Esto permite mostrar el local en el mapa dinámicamente y trazar rutas desde el teléfono del usuario hasta la tienda.

🌐 Google Drive - Imágenes de productos
Las imágenes están alojadas en Google Drive y se convierten a enlaces directos con esta función:
String convertirEnlaceDriveADirecto(String url) {
  final uri = Uri.parse(url);
  final id = uri.queryParameters['id'] ?? '';
  return "https://drive.google.com/uc?export=view&id=$id";
}
Usa estos enlaces para mostrar imágenes directamente en tu Image.network() de Flutter.

✅ Permisos requeridos
Agrega los siguientes permisos y tu API Key en android/app/src/main/AndroidManifest.xml:
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>

    <application
        android:label="detodo"
        android:icon="@mipmap/ic_launcher"
        android:name="${applicationName}">

        <!-- Google Maps API Key -->
        <meta-data
            android:name="com.google.android.geo.API_KEY"
            android:value="TU_API_KEY_AQUÍ" />
            
        ...
    </application>
</manifest>

🧪 Cómo correr la app
Clona el proyecto:
git clone https://github.com/tu_usuario/tu_repo_flutter.git
cd tu_repo_flutter

Instala dependencias:
flutter pub get

Ejecuta la app:
flutter run

🤝 Autores
👤 Yorsh-dev, Dakubo
Estudiantes de Sistemas | Apasionado por Flutter, cultura japonesa y programación
📧 yorshyo123@gmail.com

💖 Créditos
Gracias a mis profes y a la comunidad Flutter por todo el apoyo. ¡Esta app es parte de un proyecto universitario con mucho cariño y esfuerzo!

¿Quieres que también incluya capturas o un GIF de cómo se ve la app? Puedo ayudarte con eso también para que el README se vea 🔥.
