import 'dart:convert';
import 'package:flutter/material.dart';

import '../models/historial_models.dart';
import '../services/historial_service.dart';

// ✅ tus modelos reales
import '../models/categoria_model.dart';
import '../models/rol_model.dart';
import '../models/tipo_documento_model.dart';

class HistorialController extends ChangeNotifier {
  final HistorialService _service = HistorialService();

  bool loading = false;
  String error = '';

  List<HistorialRow> data = [];

  // ✅ tus modelos reales
  List<CategoriaModel> categorias = [];
  List<RolModel> roles = [];
  List<TipoDocumentoModel> tiposDocumento = [];

  // filtros
  String search = '';
  String accionFilter = '';
  String usuarioFilter = '';
  String accionTextoFilter = '';
  DateTime? fechaDesde;
  DateTime? fechaHasta;

  int currentPage = 1;
  static const int pageSize = 12;

  final Map<String, String> labelMap = const {
    'idPersona': 'ID de persona',
    'Nombre': 'Nombre',
    'Correo': 'Correo electrónico',
    'Contrasena': 'Contraseña',
    'Numero_Documento': 'Número de documento',
    'Tipo_Documento_id': 'Tipo de documento',
    'Rol_id': 'Rol',
    'Foto': 'Fotografía',
    'ResetToken': 'Token de recuperación',
    'ResetExpires': 'Expira recuperación',
    'Categoria_id': 'Categoría',
  };

