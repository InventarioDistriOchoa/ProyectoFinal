import 'package:flutter/material.dart';
import '../models/categoria_model.dart';

class CategoriaItem extends StatelessWidget {
  final Categoria categoria;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  final Color primaryGreen = const Color(0xFF27AE60);

  CategoriaItem({
    super.key,
    required this.categoria,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),

        leading: CircleAvatar(
          backgroundColor: primaryGreen.withOpacity(0.12),
          child: Text(
            categoria.nombreCategoria.isNotEmpty
                ? categoria.nombreCategoria[0].toUpperCase()
                : '?',
            style: TextStyle(
              color: primaryGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        title: Text(
          categoria.nombreCategoria,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),

        subtitle: Text(categoria.descripcion),

        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') onEdit();
            if (value == 'delete') onDelete();
          },
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: 'edit',
              child: Text("Editar"),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Text("Eliminar"),
            ),
          ],
        ),

        onTap: onEdit,
      ),
    );
  }
}
