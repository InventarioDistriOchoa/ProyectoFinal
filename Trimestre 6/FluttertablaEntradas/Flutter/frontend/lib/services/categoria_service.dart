import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/categoria_model.dart';

class CategoriaService {
  final String baseUrl = 'http://localhost:3001/api/categorias';

  Future<List<Categoria>> get() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Categoria.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar categorías');
    }
  }

  Future<Categoria?> getById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));

    if (response.statusCode == 200) {
      return Categoria.fromJson(jsonDecode(response.body));
    } 
    if (response.statusCode == 404) {
      return null; // No encontrada
    }
    throw Exception('Error al buscar categoría');
  }

  Future<Categoria> create(Categoria categoria) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(categoria.toJson()),
    );
    if (response.statusCode == 201) {
      return Categoria.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al crear categoría');
    }
  }

  Future<Categoria> update(Categoria categoria) async {
    final response = await http.put(
      Uri.parse('$baseUrl/${categoria.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(categoria.toJson()),
    );
    if (response.statusCode == 200) {
      return Categoria.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al actualizar categoría');
    }
  }

  Future<void> delete(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    if (response.statusCode != 200) {
      throw Exception('Error al eliminar categoría');
    }
  }
}