  Future<void> cargar() async {
    try {
      loading = true;
      error = '';
      notifyListeners();

      final results = await Future.wait([
        _service.getHistorial(),
        _service.getCategorias(),
        _service.getRoles(),
        _service.getTiposDocumento(),
      ]);

      data = results[0] as List<HistorialRow>;
      categorias = results[1] as List<CategoriaModel>;
      roles = results[2] as List<RolModel>;
      tiposDocumento = results[3] as List<TipoDocumentoModel>;

      currentPage = 1;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  // setters filtros
  void setSearch(String v) {
    search = v;
    currentPage = 1;
    notifyListeners();
  }

  void setAccion(String v) {
    accionFilter = v;
    currentPage = 1;
    notifyListeners();
  }

  void setUsuario(String v) {
    usuarioFilter = v;
    currentPage = 1;
    notifyListeners();
  }

  void setAccionTexto(String v) {
    accionTextoFilter = v;
    currentPage = 1;
    notifyListeners();
  }

  void setFechaDesde(DateTime? d) {
    fechaDesde = d;
    currentPage = 1;
    notifyListeners();
  }

  void setFechaHasta(DateTime? d) {
    fechaHasta = d;
    currentPage = 1;
    notifyListeners();
  }

  void limpiarFiltros() {
    search = '';
    accionFilter = '';
    usuarioFilter = '';
    accionTextoFilter = '';
    fechaDesde = null;
    fechaHasta = null;
    currentPage = 1;
    notifyListeners();
  }

  List<String> get usuariosDisponibles {
    final s = <String>{};
    for (final item in data) {
      final n = item.persona?.nombre;
      if (n != null && n.trim().isNotEmpty) s.add(n.trim());
    }
    final list = s.toList()..sort();
    return list;
  }

  // textos
  String getAccionTexto(HistorialRow item) {
    final nombre = item.persona?.nombre?.trim().isNotEmpty == true
        ? item.persona!.nombre!.trim()
        : 'Se';
    final modulo = item.coleccion.isNotEmpty ? item.coleccion : 'el sistema';

    switch (item.accion) {
      case 'CREATE':
        return nombre == 'Se'
            ? 'Se creó un registro en $modulo'
            : '$nombre creó un registro en $modulo';
      case 'UPDATE':
        return nombre == 'Se'
            ? 'Se realizó una actualización en $modulo'
            : '$nombre realizó una actualización en $modulo';
      case 'DELETE':
        return nombre == 'Se'
            ? 'Se desactivó un registro en $modulo'
            : '$nombre desactivó un registro en $modulo';
      case 'ACTIVATE':
        return nombre == 'Se'
            ? 'Se reactivó un registro en $modulo'
            : '$nombre reactivó un registro en $modulo';
      default:
        return item.accion;
    }
  }

  Color accionColor(String accion) {
    switch (accion) {
      case 'CREATE':
        return const Color(0xFF198754);
      case 'UPDATE':
        return const Color(0xFFFFC107);
      case 'DELETE':
        return const Color(0xFFDC3545);
      case 'ACTIVATE':
        return const Color(0xFF0D6EFD);
      default:
        return const Color(0xFF6C757D);
    }
  }

  // =========================
  // Traducciones (IDs int/string)
  // =========================
  int _asInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }

  String categoriaNombre(dynamic id) {
    final target = _asInt(id);
    final c = categorias.cast<CategoriaModel?>().firstWhere(
          (x) => x != null && x.idCategoria == target,
          orElse: () => null,
        );
    return c?.nombreCategoria ?? 'Desconocida';
  }

  String rolNombre(dynamic id) {
    final target = _asInt(id);
    final r = roles.cast<RolModel?>().firstWhere(
          (x) => x != null && x.idRol == target,
          orElse: () => null,
        );
    return r?.descripcionRol ?? 'Desconocido';
  }

  String tipoDocumentoNombre(dynamic id) {
    final target = _asInt(id);
    final td = tiposDocumento.cast<TipoDocumentoModel?>().firstWhere(
          (x) => x != null && x.idTipoDocumento == target,
          orElse: () => null,
        );
    return td?.descripcion ?? 'Desconocido';
  }

  // parse JSON raro (igual que tu web)
  Map<String, dynamic> parseMaybeJson(dynamic input) {
    if (input == null) return {};
    if (input is Map) return input.cast<String, dynamic>();
    if (input is List) return {'lista': input};

    if (input is String) {
      final s = input.trim();
      if (s.isEmpty) return {};
      try {
        final parsed = jsonDecode(s);
        if (parsed is Map) return parsed.cast<String, dynamic>();
        if (parsed is List) return {'lista': parsed};
        if (parsed is String) {
          final t = parsed.trim();
          if (t.startsWith('{') || t.startsWith('[')) {
            try {
              final parsed2 = jsonDecode(t);
              if (parsed2 is Map) return parsed2.cast<String, dynamic>();
              if (parsed2 is List) return {'lista': parsed2};
            } catch (_) {}
          }
          return {'texto': parsed};
        }
        return {'texto': parsed.toString()};
      } catch (_) {
        if (s.startsWith('{') || s.startsWith('[')) {
          try {
            final parsed2 = jsonDecode(s);
            if (parsed2 is Map) return parsed2.cast<String, dynamic>();
            if (parsed2 is List) return {'lista': parsed2};
          } catch (_) {}
        }
        return {'texto': input};
      }
    }

    return {'texto': input.toString()};
  }

  String renderValue(String key, dynamic value) {
    if (value == null) return '—';
    if (key == 'Categoria_id') return categoriaNombre(value);
    if (key == 'Tipo_Documento_id') return tipoDocumentoNombre(value);
    if (key == 'Rol_id') return rolNombre(value);

    if (value is bool) return value ? 'Sí' : 'No';
    if (value is Map || value is List) return jsonEncode(value);
    return value.toString();
  }

  // filtrado
  List<HistorialRow> get filteredData {
    var result = List<HistorialRow>.from(data);

    final term = search.trim().toLowerCase();
    final accionTextoTerm = accionTextoFilter.trim().toLowerCase();

    result = result.where((item) {
      final usuario = item.persona?.nombre ?? '';
      final modulo = item.coleccion;
      final accion = item.accion;
      final accionDesc = getAccionTexto(item);

      if (term.isNotEmpty) {
        final combined = '$usuario $modulo $accion $accionDesc'.toLowerCase();
        if (!combined.contains(term)) return false;
      }

      if (accionFilter.isNotEmpty && accion != accionFilter) return false;
      if (usuarioFilter.isNotEmpty && usuario != usuarioFilter) return false;
      if (accionTextoTerm.isNotEmpty &&
          !accionDesc.toLowerCase().contains(accionTextoTerm)) {
        return false;
      }

      if (fechaDesde != null || fechaHasta != null) {
        final f = item.createdAt;
        if (fechaDesde != null) {
          final d = DateTime(fechaDesde!.year, fechaDesde!.month, fechaDesde!.day);
          if (f.isBefore(d)) return false;
        }
        if (fechaHasta != null) {
          final h = DateTime(fechaHasta!.year, fechaHasta!.month, fechaHasta!.day)
              .add(const Duration(days: 1));
          if (!f.isBefore(h)) return false;
        }
      }

      return true;
    }).toList();

    return result;
  }

  int get totalPages => (filteredData.isEmpty)
      ? 1
      : ((filteredData.length / pageSize).ceil()).clamp(1, 999999);

  List<HistorialRow> get paginatedData {
    final safe = currentPage.clamp(1, totalPages);
    final start = (safe - 1) * pageSize;
    final end = (start + pageSize).clamp(0, filteredData.length);
    if (start >= filteredData.length) return [];
    return filteredData.sublist(start, end);
  }

  void prevPage() {
    if (currentPage > 1) {
      currentPage--;
      notifyListeners();
    }
  }

  void nextPage() {
    if (currentPage < totalPages) {
      currentPage++;
      notifyListeners();
    }
  }
}
