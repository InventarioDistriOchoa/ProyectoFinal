import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ActualizarCategoriaScreen extends StatefulWidget {
  final int id;
  final String nombre;
  final String descripcion;

  const ActualizarCategoriaScreen({
    super.key,
    required this.id,
    required this.nombre,
    required this.descripcion,
  });

  @override
  _ActualizarCategoriaScreenState createState() =>
      _ActualizarCategoriaScreenState();
}

class _ActualizarCategoriaScreenState extends State<ActualizarCategoriaScreen> {
  TextEditingController nombreController = TextEditingController();
  TextEditingController descripcionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    nombreController.text = widget.nombre;
    descripcionController.text = widget.descripcion;
  }

  Future<void> actualizarCategoria() async {
    final url = Uri.parse(
        "http://localhost/DISTRIOCHOA/Backend/actualizar_categoria.php");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "id": widget.id,
        "nombre": nombreController.text,
        "descripcion": descripcionController.text,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Categoría actualizada")),
      );

      Navigator.pop(context, true); // ✅ vuelve y refresca lista
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Error al actualizar")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Actualizar Categoría"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nombreController,
              decoration: const InputDecoration(labelText: "Nombre"),
            ),
            TextField(
              controller: descripcionController,
              decoration: const InputDecoration(labelText: "Descripción"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: actualizarCategoria,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text("Actualizar"),
            )
          ],
        ),
      ),
    );
  }
}
