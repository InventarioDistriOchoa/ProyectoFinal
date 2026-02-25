import 'dart:convert';
import '../services/api_service.dart';

// ✅ usa TUS modelos reales
import '../models/categoria_model.dart';
import '../models/rol_model.dart';
import '../models/tipo_documento_model.dart';

import '../models/historial_models.dart';

class HistorialService {
  final ApiService _api = ApiService();

  Future<List<Map<String, dynamic>>> _getBodyAsMapList(String endpoint) async {
    final res = await _api.get(endpoint, useToken: true);
    final ok = res.statusCode >= 200 && res.statusCode < 300;

    final decoded = res.body.isNotEmpty ? jsonDecode(res.body) : {};
    if (!ok) {
      final msg = (decoded is Map)
          ? (decoded['message'] ?? decoded['Message'] ?? decoded['msg'])
          : null;
      throw Exception(
        msg ?? 'Error consultando $endpoint (status: ${res.statusCode})',
      );
    }

    final body = (decoded is Map) ? decoded['body'] : null;
    if (body == null) return [];
    if (body is List) {
      return body.whereType<Map>().map((e) => e.cast<String, dynamic>()).toList();
    }
    if (body is Map) return [body.cast<String, dynamic>()];
    return [];
  }

  Future<List<HistorialRow>> getHistorial() async {
    final list = await _getBodyAsMapList('/historial');
    return list.map(HistorialRow.fromJson).toList();
  }

  // ✅ AHORA devuelve CategoriaModel
  Future<List<CategoriaModel>> getCategorias() async {
    final list = await _getBodyAsMapList('/categoria/categoria');
    return list.map((e) => CategoriaModel.fromJson(e)).toList();
  }

  // ✅ AHORA devuelve RolModel
  Future<List<RolModel>> getRoles() async {
    final list = await _getBodyAsMapList('/rol/rol');
    return list.map((e) => RolModel.fromJson(e)).toList();
  }

  // ✅ AHORA devuelve TipoDocumentoModel
  Future<List<TipoDocumentoModel>> getTiposDocumento() async {
    final list = await _getBodyAsMapList('/tipoDocumento/tipoDocumento');
    return list.map((e) => TipoDocumentoModel.fromJson(e)).toList();
  }
}
