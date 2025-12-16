import 'package:flutter/material.dart';
import '../../models/categoria_model.dart';
import '../../services/categoria_service.dart';
import 'categoria_form_screen.dart';

class CategoriaListScreen extends StatefulWidget {
  const CategoriaListScreen({super.key});

  @override
  State<CategoriaListScreen> createState() => _CategoriaListScreenState();
}

class _CategoriaListScreenState extends State<CategoriaListScreen> {
  final CategoriaService _service = CategoriaService();
  late Future<List<Categoria>> futureCategorias;

  final Color primary = const Color(0xFF27AE60);

  @override
  void initState() {
    super.initState();
    futureCategorias = _service.get();
  }

  Future<void> _reload() async {
    setState(() {
      futureCategorias = _service.get();
    });
  }

  void _goToCreate() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CategoriaFormScreen(),
      ),
    );

    if (result == true) {
      _reload();
    }
  }

  void _goToEdit(Categoria categoria) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoriaFormScreen(categoria: categoria),
      ),
    );

    if (result == true) {
      _reload();
    }
  }

  void _deleteCategoria(int id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirmar"),
        content: const Text("¿Deseas eliminar esta categoría?"),
        actions: [
          TextButton(
            child: const Text("Cancelar"),
            onPressed: () => Navigator.pop(context, false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primary),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Eliminar"),
          )
        ],
      ),
    );

    if (confirmar == true) {
      try {
        await _service.delete(id); // ← CORRECTO
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Categoría eliminada")),
        );
        _reload();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

  Widget _buildCard(Categoria c) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: primary.withOpacity(0.15),
          child: Text(
            c.nombre[0].toUpperCase(),   // ← CAMBIADO
            style: TextStyle(color: primary, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          c.nombre, // ← CAMBIADO
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
        ),
        subtitle: Text(
          c.descripcion, // ← CAMBIADO
          style: const TextStyle(fontSize: 14),
        ),
        trailing: PopupMenuButton(
          onSelected: (value) {
            if (value == "edit") _goToEdit(c);
            if (value == "delete") _deleteCategoria(c.id!); // ← CORREGIDO
          },
          itemBuilder: (_) => [
            const PopupMenuItem(value: "edit", child: Text("Editar")),
            const PopupMenuItem(value: "delete", child: Text("Eliminar")),
          ],
        ),
        onTap: () => _goToEdit(c),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Categorías"),
        backgroundColor: primary,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primary,
        child: const Icon(Icons.add),
        onPressed: _goToCreate,
      ),
      body: RefreshIndicator(
        onRefresh: _reload,
        child: FutureBuilder<List<Categoria>>(
          future: futureCategorias,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text("Error: ${snapshot.error}"),
              );
            }

            final categorias = snapshot.data ?? [];

            if (categorias.isEmpty) {
              return Center(
                child: Text(
                  "No hay categorías registradas",
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.only(top: 12, bottom: 80),
              itemCount: categorias.length,
              itemBuilder: (context, i) {
                return _buildCard(categorias[i]);
              },
            );
          },
        ),
      ),
    );
  }
}
