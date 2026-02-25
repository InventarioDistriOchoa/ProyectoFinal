import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_service.dart';
import '../services/venta_service.dart';
import '../services/detalle_venta_service.dart';
import '../models/carrito_item.dart';
import '../models/venta_model.dart';
import '../models/detalle_venta_model.dart';

class VentasController extends ChangeNotifier {
  final ApiService _api = ApiService(); // ✅ para /persona/me
  final VentaService _ventaService = VentaService();
  final DetalleVentaService _detalleService = DetalleVentaService();

  bool loading = false;

  // data
  List<VentaModel> ventas = [];
  List<CarritoItem> carrito = [];

  // helpers
  String fecha = DateTime.now().toIso8601String().split('T').first;
  int personaId = 0;
  String responsableNombre = '';

  // filtros
  String search = '';
  String idFilter = '';

  // ✅ GETTERS QUE TE FALTABAN (para el screen)
  double get totalVenta => carrito.fold(0.0, (acc, it) => acc + it.subtotal);
  int get totalItems => carrito.fold(0, (acc, it) => acc + it.cantidad);

  Future<void> init() async {
    await _loadCarrito();
    await _loadPerfil();
    await cargarVentas();
  }

  Future<void> _loadPerfil() async {
    try {
      final res = await _api.get('/persona/me', useToken: true);

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final decoded = jsonDecode(res.body);
        final body = decoded is Map ? decoded['body'] : null;

        if (body is Map) {
          personaId = int.tryParse((body['idPersona']).toString()) ?? 0;
          responsableNombre = (body['Nombre'] ?? body['nombre'] ?? '').toString();
          notifyListeners();
          return;
        }
      }

      // fallback prefs
      final prefs = await SharedPreferences.getInstance();
      personaId = prefs.getInt('personaId') ?? 0;
      responsableNombre = prefs.getString('nombre') ?? '';
      notifyListeners();
    } catch (_) {
      final prefs = await SharedPreferences.getInstance();
      personaId = prefs.getInt('personaId') ?? 0;
      responsableNombre = prefs.getString('nombre') ?? '';
      notifyListeners();
    }
  }

  Future<void> _loadCarrito() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('carrito_venta');
    if (raw == null || raw.isEmpty) return;

    try {
      final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      carrito = list.map((e) => CarritoItem.fromJson(e)).toList();
    } catch (_) {}

    notifyListeners();
  }

  Future<void> _saveCarrito() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'carrito_venta',
      jsonEncode(carrito.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> cargarVentas() async {
    loading = true;
    notifyListeners();
    try {
      ventas = await _ventaService.obtenerVentas();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void setFecha(String v) {
    fecha = v;
    notifyListeners();
  }

  void agregarAlCarrito({
    required int productoId,
    required String nombre,
    required double precio,
    required int cantidad,
    required int stockDisponible,
  }) {
    final idx = carrito.indexWhere((x) => x.productoId == productoId);
    final enCarrito = idx >= 0 ? carrito[idx].cantidad : 0;
    final nuevaTotal = enCarrito + cantidad;

    if (nuevaTotal > stockDisponible) {
      throw Exception('Stock insuficiente. Solo quedan $stockDisponible.');
    }

    if (idx >= 0) {
      final old = carrito[idx];
      carrito[idx] = CarritoItem(
        productoId: old.productoId,
        nombre: old.nombre,
        precio: old.precio,
        cantidad: old.cantidad + cantidad,
      );
    } else {
      carrito.add(
        CarritoItem(
          productoId: productoId,
          nombre: nombre,
          precio: precio,
          cantidad: cantidad,
        ),
      );
    }

    _saveCarrito();
    notifyListeners();
  }

  void quitarDelCarrito(int productoId) {
    carrito.removeWhere((x) => x.productoId == productoId);
    _saveCarrito();
    notifyListeners();
  }

  Future<void> registrarVentaCompleta() async {
    if (personaId == 0) throw Exception('No se encontró responsable (personaId).');
    if (carrito.isEmpty) throw Exception('Debes agregar al menos un producto.');

    loading = true;
    notifyListeners();

    try {
      // 1) crear venta
      final idVenta = await _ventaService.crearVenta(
        fecha: fecha,
        personaId: personaId,
      );

      // 2) crear detalles
      for (final item in carrito) {
        final detalle = DetalleVentaModel(
          idDetalleVenta: 0,
          ventaId: idVenta,
          productoId: item.productoId,
          cantidad: item.cantidad,
          precioUnitario: item.precio,
          subtotal: item.subtotal,
        );
        await _detalleService.crearDetalle(detalle);
      }

      // 3) limpiar
      carrito = [];
      await _saveCarrito();

      // 4) recargar
      await cargarVentas();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> actualizarFechaVenta(int idVenta, String fechaNueva) async {
    await _ventaService.actualizarFecha(idVenta: idVenta, fecha: fechaNueva);
    await cargarVentas();
  }

  Future<void> eliminarVenta(int idVenta) async {
    await _ventaService.eliminarVenta(idVenta);
    ventas.removeWhere((v) => v.idVenta == idVenta);
    notifyListeners();
  }

  void reset() {
    carrito.clear();
    ventas.clear();

    search = '';
    idFilter = '';

    loading = false;
    notifyListeners();
  }
}
