import 'package:flutter/material.dart';

import '../models/entrada_model.dart';
import '../services/entrada_service.dart';

class EntradaController with ChangeNotifier {
  final EntradaService _entradaService = EntradaService();

  List<EntradaModel> _entradas = [];
  bool _isLoading = false;
  String? _error;

  List<EntradaModel> get entradas => _entradas;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> cargarEntradas() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _entradas = await _entradaService.obtenerEntradas();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> registrarEntrada(EntradaModel entrada) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _entradaService.registrarEntrada(entrada);
      _entradas = await _entradaService.obtenerEntradas();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> eliminarEntrada(int idEntrada) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _entradaService.eliminarEntrada(idEntrada);
      _entradas.removeWhere((e) => e.idEntrada == idEntrada);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> actualizarProveedorEntrada({
    required int entradaId,
    required int proveedorId,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _entradaService.actualizarProveedorEntrada(
        entradaId: entradaId,
        proveedorId: proveedorId,
      );

      _entradas = await _entradaService.obtenerEntradas();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }
}
