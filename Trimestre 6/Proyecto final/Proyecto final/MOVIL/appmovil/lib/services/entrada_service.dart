import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api_endpoints.dart';
import '../models/entrada_model.dart';
import 'api_service.dart';

class EntradaService {
  final ApiService _apiService = ApiService();

  Future<List<EntradaModel>> obtenerEntradas() async {
    final http.Response res =
        await _apiService.get(ApiEndpoints.entradas, useToken: true);

    if (res.statusCode == 200) {
      final decoded = jsonDecode(res.body);

      final List<dynamic> data = (decoded is List)
          ? decoded
          : ((decoded['body'] ?? decoded['data']) as List? ?? []);

      return data.map((e) => EntradaModel.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener entradas: ${res.body}');
    }
  }

  Future<void> registrarEntrada(EntradaModel entrada) async {
    final http.Response res = await _apiService.post(
      ApiEndpoints.entradas,
      entrada.toJson(),
      useToken: true,
    );

    if (!(res.statusCode == 200 || res.statusCode == 201)) {
      throw Exception('Error al registrar entrada: ${res.body}');
    }
  }

  Future<void> eliminarEntrada(int idEntrada) async {
    final http.Response res = await _apiService.delete(
      '${ApiEndpoints.entradas}/$idEntrada',
      useToken: true,
    );

    if (!(res.statusCode == 200 || res.statusCode == 204)) {
      throw Exception('Error al eliminar entrada: ${res.body}');
    }
  }

  Future<void> actualizarProveedorEntrada({
    required int entradaId,
    required int proveedorId,
  }) async {
    final http.Response res = await _apiService.put(
      '${ApiEndpoints.entradas}/$entradaId',
      {'Proveedor_id': proveedorId},
      useToken: true,
    );

    if (!(res.statusCode == 200 || res.statusCode == 204)) {
      throw Exception('Error al actualizar proveedor: ${res.body}');
    }
  }
}
