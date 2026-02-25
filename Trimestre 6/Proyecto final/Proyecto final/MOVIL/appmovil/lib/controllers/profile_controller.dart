import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/profile_models.dart';
import '../services/profile_service.dart';

class ProfileController extends ChangeNotifier {
  final ProfileService _service = ProfileService();

  bool loading = false;
  String error = '';

  PerfilRow? perfil;
  List<TipoDocumentoRow> tiposDocumento = [];

  String get tipoDocDescripcion {
    final p = perfil;
    if (p == null) return '—';

    final match = tiposDocumento
        .where((t) => t.id.toString() == p.tipoDocumentoId.toString())
        .map((t) => t.descripcion)
        .where((d) => d.trim().isNotEmpty)
        .toList();

    return match.isNotEmpty ? match.first : p.tipoDocumentoId;
  }

  Future<void> cargar() async {
    try {
      loading = true;
      error = '';
      notifyListeners();

      final results = await Future.wait([
        _service.getMe(),
        _service.getTiposDocumento(),
      ]);

      perfil = results[0] as PerfilRow;
      tiposDocumento = results[1] as List<TipoDocumentoRow>;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> actualizarPerfil({
    required String nombre,
    required String correo,
    required String numeroDocumento,
    required String tipoDocumentoId,
    String? contrasena,
  }) async {
    try {
      error = '';
      final p = perfil;
      if (p == null) throw Exception('Perfil no cargado.');

      await _service.updatePerfil(
        idPersona: p.idPersona,
        nombre: nombre,
        correo: correo,
        numeroDocumento: numeroDocumento,
        tipoDocumentoId: tipoDocumentoId,
        contrasena: contrasena,
      );

      // refresca
      perfil = await _service.getMe();
      notifyListeners();
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }

  Future<void> subirFoto(XFile xfile) async {
    try {
      error = '';
      final p = perfil;
      if (p == null) throw Exception('Perfil no cargado.');

      await _service.uploadFoto(idPersona: int.parse(p.idPersona.toString()), xfile: xfile);

      // refresca
      perfil = await _service.getMe();
      notifyListeners();
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }

  Future<void> cerrarSesion() async {
    try {
      error = '';
      await _service.logout();
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }
}
