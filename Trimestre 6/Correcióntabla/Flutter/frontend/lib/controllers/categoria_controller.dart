import 'package:flutter/material.dart';
import '../models/categoria_model.dart';
import '../services/categoria_service.dart';

class CategoriaController extends ChangeNotifier {
  final CategoriaService _service = CategoriaService();

  List<Categoria> categorias = [];
  bool loading = false;

  // Cargar todas las categorías
  Future<void> loadCategorias() async {
    loading = true;
    notifyListeners();

    try {
      categorias = await _service.get();
    } catch (e) {
      categorias = [];
      debugPrint("Error cargando categorías: $e");
    }

    loading = false;
    notifyListeners();
  }

  // Crear o actualizar categoría
  Future<bool> saveCategoria(Categoria categoria) async {
    try {
      if (categoria.id != null) {
        await _service.update(categoria);
      } else {
        await _service.create(categoria);
      }
      await loadCategorias();
      return true;
    } catch (e) {
      debugPrint("Error guardando categoría: $e");
      return false;
    }
  }

  // Eliminar categoría
  Future<bool> deleteCategoria(int id) async {
    try {
      await _service.delete(id);
      await loadCategorias();
      return true;
    } catch (e) {
      debugPrint("Error eliminando categoría: $e");
      return false;
    }
  }
}
