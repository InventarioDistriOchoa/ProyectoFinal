// lib/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/env_config.dart';
import '../config/api_endpoints.dart';
import '../models/user_model.dart';

/// Excepción específica de autenticación
class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}

class AuthService {
  final String _baseUrl = EnvConfig.baseUrl;

  // ===================== LOGIN =====================
  Future<UserModel> login(String correo, String password) async {
    final uri = Uri.parse('$_baseUrl${ApiEndpoints.personaLogin}');

    final body = {
      'Correo': correo,
      'Contrasena': password,
    };

    print('➡️ [LOGIN] POST $uri');
    print('   body: $body');

    try {
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      print('⬅️ STATUS LOGIN => ${res.statusCode}');
      print('⬅️ RESPUESTA LOGIN => ${res.body}');

      final decoded = res.body.isNotEmpty ? jsonDecode(res.body) : {};

      if (res.statusCode >= 200 && res.statusCode < 300) {
        if (decoded is Map<String, dynamic>) {
          return UserModel.fromJson(decoded);
        }
        throw AuthException('Respuesta inválida del servidor.');
      }

      final msg = _extractMsg(decoded) ?? 'Correo o contraseña incorrectos';
      throw AuthException(msg);
    } catch (e) {
      print('❌ Error conectando con backend: $e');
      if (e is AuthException) rethrow;
      throw AuthException('No se pudo conectar al servidor. Revisa tu red.');
    }
  }

  // ===================== FORGOT PASSWORD =====================
  Future<void> forgotPassword(String correo) async {
    final uri = Uri.parse('$_baseUrl${ApiEndpoints.forgotPassword}');

    final body = {'Correo': correo};

    print('➡️ [FORGOT] POST $uri');
    print('   body: $body');

    try {
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      print('⬅️ STATUS FORGOT => ${res.statusCode}');
      print('⬅️ RESPUESTA FORGOT => ${res.body}');

      final decoded = res.body.isNotEmpty ? jsonDecode(res.body) : {};

      if (res.statusCode >= 200 && res.statusCode < 300) {
        // backend: { ok:true, msg:"Correo de recuperación enviado" }
        final ok = (decoded is Map) ? (decoded['ok'] == true) : false;
        if (ok) return;

        throw AuthException(_extractMsg(decoded) ?? 'No se pudo enviar el correo.');
      }

      throw AuthException(_extractMsg(decoded) ?? 'Error enviando el correo.');
    } catch (e) {
      print('❌ Error FORGOT: $e');
      if (e is AuthException) rethrow;
      throw AuthException('No se pudo conectar al servidor. Revisa tu red.');
    }
  }

  // ===================== RESET PASSWORD =====================
  Future<void> resetPassword({
    required String token,
    required String nuevaContrasena,
  }) async {
    // OJO: tu backend recibe token por params: /reset-password/:token
    final uri = Uri.parse('$_baseUrl${ApiEndpoints.resetPassword}/$token');

    final body = {'nuevaContrasena': nuevaContrasena};

    print('➡️ [RESET] POST $uri');
    print('   body: $body');

    try {
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      print('⬅️ STATUS RESET => ${res.statusCode}');
      print('⬅️ RESPUESTA RESET => ${res.body}');

      final decoded = res.body.isNotEmpty ? jsonDecode(res.body) : {};

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final ok = (decoded is Map) ? (decoded['ok'] == true) : false;
        if (ok) return;

        throw AuthException(_extractMsg(decoded) ?? 'No se pudo actualizar la contraseña.');
      }

      throw AuthException(_extractMsg(decoded) ?? 'Token inválido o vencido.');
    } catch (e) {
      print('❌ Error RESET: $e');
      if (e is AuthException) rethrow;
      throw AuthException('No se pudo conectar al servidor. Revisa tu red.');
    }
  }

  // ===================== Helpers =====================
  String? _extractMsg(dynamic decoded) {
    if (decoded is Map) {
      // Tu backend usa: Message / msg (y a veces message)
      return (decoded['Message'] ??
              decoded['message'] ??
              decoded['msg'] ??
              decoded['error'])
          ?.toString();
    }
    return null;
  }
}
