// services/tipo_documento_service.dart
import 'dart:convert';
import '../models/tipo_documento_model.dart';
import 'api_service.dart';

class TipoDocumentoConflictException implements Exception {
  final String message;
  final bool desactivado;
  final int? idTipoDocumento;

  TipoDocumentoConflictException({
    required this.message,
    this.desactivado = false,
    this.idTipoDocumento,
  });
}

class TipoDocumentoService {
  final ApiService _api = ApiService();

  // ================= LISTAR =================
  Future<List<TipoDocumentoModel>> listar() async {
    final res = await _api.get(
      '/tipoDocumento/tipoDocumento',
      useToken: true,
    );

    if (res.statusCode == 200) {
      final decoded = jsonDecode(res.body);
      final List list = decoded['body'] ?? [];

      return list
          .map((e) => TipoDocumentoModel.fromJson(e))
          .toList();
    } else {
      throw Exception('No se pudieron cargar los tipos de documento');
    }
  }

  // ================= CREAR =================
  Future<void> crear(String descripcion) async {
    final res = await _api.post(
      '/tipoDocumento/tipoDocumento',
      {'Descripcion': descripcion},
      useToken: true,
    );

    if (res.statusCode == 201 || res.statusCode == 200) return;

    final decoded = jsonDecode(res.body);

    if (res.statusCode == 409) {
      throw TipoDocumentoConflictException(
        message: decoded['Message'] ?? 'Ya existe',
        desactivado: decoded['desactivado'] == true,
        idTipoDocumento: decoded['idTipo_Documento'],
      );
    }

    throw Exception(decoded['Message'] ?? 'No se pudo crear');
  }

  // ================= EDITAR =================
  Future<void> editar(int id, String descripcion) async {
    final res = await _api.put(
      '/tipoDocumento/tipoDocumento/$id',
      {'Descripcion': descripcion},
      useToken: true,
    );

    if (res.statusCode == 200) return;

    final decoded = jsonDecode(res.body);
    throw Exception(decoded['Message'] ?? 'No se pudo actualizar');
  }

  // ================= ELIMINAR =================
  Future<void> eliminar(int id) async {
    final res = await _api.delete(
      '/tipoDocumento/tipoDocumento/$id',
      useToken: true,
    );

    if (res.statusCode == 200) return;

    final decoded = jsonDecode(res.body);
    throw Exception(decoded['Message'] ?? 'No se pudo eliminar');
  }

  // ================= ACTIVAR =================
  Future<void> activar(int id) async {
    final res = await _api.put(
      '/tipoDocumento/tipoDocumento/activar/$id',
      {},
      useToken: true,
    );

    if (res.statusCode == 200) return;

    final decoded = jsonDecode(res.body);
    throw Exception(decoded['Message'] ?? 'No se pudo activar');
  }
}
