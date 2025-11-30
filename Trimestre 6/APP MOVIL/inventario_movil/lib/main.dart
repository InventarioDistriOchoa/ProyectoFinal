import 'package:flutter/material.dart';
import 'screens/proveedores/proveedores_screen.dart'; // Ajusta la ruta si moviste la carpeta

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
 //esto es pa cuando haya token xd
    const token = 'TU_TOKEN_AQUI';

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Inventario Móvil',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: ProveedoresScreen(token: token),
    );
  }
}
