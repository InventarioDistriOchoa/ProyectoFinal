import 'package:flutter/material.dart';
import 'screens/listar_categoria.dart'; // Importa tu pantalla de listado

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Distriochoa CRUD',
      theme: ThemeData(
        // Puedes cambiar el color primario de tu aplicación aquí
        primarySwatch: Colors.green, 
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // --- ¡EL CAMBIO CRÍTICO ES ESTE! ---
      home: const ListarCategoriaScreen(), 
      // Si tu clase se llama ListarCategoriaScreen
    );
  }
}