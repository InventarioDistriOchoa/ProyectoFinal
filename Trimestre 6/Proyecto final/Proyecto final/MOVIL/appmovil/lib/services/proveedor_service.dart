import 'dart:convert';
import '../models/proveedor_model.dart';
import 'api_service.dart';

class ProveedorConflictException implements Exception {
  final String message;
  final bool desactivado;
  final int? idProveedor;

  ProveedorConflictException({
    required this.message,
    this.desactivado = false,
    this.idProveedor,
  });
}

class ProveedorService {
  final ApiService _api = ApiService();

  Future<List<ProveedorModel>> listar() async {
    final res = await _api.get('/proveedor/proveedor', useToken: true);

    if (res.statusCode == 200) {
      final decoded = jsonDecode(res.body);
      final List list = decoded['body'] ?? [];
      return list.map((e) => ProveedorModel.fromJson(Map<String, dynamic>.from(e))).toList();
    }

    throw Exception('No se pudieron cargar los proveedores');
  }

  Future<void> crear({
    required String nombreEmpresa,
    required String direccion,
  }) async {
    final res = await _api.post(
      '/proveedor/proveedor',
      {
        'Nombre_Empresa': nombreEmpresa,
        'Direccion': direccion,
      },
      useToken: true,
    );

    if (res.statusCode == 201 || res.statusCode == 200) return;

    final decoded = _safeJson(res.body);

    if (res.statusCode == 409) {
      throw ProveedorConflictException(
        message: (decoded['message'] ?? decoded['Message'] ?? 'El proveedor ya existe').toString(),
        desactivado: decoded['desactivado'] == true,
        idProveedor: decoded['idProveedor'] == null ? null : int.tryParse(decoded['idProveedor'].toString()),
      );
    }

    throw Exception((decoded['message'] ?? decoded['Message'] ?? 'No se pudo registrar').toString());
  }

  Future<void> editar({
    required int idProveedor,
    required String nombreEmpresa,
    required String direccion,
  }) async {
    final res = await _api.put(
      '/proveedor/proveedor/$idProveedor',
      {
        'Nombre_Empresa': nombreEmpresa,
        'Direccion': direccion,
      },
      useToken: true,
    );

    if (res.statusCode == 200) return;

    final decoded = _safeJson(res.body);
    throw Exception((decoded['message'] ?? decoded['Message'] ?? 'No se pudo actualizar').toString());
  }

  Future<void> eliminar(int idProveedor) async {
    final res = await _api.delete('/proveedor/proveedor/$idProveedor', useToken: true);

    if (res.statusCode == 200) return;

    final decoded = _safeJson(res.body);
    throw Exception((decoded['message'] ?? decoded['Message'] ?? 'No se pudo desactivar').toString());
  }

  Future<void> activar(int idProveedor) async {
    final res = await _api.put(
      '/proveedor/proveedor/activar/$idProveedor',
      {},
      useToken: true,
    );

    if (res.statusCode == 200) return;

    final decoded = _safeJson(res.body);
    throw Exception((decoded['message'] ?? decoded['Message'] ?? 'No se pudo activar').toString());
  }

  Map<String, dynamic> _safeJson(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) return decoded;
      return {};
    } catch (_) {
      return {};
    }
  }
}
