// lib/services/producto_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api_endpoints.dart';
import '../models/producto_model.dart';
import 'api_service.dart';

class ProductoService {
  final ApiService _apiService = ApiService();
Future<List<ProductoModel>> obtenerProductos() async {
  final http.Response res =
      await _apiService.get(ApiEndpoints.productos); // '/producto/producto'

  if (res.statusCode == 200) {
    final decoded = jsonDecode(res.body);

    // Si tu backend responde: res.json(productos);
    final List<dynamic> data =
        decoded is List ? decoded : (decoded['data'] as List<dynamic>);

    return data.map((e) => ProductoModel.fromJson(e)).toList();
  } else {
    throw Exception('Error al obtener productos: ${res.body}');
  }
}
}
