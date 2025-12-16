import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/persona_model.dart';

class PersonaService {
  final String baseUrl = "http://tu_api/personas";

  Future<List<Persona>> getAll() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => Persona.fromJson(e)).toList();
    } else {
      throw Exception("Error al obtener personas");
    }
  }

  Future<void> create(Persona p) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: json.encode(p.toJson()),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Error al crear persona");
    }
  }

  Future<void> update(Persona p) async {
    if (p.id == null) throw Exception("El ID es requerido para actualizar");
    final response = await http.put(
      Uri.parse('$baseUrl/${p.id}'),
      headers: {"Content-Type": "application/json"},
      body: json.encode(p.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception("Error al actualizar persona");
    }
  }

  Future<void> delete(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    if (response.statusCode != 200) {
      throw Exception("Error al eliminar persona");
    }
  }
}
