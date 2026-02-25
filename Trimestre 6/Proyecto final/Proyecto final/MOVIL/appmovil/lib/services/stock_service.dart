import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api_endpoints.dart';
import '../models/stock_model.dart';
import 'api_service.dart';

class StockService {
  final ApiService _apiService = ApiService();

  Future<List<StockModel>> obtenerStock() async {
    final http.Response res = await _apiService.get(ApiEndpoints.stock);

    if (res.statusCode == 200) {
      final decoded = jsonDecode(res.body);

      // Tu backend suele mandar { body: [] }
      final List<dynamic> data = (decoded is List)
          ? decoded
          : ((decoded['body'] ?? decoded['data']) as List? ?? []);

      return data.map((e) => StockModel.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Error al cargar stock: ${res.body}');
    }
  }

  Future<Map<String, dynamic>> obtenerPerfil() async {
    final http.Response res = await _apiService.get(ApiEndpoints.me); // '/persona/me'

    if (res.statusCode == 200) {
      final decoded = jsonDecode(res.body);
      final body = (decoded['body'] ?? {}) as Map<String, dynamic>;
      return body;
    } else {
      throw Exception('Error al cargar perfil: ${res.body}');
    }
  }
}
