import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/detalle_venta_controller.dart';
import '../../models/detalle_venta_model.dart';
import '../../controllers/venta_controller.dart';
import '../../models/venta_model.dart';

class DetalleVentaListScreen extends StatefulWidget {
  final Venta venta;

  const DetalleVentaListScreen({super.key, required this.venta});

  @override
  State<DetalleVentaListScreen> createState() => _DetalleVentaListScreenState();
}

class _DetalleVentaListScreenState extends State<DetalleVentaListScreen> {
  late DetalleVentaController ctrl;

  @override
  void initState() {
    super.initState();
    ctrl = Provider.of<DetalleVentaController>(context, listen: false);
    ctrl.cargarDatos(widget.venta.id!);
  }

  Future<void> _agregarDetalle() async {
    // Aquí se agrega un producto de ejemplo, luego puedes hacer un diálogo para seleccionar producto y cantidad
    final nuevoDetalle = DetalleVenta(
      Venta_id: widget.venta.id!,
      Producto_id: 1,
      Cantidad: 1,
      PrecioUnitario: 100.0,
      Subtotal: 100.0,
    );

    await ctrl.guardar(nuevoDetalle);
  }

  @override
  Widget build(BuildContext context) {
    ctrl = Provider.of<DetalleVentaController>(context);

    double total = ctrl.lista.fold(0, (sum, item) => sum + item.Subtotal);

    return Scaffold(
      appBar: AppBar(
        title: Text("Detalles de venta: ${widget.venta.cliente}"),
        backgroundColor: Colors.green.shade700,
      ),
      body: ctrl.loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ctrl.lista.isEmpty
                      ? const Center(child: Text("No hay productos agregados"))
                      : ListView.builder(
                          itemCount: ctrl.lista.length,
                          itemBuilder: (context, index) {
                            final d = ctrl.lista[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 12),
                              child: ListTile(
                                title: Text("Producto ${d.Producto_id}"),
                                subtitle: Text(
                                    "${d.Cantidad} x \$${d.PrecioUnitario}"),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () async {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            title: const Text("Confirmar"),
                                            content: const Text(
                                                "¿Deseas eliminar este producto?"),
                                            actions: [
                                              TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(ctx, false),
                                                  child: const Text("Cancelar")),
                                              TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(ctx, true),
                                                  child: const Text("Eliminar")),
                                            ],
                                          ),
                                        );
                                        if (confirm ?? false) {
                                          await ctrl.eliminar(d.idDetalleVenta!);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        "Total: \$${total.toStringAsFixed(2)}",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade700,
                            minimumSize: const Size.fromHeight(50)),
                        onPressed: _agregarDetalle,
                        child: const Text("Agregar producto"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
