import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/env_config.dart';
import '../config/api_endpoints.dart';
import '../models/tipo_devolucion_model.dart';

class TipoDevolucionConflictException implements Exception {
  final String message;
  final bool desactivado;
  final int? idTipoDevolucion;

  TipoDevolucionConflictException({
    required this.message,
    required this.desactivado,
    required this.idTipoDevolucion,
  });
}

class TipoDevolucionService {
  Future<String> _token() async {
    final prefs = await SharedPreferences.getInstance();
    final t = prefs.getString('token');
    if (t == null) throw Exception('No hay token. Inicia sesión.');
    return t;
  }

  Uri _u(String path) => Uri.parse('${EnvConfig.baseUrl}$path');

  Future<List<TipoDevolucionModel>> listar() async {
    final token = await _token();
    final res = await http.get(
      _u(ApiEndpoints.tiposDevolucion),
      headers: {'Authorization': 'Bearer $token'},
    );

    final data = jsonDecode(res.body);
    if (res.statusCode == 200) {
      final body = (data['body'] as List?) ?? [];
      return body.map((e) => TipoDevolucionModel.fromJson(e)).toList();
    }
    throw Exception(data['Message'] ?? 'No se pudieron cargar los tipos');
  }

  Future<TipoDevolucionModel> crear(String nombreTipo) async {
    final token = await _token();
    final res = await http.post(
      _u(ApiEndpoints.tiposDevolucion),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'NombreTipo': nombreTipo}),
    );

    final data = jsonDecode(res.body);

    if (res.statusCode == 409 && (data['desactivado'] == true)) {
      throw TipoDevolucionConflictException(
        message: (data['message'] ?? data['Message'] ?? 'Ya existe').toString(),
        desactivado: true,
        idTipoDevolucion: int.tryParse((data['idTipoDevolucion'] ?? '').toString()),
      );
    }

    if (res.statusCode == 200 || res.statusCode == 201) {
      return TipoDevolucionModel.fromJson((data['body'] ?? {}) as Map<String, dynamic>);
    }

    throw Exception(data['Message'] ?? 'No se pudo registrar el tipo');
  }

  Future<void> activar(int id) async {
    final token = await _token();
    final res = await http.put(
      _u(ApiEndpoints.activarTipoDevolucion(id)),
      headers: {'Authorization': 'Bearer $token'},
    );

    final data = jsonDecode(res.body);
    if (res.statusCode == 200) return;
    throw Exception(data['Message'] ?? 'No se pudo activar el tipo');
  }

  Future<void> editar(int id, String nombreTipo) async {
    final token = await _token();
    final res = await http.put(
      _u('${ApiEndpoints.tiposDevolucion}/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'NombreTipo': nombreTipo}),
    );

    final data = jsonDecode(res.body);
    if (res.statusCode == 200) return;
    throw Exception(data['Message'] ?? 'No se pudo actualizar el tipo');
  }

  Future<void> eliminar(int id) async {
    final token = await _token();
    final res = await http.delete(
      _u('${ApiEndpoints.tiposDevolucion}/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    final data = jsonDecode(res.body);
    if (res.statusCode == 200) return;
    throw Exception(data['Message'] ?? 'No se pudo eliminar el tipo');
  }
}
