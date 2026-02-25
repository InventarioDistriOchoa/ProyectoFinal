import 'dart:convert';
import 'package:http/http.dart' as http;

import 'api_service.dart';
import '../models/reporte_models.dart';

class ReportesService {
  final ApiService _api = ApiService();

  Future<List<Map<String, dynamic>>> _getBodyAsMapList(String endpoint) async {
    final http.Response res = await _api.get(endpoint, useToken: true);

    final decoded = res.body.isNotEmpty ? jsonDecode(res.body) : {};
    final bool ok = res.statusCode >= 200 && res.statusCode < 300;

    if (!ok) {
      final msg = (decoded is Map)
          ? (decoded['message'] ?? decoded['Message'])
          : null;
      throw Exception(msg ?? 'Error consultando $endpoint (status: ${res.statusCode})');
    }

    final body = (decoded is Map) ? decoded['body'] : null;

    if (body == null) return [];
    if (body is List) {
      return body
          .whereType<Map>()
          .map((e) => e.cast<String, dynamic>())
          .toList();
    }
    if (body is Map) return [body.cast<String, dynamic>()];

    return [];
  }

  Future<List<StockRow>> getStock() async {
    final list = await _getBodyAsMapList('/stock');
    return list.map(StockRow.fromJson).toList();
  }

  Future<List<EntradaRow>> getEntradas() async {
    final list = await _getBodyAsMapList('/entrada/entrada');
    return list.map(EntradaRow.fromJson).toList();
  }

  Future<List<VentaRow>> getVentas() async {
    final list = await _getBodyAsMapList('/detalleVenta/detalleVenta');
    return list.map(VentaRow.fromJson).toList();
  }
}
