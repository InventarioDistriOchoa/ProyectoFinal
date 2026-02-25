import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/env_config.dart';

class ApiService {
  final String _baseUrl = EnvConfig.baseUrl;

  // ✅ Para armar URLs en MultipartRequest
  String get baseUrl => _baseUrl;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // ✅ Público por si lo necesitas desde services (multipart)
  Future<String?> getToken() => _getToken();

  Map<String, String> _headers({String? token}) {
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> get(String endpoint, {bool useToken = true}) async {
    final uri = Uri.parse('$_baseUrl$endpoint');
    final token = useToken ? await _getToken() : null;

    print('➡️ [GET] $uri');
    return http.get(uri, headers: _headers(token: token));
  }

  Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> body, {
    bool useToken = false,
  }) async {
    final uri = Uri.parse('$_baseUrl$endpoint');
    final token = useToken ? await _getToken() : null;

    print('➡️ [POST] $uri');
    print('   body: $body');

    return http.post(
      uri,
      headers: _headers(token: token),
      body: jsonEncode(body),
    );
  }

  Future<http.Response> put(
    String endpoint,
    Map<String, dynamic> body, {
    bool useToken = true,
  }) async {
    final uri = Uri.parse('$_baseUrl$endpoint');
    final token = useToken ? await _getToken() : null;

    print('➡️ [PUT] $uri');
    print('   body: $body');

    return http.put(
      uri,
      headers: _headers(token: token),
      body: jsonEncode(body),
    );
  }

  Future<http.Response> delete(
    String endpoint, {
    bool useToken = true,
  }) async {
    final uri = Uri.parse('$_baseUrl$endpoint');
    final token = useToken ? await _getToken() : null;

    print('➡️ [DELETE] $uri');
    return http.delete(uri, headers: _headers(token: token));
  }
}
