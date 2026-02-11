import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class HttpClient {
  final String baseUrl = AppConfig.baseUrl;

  Future<dynamic> get(String endpoint) async {
    final res = await http.get(Uri.parse("$baseUrl$endpoint"));
    return _processResponse(res);
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    final res = await http.post(
      Uri.parse("$baseUrl$endpoint"),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );
    return _processResponse(res);
  }

  Future<dynamic> put(String endpoint, Map<String, dynamic> body) async {
    final res = await http.put(
      Uri.parse("$baseUrl$endpoint"),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );
    return _processResponse(res);
  }

  Future<dynamic> delete(String endpoint) async {
    final res = await http.delete(Uri.parse("$baseUrl$endpoint"));
    return _processResponse(res);
  }

  dynamic _processResponse(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return json.decode(res.body);
    } else {
      throw Exception("Error en la petición: ${res.statusCode}");
    }
  }
}
