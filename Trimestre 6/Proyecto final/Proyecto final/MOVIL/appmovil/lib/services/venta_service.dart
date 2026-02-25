import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api_endpoints.dart';
import '../models/venta_model.dart';
import 'api_service.dart';

class VentaService {
  final ApiService _api = ApiService();

  Future<List<VentaModel>> obtenerVentas() async {
    final http.Response res = await _api.get(ApiEndpoints.ventas, useToken: true);

    if (res.statusCode == 200) {
      final decoded = jsonDecode(res.body);
      final List<dynamic> data =
          (decoded is List) ? decoded : ((decoded['body'] ?? decoded['data']) as List? ?? []);

      return data.map((e) => VentaModel.fromJson(e)).toList();
    }

    throw Exception('Error al obtener ventas: ${res.body}');
  }

  Future<int> crearVenta({
    required String fecha,
    required int personaId,
  }) async {
    final res = await _api.post(
      ApiEndpoints.ventas,
      {
        'Fecha': fecha,
        'Total': 0,
        'Persona_id': personaId,
      },
      useToken: true,
    );

    final decoded = jsonDecode(res.body);

    if (res.statusCode == 200 || res.statusCode == 201) {
      // tu backend devuelve body.idVenta
      return int.tryParse((decoded['body']?['idVenta']).toString()) ?? 0;
    }

    throw Exception(decoded['message'] ?? decoded['Message'] ?? 'No se pudo crear venta');
  }

  Future<void> actualizarFecha({
    required int idVenta,
    required String fecha,
  }) async {
    final res = await _api.put(
      '${ApiEndpoints.ventas}/$idVenta',
      {'Fecha': fecha},
      useToken: true,
    );

    if (!(res.statusCode == 200 || res.statusCode == 204)) {
      throw Exception('Error al actualizar venta: ${res.body}');
    }
  }

  Future<void> eliminarVenta(int idVenta) async {
    final res = await _api.delete(
      '${ApiEndpoints.ventas}/$idVenta',
      useToken: true,
    );

    if (!(res.statusCode == 200 || res.statusCode == 204)) {
      throw Exception('Error al eliminar venta: ${res.body}');
    }
  }
}
