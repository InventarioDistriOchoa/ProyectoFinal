import 'package:flutter/material.dart';

import '../models/producto_model.dart';
import '../services/producto_service.dart';

class ProductoController with ChangeNotifier {
  final ProductoService _productoService = ProductoService();

  List<ProductoModel> _productos = [];
  bool _isLoading = false;
  String? _error;

  List<ProductoModel> get productos => _productos;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> cargarProductos() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _productos = await _productoService.obtenerProductos();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }
}
