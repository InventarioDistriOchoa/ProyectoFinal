import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/venta_model.dart';
import '../config/api_config.dart';

class VentaService {
  final String baseUrl = "${ApiConfig.baseUrl}/ventas";

  Future<List<Venta>> getAll() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Venta.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar ventas');
    }
  }

  Future<Venta> create(Venta venta) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(venta.toJson()),
    );

    if (response.statusCode == 201) {
      return Venta.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al crear venta');
    }
  }

  Future<Venta> update(Venta venta) async {
    final response = await http.put(
      Uri.parse('$baseUrl/${venta.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(venta.toJson()),
    );

    if (response.statusCode == 200) {
      return Venta.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al actualizar venta');
    }
  }

  Future<void> delete(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    if (response.statusCode != 200) {
      throw Exception('Error al eliminar venta');
    }
  }
}
