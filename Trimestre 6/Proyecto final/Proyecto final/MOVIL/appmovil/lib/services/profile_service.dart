import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

import 'api_service.dart';
import '../models/profile_models.dart';

class ProfileService {
  final ApiService _api = ApiService();

  // -----------------------------
  //   GET /persona/me
  // -----------------------------
  Future<PerfilRow> getMe() async {
    final res = await _api.get('/persona/me', useToken: true);

    final ok = res.statusCode >= 200 && res.statusCode < 300;
    final decoded = res.body.isNotEmpty ? jsonDecode(res.body) : {};

    if (!ok) {
      final msg = (decoded is Map) ? (decoded['message'] ?? decoded['Message']) : null;
      throw Exception(msg ?? 'No se pudo cargar el perfil (status: ${res.statusCode})');
    }

    final body = (decoded is Map) ? decoded['body'] : null;
    if (body is! Map) throw Exception('Respuesta inválida de perfil.');

    return PerfilRow.fromJson(body.cast<String, dynamic>());
  }

  // -----------------------------
  //   GET /tipoDocumento/tipoDocumento
  // -----------------------------
  Future<List<TipoDocumentoRow>> getTiposDocumento() async {
    final res = await _api.get('/tipoDocumento/tipoDocumento', useToken: true);

    final ok = res.statusCode >= 200 && res.statusCode < 300;
    final decoded = res.body.isNotEmpty ? jsonDecode(res.body) : {};

    if (!ok) {
      final msg = (decoded is Map) ? (decoded['message'] ?? decoded['Message']) : null;
      throw Exception(msg ?? 'No se pudo cargar tipos de documento (status: ${res.statusCode})');
    }

    final body = (decoded is Map) ? decoded['body'] : null;
    if (body is List) {
      return body
          .whereType<Map>()
          .map((e) => TipoDocumentoRow.fromJson(e.cast<String, dynamic>()))
          .toList();
    }
    return [];
  }

  // -----------------------------
  //   PUT /persona/persona/{id}
  // -----------------------------
  Future<void> updatePerfil({
    required String idPersona,
    required String nombre,
    required String correo,
    required String numeroDocumento,
    required String tipoDocumentoId,
    String? contrasena,
  }) async {
    final payload = <String, dynamic>{
      'Nombre': nombre.trim(),
      'Correo': correo.trim(),
      'Numero_Documento': numeroDocumento.trim(),
      'Tipo_Documento_id': int.tryParse(tipoDocumentoId) ?? tipoDocumentoId,
      if (contrasena != null && contrasena.trim().isNotEmpty) 'Contrasena': contrasena.trim(),
    };

    final res = await _api.put('/persona/persona/$idPersona', payload, useToken: true);

    final ok = res.statusCode >= 200 && res.statusCode < 300;
    if (!ok) {
      String msg = 'No se pudo actualizar (status: ${res.statusCode})';
      try {
        final decoded = jsonDecode(res.body);
        if (decoded is Map) {
          msg = (decoded['Message'] ?? decoded['message'] ?? msg).toString();
        }
      } catch (_) {}
      throw Exception(msg);
    }
  }

  // -----------------------------
  //   PUT multipart /persona/:id/foto
  //   router.put("/persona/:id/foto", authMiddleware, upload.single("foto"), uploadFotoPersona)
  // -----------------------------
  Future<void> uploadFoto({
    required int idPersona,
    required XFile xfile,
  }) async {
    final uri = Uri.parse('${_api.baseUrl}/persona/persona/$idPersona/foto');

    final req = http.MultipartRequest('PUT', uri);

    // ✅ token (ApiService ya lo expone)
    final token = await _api.getToken();
    if (token != null && token.isNotEmpty) {
      req.headers['Authorization'] = 'Bearer $token';
    }

    const fieldName = 'foto'; // ✅ debe coincidir con upload.single("foto")

    if (kIsWeb) {
      // ✅ WEB: bytes
      final Uint8List bytes = await xfile.readAsBytes();
      req.files.add(
        http.MultipartFile.fromBytes(
          fieldName,
          bytes,
          filename: xfile.name,
          contentType: MediaType('image', 'jpeg'),
        ),
      );
    } else {
      // ✅ ANDROID/IOS: path
      req.files.add(
        await http.MultipartFile.fromPath(
          fieldName,
          xfile.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );
    }

    final streamed = await req.send();
    final res = await http.Response.fromStream(streamed);

    if (res.statusCode < 200 || res.statusCode >= 300) {
      String msg = 'Error subiendo foto (${res.statusCode})';
      try {
        final decoded = jsonDecode(res.body);
        if (decoded is Map) {
          msg = (decoded['Message'] ?? decoded['message'] ?? msg).toString();
        }
      } catch (_) {}
      throw Exception(msg);
    }
  }

  // -----------------------------
  //   POST /persona/logout
  // -----------------------------
  Future<void> logout() async {
    await _api.post('/persona/logout', {}, useToken: true);
  }
}
