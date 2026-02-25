import 'package:flutter/material.dart';
import '../models/rol_model.dart';
import '../services/rol_service.dart';

class RolController extends ChangeNotifier {
  final RolService _service = RolService();

  bool loading = false;
  String error = '';

  List<RolModel> roles = [];

  Future<void> cargar() async {
    try {
      loading = true;
      error = '';
      notifyListeners();

      roles = await _service.listar();
      roles.sort((a, b) => a.descripcionRol.toLowerCase().compareTo(b.descripcionRol.toLowerCase()));
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> crear(String descripcion) async {
    await _service.crear(descripcion);
  }

  Future<void> activar(int idRol) async {
    await _service.activar(idRol);
  }

  Future<void> editar(int idRol, String descripcion) async {
    await _service.editar(idRol, descripcion);
  }

  Future<void> eliminar(int idRol) async {
    await _service.eliminar(idRol);
  }
}
