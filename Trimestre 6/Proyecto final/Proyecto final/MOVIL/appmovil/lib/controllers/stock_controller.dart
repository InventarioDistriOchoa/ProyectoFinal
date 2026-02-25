import 'package:flutter/material.dart';

import '../config/env_config.dart';
import '../models/stock_model.dart';
import '../services/stock_service.dart';

class StockController with ChangeNotifier {
  final StockService _stockService = StockService();

  // Perfil
  String _nombre = '';
  String _rol = '';
  String? _fotoUrl;

  // Stock
  List<StockModel> _stock = [];
  bool _isLoading = false;
  String? _error;

  // Buscadores + paginación
  String _searchNombre = '';
  String _searchId = '';
  int _currentPage = 1;
  final int itemsPerPage = 10;

  String get nombre => _nombre;
  String get rol => _rol;
  String? get fotoUrl => _fotoUrl;

  List<StockModel> get stock => _stock;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String get searchNombre => _searchNombre;
  String get searchId => _searchId;
  int get currentPage => _currentPage;

  Future<void> init() async {
    await Future.wait([
      cargarPerfil(),
      cargarStock(),
    ]);
  }

  Future<void> cargarPerfil() async {
    try {
      final body = await _stockService.obtenerPerfil();
      final foto = body['Foto'];

      if (foto != null && foto.toString().isNotEmpty) {
        _fotoUrl = '${EnvConfig.mediaBaseUrl}${foto.toString()}';
      }
      notifyListeners();
    } catch (_) {
      // si falla perfil, no rompas la pantalla
    }
  }

  void setSessionInfo({required String nombre, required String rol}) {
    _nombre = nombre;
    _rol = rol.toLowerCase();
    notifyListeners();
  }

  Future<void> cargarStock() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _stock = await _stockService.obtenerStock();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  void setSearchNombre(String v) {
    _searchNombre = v;
    _currentPage = 1;
    notifyListeners();
  }

  void setSearchId(String v) {
    _searchId = v;
    _currentPage = 1;
    notifyListeners();
  }

  List<StockModel> get filteredStock {
    final qNombre = _searchNombre.trim().toLowerCase();
    final qId = _searchId.trim();

    return _stock.where((item) {
      final okNombre = item.producto.toLowerCase().contains(qNombre);
      final okId = item.id.toString().contains(qId);
      return okNombre && okId;
    }).toList();
  }

  int get totalPages {
    final len = filteredStock.length;
    final pages = (len / itemsPerPage).ceil();
    return pages <= 0 ? 1 : pages;
  }

  List<StockModel> get paginatedStock {
    final list = filteredStock;
    final start = (_currentPage - 1) * itemsPerPage;
    final end = start + itemsPerPage;
    if (start >= list.length) return [];
    return list.sublist(start, end > list.length ? list.length : end);
  }

  void prevPage() {
    if (_currentPage > 1) {
      _currentPage--;
      notifyListeners();
    }
  }

  void nextPage() {
    if (_currentPage < totalPages) {
      _currentPage++;
      notifyListeners();
    }
  }

  void goToPage(int p) {
    if (p >= 1 && p <= totalPages) {
      _currentPage = p;
      notifyListeners();
    }
  }
}
