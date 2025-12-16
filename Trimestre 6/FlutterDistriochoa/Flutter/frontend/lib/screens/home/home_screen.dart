import 'package:flutter/material.dart';
import '../personas/persona_list_screen.dart';
import '../ventas/venta_list_screen.dart';
import '../entradas/entrada_list_screen.dart'; // Si tienes esta pantalla

class HomeScreen extends StatelessWidget {
  final String role;
  final String userName;
  final String userPhotoUrl;

  const HomeScreen({
    super.key,
    this.role = 'auxiliar',                 // valor por defecto
    this.userName = 'Usuario',              // valor por defecto
    this.userPhotoUrl = 'https://i.pravatar.cc/150?img=12', // valor por defecto
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        backgroundColor: Colors.green.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PersonaListScreen()),
                );
              },
              child: const Text("Personas"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => VentaListScreen()),
                );
              },
              child: const Text("Ventas"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => EntradaListScreen()),
                );
              },
              child: const Text("Entradas"),
            ),
          ],
        ),
      ),
    );
  }
}
