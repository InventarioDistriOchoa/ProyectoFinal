import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/categoria_model.dart';

class CategoriaService {
  final String baseUrl = "http://localhost:3001/api/categoria";

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  Future<List<Categoria>> getCategorias() async {
    final token = await _getToken();

    final response = await http.get(
      Uri.parse("$baseUrl/listar"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List lista = data["data"];
      return lista.map((e) => Categoria.fromJson(e)).toList();
    } else {
      throw Exception("Error al cargar categorías");
    }
  }

  Future<bool> crearCategoria(String nombre, String descripcion) async {
    final token = await _getToken();

    final response = await http.post(
      Uri.parse("$baseUrl/crear"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "Nombre_Categoria": nombre,
        "Descripcion": descripcion,
      }),
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<bool> actualizarCategoria(int id, String nombre, String descripcion) async {
    final token = await _getToken();

    final response = await http.put(
      Uri.parse("$baseUrl/editar/$id"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "Nombre_Categoria": nombre,
        "Descripcion": descripcion,
      }),
    );

    return response.statusCode == 200;
  }

  Future<bool> eliminarCategoria(int id) async {
    final token = await _getToken();

    final response = await http.delete(
      Uri.parse("$baseUrl/eliminar/$id"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    return response.statusCode == 200;
  }
}
