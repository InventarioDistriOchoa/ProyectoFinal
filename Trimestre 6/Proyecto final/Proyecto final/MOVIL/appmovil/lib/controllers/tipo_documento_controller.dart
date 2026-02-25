// controllers/tipo_documento_controller.dart
import 'package:flutter/material.dart';
import '../models/tipo_documento_model.dart';
import '../services/tipo_documento_service.dart';

class TipoDocumentoController extends ChangeNotifier {
  final TipoDocumentoService _service = TipoDocumentoService();

  bool loading = false;
  String error = '';
  List<TipoDocumentoModel> tipos = [];

  // ================= CARGAR =================
  Future<void> cargar() async {
    try {
      loading = true;
      error = '';
      notifyListeners();

      tipos = await _service.listar();
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // ================= CREAR =================
  Future<void> crear(String descripcion) async {
    await _service.crear(descripcion);
  }

  // ================= EDITAR =================
  Future<void> editar(int id, String descripcion) async {
    await _service.editar(id, descripcion);
  }

  // ================= ELIMINAR =================
  Future<void> eliminar(int id) async {
    await _service.eliminar(id);
  }

  // ================= ACTIVAR =================
  Future<void> activar(int id) async {
    await _service.activar(id);
  }
}
