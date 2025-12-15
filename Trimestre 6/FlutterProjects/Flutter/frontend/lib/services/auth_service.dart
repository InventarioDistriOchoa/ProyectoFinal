import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl = "http://localhost:3001/api/persona";

  Future<bool> login(String correo, String password) async {
    final url = Uri.parse("$baseUrl/login");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "Correo": correo,
        "Contrasena": password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data["ok"] == true) {
        String token = data["token"];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", token);

        return true;
      }
    }

    return false;
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }
}
      