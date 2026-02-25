import 'package:flutter/material.dart';
import '../models/devolucion_model.dart';
import '../services/devolucion_service.dart';

class DevolucionController extends ChangeNotifier {
  final DevolucionService _service;
  DevolucionController(this._service);

  bool loading = false;
  String? error;

  List<DevolucionModel> devoluciones = [];

  Future<void> cargar() async {
    try {
      loading = true;
      error = null;
      notifyListeners();

      devoluciones = await _service.listar();
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> crear(DevolucionModel d) async {
    error = null;
    try {
      await _service.crear(d);
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  Future<void> editar(int id, DevolucionModel d) async {
    error = null;
    try {
      await _service.editar(id, d);
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  Future<void> eliminar(int id) async {
    error = null;
    try {
      await _service.eliminar(id);
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      rethrow;
    } finally {
      notifyListeners();
    }
  }
}
