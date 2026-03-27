import 'package:flutter/material.dart';
import '../models/venta_model.dart';
import '../services/venta_service.dart';

class VentaController extends ChangeNotifier {
  final VentaService _service = VentaService();

  List<Venta> ventas = [];
  bool loading = false;

  // Cargar todas las ventas
  Future<void> loadVentas() async {
    loading = true;
    notifyListeners();

    try {
      ventas = await _service.getAll();
    } catch (e) {
      ventas = [];
      debugPrint("Error cargando ventas: $e");
    }

    loading = false;
    notifyListeners();
  }

  // Crear o actualizar venta
  Future<bool> saveVenta(Venta venta) async {
    try {
      if (venta.id != null) {
        await _service.update(venta);
      } else {
        await _service.create(venta);
      }
      await loadVentas();
      return true;
    } catch (e) {
      debugPrint("Error guardando venta: $e");
      return false;
    }
  }

  // Eliminar venta
  Future<bool> deleteVenta(int id) async {
    try {
      await _service.delete(id);
      await loadVentas();
      return true;
    } catch (e) {
      debugPrint("Error eliminando venta: $e");
      return false;
    }
  }
}
