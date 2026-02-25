import 'package:flutter/material.dart';
import '../models/usuario_model.dart';
import '../models/rol_model.dart';
import '../models/tipo_documento_model.dart';
import '../services/usuario_service.dart';

class UsuariosController extends ChangeNotifier {
  final UsuariosService _service = UsuariosService();

  bool loading = false;
  String error = '';

  List<TipoDocumentoModel> tiposDoc = [];
  List<RolModel> roles = [];
  List<UsuarioModel> usuarios = [];

  Future<void> cargarTodo() async {
    try {
      loading = true;
      error = '';
      notifyListeners();

      final results = await Future.wait([
        _service.listarTiposDocumento(),
        _service.listarRoles(),
        _service.listarUsuarios(),
      ]);

      tiposDoc = results[0] as List<TipoDocumentoModel>;
      roles = results[1] as List<RolModel>;
      usuarios = results[2] as List<UsuarioModel>;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> recargarUsuarios() async {
    try {
      usuarios = await _service.listarUsuarios();
      notifyListeners();
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  Future<void> crear({
    required String nombre,
    required String correo,
    required String contrasena,
    required String numeroDocumento,
    required int tipoDocumentoId,
    required int rolId,
  }) async {
    await _service.crearUsuario(
      nombre: nombre,
      correo: correo,
      contrasena: contrasena,
      numeroDocumento: numeroDocumento,
      tipoDocumentoId: tipoDocumentoId,
      rolId: rolId,
    );
  }

  Future<void> editar({
    required int idPersona,
    required String nombre,
    required String correo,
    required String numeroDocumento,
    required int tipoDocumentoId,
    required int rolId,
    String? contrasena,
  }) async {
    await _service.editarUsuario(
      idPersona: idPersona,
      nombre: nombre,
      correo: correo,
      numeroDocumento: numeroDocumento,
      tipoDocumentoId: tipoDocumentoId,
      rolId: rolId,
      contrasena: contrasena,
    );
  }

  Future<void> eliminar(int idPersona) async {
    await _service.eliminarUsuario(idPersona);
  }

  String tipoDocLabel(int id) {
    return tiposDoc.firstWhere((t) => t.idTipoDocumento == id, orElse: () => TipoDocumentoModel(idTipoDocumento: id, descripcion: id.toString())).descripcion;
  }

  String rolLabel(int id) {
    return roles.firstWhere((r) => r.idRol == id, orElse: () => RolModel(idRol: id, descripcionRol: id.toString())).descripcionRol;
  }
}
