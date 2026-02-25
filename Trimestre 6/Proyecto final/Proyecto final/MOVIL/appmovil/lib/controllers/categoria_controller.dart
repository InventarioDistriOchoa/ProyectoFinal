import 'package:flutter/material.dart';
import '../models/categoria_model.dart';
import '../services/categoria_service.dart';

class CategoriaController extends ChangeNotifier {
  final CategoriaService _service = CategoriaService();

  bool loading = false;
  List<CategoriaModel> categorias = [];

  Future<void> cargar() async {
    loading = true;
    notifyListeners();
    try {
      categorias = await _service.obtenerCategorias();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> crear(CategoriaModel cat) => _service.crearCategoria(cat);
  Future<void> editar(int id, CategoriaModel cat) => _service.actualizarCategoria(id, cat);
  Future<void> eliminar(int id) => _service.eliminarCategoria(id);
  Future<void> activar(int id) => _service.activarCategoria(id);
}
