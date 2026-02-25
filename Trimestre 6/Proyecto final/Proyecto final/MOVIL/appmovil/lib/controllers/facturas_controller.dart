import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../models/factura_models.dart';
import '../services/facturas_service.dart';

class FacturasController extends ChangeNotifier {
  final FacturasService _service = FacturasService();

  bool loading = false;
  String error = '';

  List<VentaFacturaRow> ventas = [];
  List<UsuarioRow> usuarios = [];

  String filtro = '';

  Future<void> cargar() async {
    try {
      loading = true;
      error = '';
      notifyListeners();

      final v = await _service.getVentas();
      final u = await _service.getUsuarios();

      ventas = v;
      usuarios = u;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void setFiltro(String v) {
    filtro = v;
    notifyListeners();
  }

  String responsableDe(String personaId) {
    return usuarios
            .where((x) => x.idPersona == personaId)
            .map((x) => x.nombre)
            .cast<String?>()
            .firstWhere((x) => x != null && x.trim().isNotEmpty,
                orElse: () => '—') ??
        '—';
  }

  List<VentaFacturaRow> get ventasFiltradas {
    final q = filtro.trim().toLowerCase();
    if (q.isEmpty) return ventas;

    return ventas.where((v) {
      final fecha = v.fecha == null
          ? ''
          : '${v.fecha!.year.toString().padLeft(4, '0')}-'
              '${v.fecha!.month.toString().padLeft(2, '0')}-'
              '${v.fecha!.day.toString().padLeft(2, '0')}';

      final responsable = responsableDe(v.personaId).toLowerCase();
      final id = v.idVenta.toLowerCase();

      return fecha.contains(q) || responsable.contains(q) || id.contains(q);
    }).toList();
  }

  // ✅ ESTE es el que debes usar desde el botón "Ver PDF"
  Future<Uint8List> descargarPdf(String idVenta) async {
    final res = await _service.getFacturaPdfResponse(idVenta);

    final contentType = (res.headers['content-type'] ?? '').toLowerCase();

    if (res.statusCode < 200 || res.statusCode >= 300) {
      String msg = 'No se pudo generar la factura (status: ${res.statusCode})';

      try {
        final decoded = jsonDecode(utf8.decode(res.bodyBytes));
        if (decoded is Map) {
          msg = (decoded['message'] ?? decoded['Message'] ?? msg).toString();
        }
      } catch (_) {}

      throw Exception(msg);
    }

    // si NO es pdf, muchas veces viene JSON con mensaje
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

    return res.bodyBytes;
  }
}
