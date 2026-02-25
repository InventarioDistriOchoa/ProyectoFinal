import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

import 'api_service.dart';
import '../models/factura_models.dart';

class FacturasService {
  final ApiService _api = ApiService();

  Future<List<Map<String, dynamic>>> _getBodyAsMapList(String endpoint) async {
    final http.Response res = await _api.get(endpoint, useToken: true);

    final decoded = res.body.isNotEmpty ? jsonDecode(res.body) : {};
    final ok = res.statusCode >= 200 && res.statusCode < 300;

    if (!ok) {
      final msg =
          (decoded is Map) ? (decoded['message'] ?? decoded['Message']) : null;
      throw Exception(
          msg ?? 'Error consultando $endpoint (status: ${res.statusCode})');
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

  Future<List<VentaFacturaRow>> getVentas() async {
    final list = await _getBodyAsMapList('/venta/venta');
    return list.map(VentaFacturaRow.fromJson).toList();
  }

  Future<List<UsuarioRow>> getUsuarios() async {
    final list = await _getBodyAsMapList('/persona/persona');
    return list.map(UsuarioRow.fromJson).toList();
  }

  // ✅ DEVUELVE EL RESPONSE COMPLETO (headers + bytes)
  Future<http.Response> getFacturaPdfResponse(String idVenta) async {
    final http.Response res = await _api.get('/factura/$idVenta', useToken: true);

    final ok = res.statusCode >= 200 && res.statusCode < 300;
    final contentType = (res.headers['content-type'] ?? '').toLowerCase();

    if (!ok) {
      String msg = 'No se pudo generar la factura (status: ${res.statusCode})';

      // si vino JSON con message, lo leemos
      try {
        final decoded = jsonDecode(utf8.decode(res.bodyBytes));
        if (decoded is Map) {
          msg = (decoded['message'] ?? decoded['Message'] ?? msg).toString();
        }
      } catch (_) {}

      throw Exception(msg);
    }

    // Si NO es PDF, a veces backend manda JSON igual con ok=true
    if (!contentType.contains('pdf')) {
      try {
        final decoded = jsonDecode(utf8.decode(res.bodyBytes));
        if (decoded is Map) {
          final msg = (decoded['message'] ??
                  decoded['Message'] ??
                  'La respuesta no es PDF')
              .toString();
          throw Exception(msg);
        }
      } catch (_) {}
    }

    if (res.bodyBytes.isEmpty) {
      throw Exception('El PDF llegó vacío.');
    }

    return res;
  }

  // ✅ SI QUIERES SEGUIR USANDO BYTES DIRECTO
  Future<Uint8List> getFacturaPdfBytes(String idVenta) async {
    final res = await getFacturaPdfResponse(idVenta);
    return res.bodyBytes;
  }
}
