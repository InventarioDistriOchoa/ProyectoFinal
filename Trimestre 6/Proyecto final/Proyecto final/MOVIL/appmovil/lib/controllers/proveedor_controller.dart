import 'package:flutter/material.dart';
import '../models/proveedor_model.dart';
import '../services/proveedor_service.dart';

class ProveedorController extends ChangeNotifier {
  final ProveedorService _service = ProveedorService();

  bool loading = false;
  String error = '';
  List<ProveedorModel> proveedores = [];

  Future<void> cargar() async {
    try {
      loading = true;
      error = '';
      notifyListeners();

      proveedores = await _service.listar();
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> crear(String nombreEmpresa, String direccion) async {
    await _service.crear(nombreEmpresa: nombreEmpresa, direccion: direccion);
  }

  Future<void> editar(int id, String nombreEmpresa, String direccion) async {
    await _service.editar(idProveedor: id, nombreEmpresa: nombreEmpresa, direccion: direccion);
  }

  Future<void> eliminar(int id) async {
    await _service.eliminar(id);
  }

  Future<void> activar(int id) async {
    await _service.activar(id);
  }
}
