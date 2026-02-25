import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/env_config.dart';
import '../models/rol_model.dart';

class RolConflictException implements Exception {
  final String message;
  final bool desactivado;
  final int? idRol;

  RolConflictException({
    required this.message,
    required this.desactivado,
    required this.idRol,
  });

  @override
  String toString() => message;
}

class RolService {
  Future<String> _token() async {
    final prefs = await SharedPreferences.getInstance();
    final t = prefs.getString('token');
    if (t == null) throw Exception('No hay token. Inicia sesión.');
    return t;
  }

  Map<String, String> _headers(String token) => {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

  Future<List<RolModel>> listar() async {
    final token = await _token();
    final uri = Uri.parse('${EnvConfig.baseUrl}/rol/rol');

    final res = await http.get(uri, headers: _headers(token));
    final decoded = jsonDecode(res.body);

    if (res.statusCode == 200) {
      final List body = (decoded['body'] as List?) ?? [];
      return body.map((e) => RolModel.fromJson(Map<String, dynamic>.from(e))).toList();
    }
    throw Exception(decoded['Message'] ?? decoded['message'] ?? 'No se pudieron cargar los roles');
  }

  Future<void> crear(String descripcion) async {
    final token = await _token();
    final uri = Uri.parse('${EnvConfig.baseUrl}/rol/rol');

    final res = await http.post(
      uri,
      headers: _headers(token),
      body: jsonEncode({'Descripcion_Rol': descripcion.trim()}),
    );

    final decoded = jsonDecode(res.body);

    // 409 con reactivar
    if (res.statusCode == 409) {
      final bool desactivado = (decoded['desactivado'] == true);
      final idRol = decoded['idRol'];
      throw RolConflictException(
        message: (decoded['Message'] ?? decoded['message'] ?? 'Rol ya existe').toString(),
        desactivado: desactivado,
        idRol: idRol == null ? null : int.tryParse(idRol.toString()),
      );
    }

    if (res.statusCode == 200 || res.statusCode == 201) return;

    throw Exception(decoded['Message'] ?? decoded['message'] ?? 'No se pudo crear el rol');
  }

  Future<void> activar(int idRol) async {
    final token = await _token();
    final uri = Uri.parse('${EnvConfig.baseUrl}/rol/rol/activar/$idRol');

    final res = await http.put(uri, headers: _headers(token));
    final decoded = jsonDecode(res.body);

    if (res.statusCode == 200) return;
    throw Exception(decoded['Message'] ?? decoded['message'] ?? 'No se pudo activar el rol');
  }

  Future<void> editar(int idRol, String descripcion) async {
    final token = await _token();
    final uri = Uri.parse('${EnvConfig.baseUrl}/rol/rol/$idRol');

    final res = await http.put(
      uri,
      headers: _headers(token),
      body: jsonEncode({'Descripcion_Rol': descripcion.trim()}),
    );

    final decoded = jsonDecode(res.body);
    if (res.statusCode == 200) return;

    throw Exception(decoded['Message'] ?? decoded['message'] ?? 'No se pudo actualizar el rol');
  }

  Future<void> eliminar(int idRol) async {
    final token = await _token();
    final uri = Uri.parse('${EnvConfig.baseUrl}/rol/rol/$idRol');

    final res = await http.delete(uri, headers: _headers(token));
    final decoded = jsonDecode(res.body);

    if (res.statusCode == 200) return;
    throw Exception(decoded['Message'] ?? decoded['message'] ?? 'No se pudo eliminar el rol');
  }
}
