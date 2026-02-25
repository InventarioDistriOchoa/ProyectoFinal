import 'dart:convert';
import '../models/usuario_model.dart';
import '../models/rol_model.dart';
import '../models/tipo_documento_model.dart';
import 'api_service.dart';

class UsuariosService {
  final ApiService _api = ApiService();

  Future<List<TipoDocumentoModel>> listarTiposDocumento() async {
    final res = await _api.get('/tipoDocumento/tipoDocumento', useToken: true);
    if (res.statusCode == 200) {
      final decoded = jsonDecode(res.body);
      final List list = decoded['body'] ?? [];
      return list.map((e) => TipoDocumentoModel.fromJson(Map<String, dynamic>.from(e))).toList();
    }
    throw Exception('No se pudieron cargar los tipos de documento');
  }

  Future<List<RolModel>> listarRoles() async {
    final res = await _api.get('/rol/rol', useToken: true);
    if (res.statusCode == 200) {
      final decoded = jsonDecode(res.body);
      final List list = decoded['body'] ?? [];
      return list.map((e) => RolModel.fromJson(Map<String, dynamic>.from(e))).toList();
    }
    throw Exception('No se pudieron cargar los roles');
  }

  Future<List<UsuarioModel>> listarUsuarios() async {
    final res = await _api.get('/persona/persona', useToken: true);
    if (res.statusCode == 200) {
      final decoded = jsonDecode(res.body);
      final List list = decoded['body'] ?? [];
      return list.map((e) => UsuarioModel.fromJson(Map<String, dynamic>.from(e))).toList();
    }
    throw Exception('No se pudieron cargar los usuarios');
  }

  Future<int> crearUsuario({
    required String nombre,
    required String correo,
    required String contrasena,
    required String numeroDocumento,
    required int tipoDocumentoId,
    required int rolId,
  }) async {
    final res = await _api.post(
      '/persona/persona',
      {
        'Nombre': nombre,
        'Correo': correo,
        'Contrasena': contrasena,
        'Numero_Documento': numeroDocumento,
        'Tipo_Documento_id': tipoDocumentoId,
        'Rol_id': rolId,
      },
      useToken: true,
    );

    final decoded = _safeJson(res.body);

    if (res.statusCode == 200 || res.statusCode == 201) {
      final id = decoded['body']?['idPersona'];
      return int.tryParse(id.toString()) ?? 0;
    }

    throw Exception((decoded['message'] ?? decoded['Message'] ?? 'No se pudo registrar').toString());
  }

  Future<void> editarUsuario({
    required int idPersona,
    required String nombre,
    required String correo,
    required String numeroDocumento,
    required int tipoDocumentoId,
    required int rolId,
    String? contrasena, // opcional
  }) async {
    final res = await _api.put(
      '/persona/persona/$idPersona',
      {
        'Nombre': nombre,
        'Correo': correo,
        'Numero_Documento': numeroDocumento,
        'Tipo_Documento_id': tipoDocumentoId,
        'Rol_id': rolId,
        if (contrasena != null && contrasena.isNotEmpty) 'Contrasena': contrasena,
      },
      useToken: true,
    );

    final decoded = _safeJson(res.body);

    if (res.statusCode == 200) return;

    throw Exception((decoded['message'] ?? decoded['Message'] ?? 'No se pudo actualizar').toString());
  }

  Future<void> eliminarUsuario(int idPersona) async {
    final res = await _api.delete('/persona/persona/$idPersona', useToken: true);
    final decoded = _safeJson(res.body);

    if (res.statusCode == 200) return;

    throw Exception((decoded['message'] ?? decoded['Message'] ?? 'No se pudo eliminar').toString());
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
