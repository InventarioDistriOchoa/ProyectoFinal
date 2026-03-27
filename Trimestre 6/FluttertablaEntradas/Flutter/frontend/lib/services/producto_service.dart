import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/producto_model.dart';

class ProductoService {
  final String baseUrl = 'http://localhost:3001/api/productos';

  Future<List<Producto>> getAll() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Producto.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar productos');
    }
  }

  Future<Producto> create(Producto producto) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(producto.toJson()),
    );
    if (response.statusCode == 201) {
      return Producto.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al crear producto');
    }
  }

  Future<Producto> update(Producto producto) async {
    final response = await http.put(
      Uri.parse('$baseUrl/${producto.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(producto.toJson()),
    );
    if (response.statusCode == 200) {
      return Producto.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al actualizar producto');
    }
  }

  Future<void> delete(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    if (response.statusCode != 200) {
      throw Exception('Error al eliminar producto');
    }
  }
}
