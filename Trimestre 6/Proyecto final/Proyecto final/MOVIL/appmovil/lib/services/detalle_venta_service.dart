import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api_endpoints.dart';
import '../models/detalle_venta_model.dart';
import 'api_service.dart';

class DetalleVentaService {
  final ApiService _api = ApiService();

  Future<List<DetalleVentaModel>> obtenerDetalles() async {
    final http.Response res =
        await _api.get(ApiEndpoints.detalleVentas, useToken: true);

    if (res.statusCode == 200) {
      final decoded = jsonDecode(res.body);
      final List<dynamic> data =
          (decoded is List) ? decoded : ((decoded['body'] ?? decoded['data']) as List? ?? []);

      return data.map((e) => DetalleVentaModel.fromJson(e)).toList();
    }

    throw Exception('Error al obtener detalleVenta: ${res.body}');
  }

  Future<void> crearDetalle(DetalleVentaModel detalle) async {
    final res = await _api.post(
      ApiEndpoints.detalleVentas,
      detalle.toJson(),
      useToken: true,
    );

    if (!(res.statusCode == 200 || res.statusCode == 201)) {
      throw Exception('Error al crear detalle: ${res.body}');
    }
  }

  Future<void> actualizarDetalle(DetalleVentaModel detalle) async {
    final res = await _api.put(
      '${ApiEndpoints.detalleVentas}/${detalle.idDetalleVenta}',
      detalle.toJson(),
      useToken: true,
    );

    if (!(res.statusCode == 200 || res.statusCode == 204)) {
      throw Exception('Error al actualizar detalle: ${res.body}');
    }
  }

  Future<void> eliminarDetalle(int idDetalle) async {
    final res = await _api.delete(
      '${ApiEndpoints.detalleVentas}/$idDetalle',
      useToken: true,
    );

    if (!(res.statusCode == 200 || res.statusCode == 204)) {
      throw Exception('Error al eliminar detalle: ${res.body}');
    }
  }
}
