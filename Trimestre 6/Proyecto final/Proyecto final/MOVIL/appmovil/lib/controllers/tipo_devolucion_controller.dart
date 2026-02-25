import 'package:flutter/material.dart';
import '../models/tipo_devolucion_model.dart';
import '../services/tipo_devolucion_service.dart';

class TipoDevolucionController extends ChangeNotifier {
  final TipoDevolucionService _service;
  TipoDevolucionController(this._service);

  bool loading = false;
  String? error;

  List<TipoDevolucionModel> tipos = [];

  Future<void> cargar() async {
    try {
      loading = true;
      error = null;
      notifyListeners();

      tipos = await _service.listar();
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> crear(String nombre) async {
    error = null;
    try {
      await _service.crear(nombre);
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  Future<void> activar(int id) async {
    error = null;
    try {
      await _service.activar(id);
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  Future<void> editar(int id, String nombre) async {
    error = null;
    try {
      await _service.editar(id, nombre);
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

