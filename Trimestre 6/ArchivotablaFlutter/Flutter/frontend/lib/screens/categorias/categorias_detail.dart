import 'package:flutter/material.dart';
import '../../models/categoria_model.dart';

class CategoriasDetailScreen extends StatelessWidget {
  final Categoria categoria;

  const CategoriasDetailScreen({super.key, required this.categoria});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detalle de Categoría")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("ID: ${categoria.id}",
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 10),
                Text("Nombre: ${categoria.nombre}",
                    style: const TextStyle(fontSize: 18)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
