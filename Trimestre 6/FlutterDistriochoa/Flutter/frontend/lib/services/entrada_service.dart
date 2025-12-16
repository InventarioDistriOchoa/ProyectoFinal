import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/entrada_model.dart';

class EntradaService {
  final String baseUrl = "http://localhost:3006/api/entradas";

  Future<List<Entrada>> getAll() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => Entrada.fromJson(e)).toList();
    } else {
      throw Exception("Error al obtener entradas");
    }
  }

  Future<void> create(Entrada e) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: json.encode(e.toJson()),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Error al crear entrada");
    }
  }

  Future<void> update(Entrada e) async {
    if (e.idEntrada == null) throw Exception("La entrada debe tener ID para actualizarse");
    final response = await http.put(
      Uri.parse('$baseUrl/${e.idEntrada}'),
      headers: {"Content-Type": "application/json"},
      body: json.encode(e.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception("Error al actualizar entrada");
    }
  }

  Future<void> delete(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    if (response.statusCode != 200) {
      throw Exception("Error al eliminar entrada");
    }
  }
}
