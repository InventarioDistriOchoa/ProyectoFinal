import '../models/producto_model.dart';
import '../services/producto_service.dart';

class ProductoController {
  final ProductoService _service = ProductoService();

  Future<List<Producto>> getProductos() async {
    return await _service.getAll();
  }

  Future<Producto> agregarProducto(Producto producto) async {
    return await _service.create(producto);
  }

  Future<Producto> actualizarProducto(Producto producto) async {
    return await _service.update(producto);
  }

  Future<void> eliminarProducto(int id) async {
    await _service.delete(id);
  }
}
