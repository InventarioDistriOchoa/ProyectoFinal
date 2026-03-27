import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/detalle_venta_model.dart';

class DetalleVentaService {
  // Cambia esta URL por la de tu backend
  final String baseUrl = "http://tu_api/detalle_ventas";

  // Obtener todos los detalles de una venta por su ID
  Future<List<DetalleVenta>> getByVentaId(int ventaId) async {
    final response = await http.get(Uri.parse('$baseUrl/venta/$ventaId'));

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => DetalleVenta.fromJson(e)).toList();
    } else {
      throw Exception("Error al obtener los detalles de la venta");
    }
  }

  // Crear un nuevo detalle
  Future<void> create(DetalleVenta detalle) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: json.encode(detalle.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Error al crear detalle");
    }
  }

  // Actualizar un detalle existente
  Future<void> update(DetalleVenta detalle) async {
    if (detalle.idDetalleVenta == null) {
      throw Exception("El detalle debe tener id para actualizarse");
    }

    final response = await http.put(
      Uri.parse('$baseUrl/${detalle.idDetalleVenta}'),
      headers: {"Content-Type": "application/json"},
      body: json.encode(detalle.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception("Error al actualizar detalle");
    }
  }

  // Eliminar un detalle por su ID
  Future<void> delete(int idDetalle) async {
    final response = await http.delete(Uri.parse('$baseUrl/$idDetalle'));

    if (response.statusCode != 200) {
      throw Exception("Error al eliminar detalle");
    }
  }
}
  