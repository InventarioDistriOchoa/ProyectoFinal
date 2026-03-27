import 'package:flutter/material.dart';
import '../models/categoria_model.dart';
import '../services/categoria_service.dart';
import 'categoria_form_screen.dart';


class CategoriaListScreen extends StatefulWidget {

  const CategoriaListScreen({super.key});

  @override
  State<CategoriaListScreen> createState() => _CategoriaListScreenState();
}

class _CategoriaListScreenState extends State<CategoriaListScreen> {
  final CategoriaService _service = CategoriaService();
  late Future<List<Categoria>> _futureCategorias;

  // Colores tomados de tu styles.css (var --verde: #27ae60)
  final Color primaryGreen = const Color(0xFF27AE60);
  final Color primaryGreenHover = const Color(0xFF219150);

  @override
  void initState() {
    super.initState();
    _cargarCategorias();
  }

  void _cargarCategorias() {
    _futureCategorias = _service.getCategorias();
    setState(() {});
  }

  Future<void> _refrescar() async {
    _cargarCategorias();
    // Esperar la respuesta para que se vea el RefreshIndicator
    await _futureCategorias;
  }

  void _irACrear() async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const CategoriaForm()),
    );
    if (resultado == true) _cargarCategorias();
  }

  void _irAEditar(Categoria c) async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => CategoriaForm(categoria: c)),
    );
    if (resultado == true) _cargarCategorias();
  }

  void _eliminarCategoria(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar'),
        content: const Text('¿Eliminar esta categoría?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Eliminar', style: TextStyle(color: primaryGreen))),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _service.eliminarCategoria(id);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Categoría eliminada')));
        _cargarCategorias();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al eliminar: $e')));
      }
    }
  }

  Widget _buildRow(Categoria c) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        title: Text(c.nombreCategoria, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(c.descripcion),
        leading: CircleAvatar(
          backgroundColor: primaryGreen.withOpacity(0.12),
          child: Text(
            (c.nombreCategoria.isNotEmpty ? c.nombreCategoria[0].toUpperCase() : '?'),
            style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold),
          ),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (v) {
            if (v == 'edit') _irAEditar(c);
            if (v == 'delete') _eliminarCategoria(c.idCategoria);
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'edit', child: Text('Editar')),
            const PopupMenuItem(value: 'delete', child: Text('Eliminar')),
          ],
        ),
        onTap: () => _irAEditar(c),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // AppBar con estilo similar a tu header (uso el verde principal)
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorías'),
        backgroundColor: primaryGreen,
        elevation: 4,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryGreen,
        onPressed: _irACrear,
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: _refrescar,
        child: FutureBuilder<List<Categoria>>(
          future: _futureCategorias,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return Center(child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text('Error al cargar categorías: ${snap.error}', textAlign: TextAlign.center),
              ));
            }
            final list = snap.data ?? [];
            if (list.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.category_outlined, size: 64, color: primaryGreen.withOpacity(0.6)),
                    const SizedBox(height: 12),
                    const Text('No hay categorías registradas', style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: primaryGreen),
                      onPressed: _irACrear,
                      child: const Text('Crear categoría'),
                    )
                  ],
                ),
              );
            }

            // Lista (adaptada a móviles; en tablets se verá tipo carta)
            return ListView.builder(
              padding: const EdgeInsets.only(top: 12, bottom: 24),
              itemCount: list.length,
              itemBuilder: (context, i) => _buildRow(list[i]),
            );
          },
        ),
      ),
    );
  }
}
