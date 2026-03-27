import 'package:flutter/material.dart';
import '/models/detalle_venta_model.dart';
import '/services/detalle_venta_service.dart';

class DetalleVentaController extends ChangeNotifier {
  final DetalleVentaService service = DetalleVentaService();

  List<DetalleVenta> lista = [];
  bool loading = false;

  // Cargar detalles de una venta específica
  Future<void> cargarDatos(int ventaId) async {
    loading = true;
    notifyListeners();

    try {
      lista = await service.getByVentaId(ventaId);
    } catch (e) {
      lista = [];
      debugPrint("Error cargando detalles: $e");
    }

    loading = false;
    notifyListeners();
  }

  // Guardar o actualizar un detalle
  Future<void> guardar(DetalleVenta d) async {
    if (d.idDetalleVenta == null) {
      await service.create(d);
    } else {
      await service.update(d);
    }

    // Recargar datos de la venta correspondiente
    await cargarDatos(d.Venta_id);
  }

  // Eliminar un detalle
  Future<void> eliminar(DetalleVenta d) async {
    await service.delete(d.idDetalleVenta!);
    await cargarDatos(d.Venta_id);
  }
}
