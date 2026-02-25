import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api_endpoints.dart';
import '../models/categoria_model.dart';
import 'api_service.dart';

class CategoriaConflictException implements Exception {
  final String message;
  final int? idCategoria;
  final bool desactivado;

  CategoriaConflictException({
    required this.message,
    this.idCategoria,
    required this.desactivado,
  });

  @override
  String toString() => message;
}

class CategoriaService {
  final ApiService _api = ApiService();

  Future<List<CategoriaModel>> obtenerCategorias() async {
    final http.Response res = await _api.get(ApiEndpoints.categorias);

    if (res.statusCode == 200) {
      final decoded = jsonDecode(res.body);
      final List data = (decoded['body'] as List?) ?? [];
      return data.map((e) => CategoriaModel.fromJson(e)).toList();
    }

    throw Exception('No se pudieron cargar las categorías');
  }

  Future<void> crearCategoria(CategoriaModel categoria) async {
    final res = await _api.post(
      ApiEndpoints.categorias,
      categoria.toJson(),
      useToken: true,
    );

    final decoded = jsonDecode(res.body);

    // 👇 caso especial igual que tu web
    if (res.statusCode == 409) {
      final desactivado = decoded['desactivado'] == true;
      final id = decoded['idCategoria'];
      throw CategoriaConflictException(
        message: (decoded['Message'] ?? 'La categoría ya existe').toString(),
        idCategoria: int.tryParse(id?.toString() ?? ''),
        desactivado: desactivado,
      );
    }

    if (!(res.statusCode == 200 || res.statusCode == 201)) {
      throw Exception((decoded['Message'] ?? 'No se pudo registrar').toString());
    }
  }

  Future<void> actualizarCategoria(int id, CategoriaModel categoria) async {
    final res = await _api.put(
      '${ApiEndpoints.categorias}/$id',
      categoria.toJson(),
      useToken: true,
    );

    if (!(res.statusCode == 200 || res.statusCode == 204)) {
      final decoded = jsonDecode(res.body);
      throw Exception((decoded['Message'] ?? 'No se pudo actualizar').toString());
    }
  }

  Future<void> eliminarCategoria(int id) async {
    final res = await _api.delete('${ApiEndpoints.categorias}/$id', useToken: true);

    if (!(res.statusCode == 200 || res.statusCode == 204)) {
      final decoded = jsonDecode(res.body);
      throw Exception((decoded['Message'] ?? 'No se pudo eliminar').toString());
    }
  }

  Future<void> activarCategoria(int id) async {
    final res = await _api.put('${ApiEndpoints.activarCategoria}/$id', {}, useToken: true);

    if (!(res.statusCode == 200 || res.statusCode == 204)) {
      final decoded = jsonDecode(res.body);
      throw Exception((decoded['Message'] ?? 'No se pudo activar').toString());
    }
  }
}
