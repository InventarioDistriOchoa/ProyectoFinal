import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/env_config.dart';
import '../config/api_endpoints.dart';
import '../models/devolucion_model.dart';

class DevolucionService {
  Future<String> _token() async {
    final prefs = await SharedPreferences.getInstance();
    final t = prefs.getString('token');
    if (t == null) throw Exception('No hay token. Inicia sesión.');
    return t;
  }

  Uri _u(String path) => Uri.parse('${EnvConfig.baseUrl}$path');

  Future<List<DevolucionModel>> listar() async {
    final token = await _token();
    final res = await http.get(
      _u(ApiEndpoints.devoluciones),
      headers: {'Authorization': 'Bearer $token'},
    );

    final data = jsonDecode(res.body);
    if (res.statusCode == 200) {
      final body = (data['body'] as List?) ?? [];
      return body.map((e) => DevolucionModel.fromJson(e)).toList();
    }
    throw Exception(data['Message'] ?? 'No se pudieron cargar devoluciones');
  }

  Future<DevolucionModel> crear(DevolucionModel d) async {
    final token = await _token();
    final res = await http.post(
      _u(ApiEndpoints.devoluciones),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(d.toJsonCreate()),
    );

    final data = jsonDecode(res.body);
    if (res.statusCode == 200 || res.statusCode == 201) {
      return DevolucionModel.fromJson((data['body'] ?? {}) as Map<String, dynamic>);
    }
    throw Exception(data['Message'] ?? 'No se pudo registrar la devolución');
  }

  Future<void> editar(int id, DevolucionModel d) async {
    final token = await _token();
    final res = await http.put(
      _u('${ApiEndpoints.devoluciones}/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(d.toJsonUpdate()),
    );

    final data = jsonDecode(res.body);
    if (res.statusCode == 200) return;
    throw Exception(data['Message'] ?? 'No se pudo actualizar la devolución');
  }

  Future<void> eliminar(int id) async {
    final token = await _token();
    final res = await http.delete(
      _u('${ApiEndpoints.devoluciones}/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    final data = jsonDecode(res.body);
    if (res.statusCode == 200) return;
    throw Exception(data['Message'] ?? 'No se pudo eliminar la devolución');
  }
}
