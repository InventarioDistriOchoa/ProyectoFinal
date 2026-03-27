import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/venta_controller.dart';
import '../../models/venta_model.dart';
import '../../models/detalle_venta_model.dart';
import '../../services/detalle_venta_service.dart';

class VentaFormScreen extends StatefulWidget {
  const VentaFormScreen({super.key, this.venta});
  final Venta? venta;

  @override
  State<VentaFormScreen> createState() => _VentaFormScreenState();
}

class _VentaFormScreenState extends State<VentaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController clienteController = TextEditingController();
  String estado = "pendiente";
  double total = 0.0;

  List<DetalleVenta> detalles = [];
  final DetalleVentaService detalleService = DetalleVentaService();
  bool loading = false;

  Venta? ventaActual;

  @override
  void initState() {
    super.initState();
    ventaActual = widget.venta;
    if (ventaActual != null) {
      clienteController.text = ventaActual!.cliente;
      estado = ventaActual!.estado;
      total = ventaActual!.total;
      _loadDetalles();
    }
  }

  @override
  void dispose() {
    clienteController.dispose();
    super.dispose();
  }

  Future<void> _loadDetalles() async {
    if (ventaActual != null && ventaActual!.id != null) {
      detalles = await detalleService.getByVentaId(ventaActual!.id!);
      _calcularTotal();
      setState(() {});
    }
  }

  void _calcularTotal() {
    total = detalles.fold(0, (sum, item) => sum + item.Subtotal);
  }

  Future<void> _agregarDetalle() async {
    // Guardar venta primero si es nueva
    if (ventaActual == null || ventaActual!.id == null) {
      final controller = Provider.of<VentaController>(context, listen: false);

      final nuevaVenta = Venta(
        cliente: clienteController.text,
        fecha: DateTime.now().toIso8601String(),
        total: total,
        estado: estado,
      );

      final success = await controller.saveVenta(nuevaVenta);
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Primero guarda la venta antes de agregar detalles")),
        );
        return;
      }

      ventaActual = nuevaVenta; // ahora ventaActual.id tiene valor
    }

    // Crear detalle usando tu modelo exacto
    final nuevoDetalle = DetalleVenta(
      Venta_id: ventaActual!.id!, // ID de la venta
      Producto_id: 1,             // ID del producto de ejemplo
      Cantidad: 1,                // cantidad int
      PrecioUnitario: 100.0,      // double
      Subtotal: 100.0,            // double
    );

    await detalleService.create(nuevoDetalle);

    setState(() {
      detalles.add(nuevoDetalle);
      _calcularTotal();
    });
  }

  Future<void> _guardarVenta() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      loading = true;
    });

    final controller = Provider.of<VentaController>(context, listen: false);

    final venta = Venta(
      id: ventaActual?.id,
      cliente: clienteController.text,
      fecha: DateTime.now().toIso8601String(),
      total: total,
      estado: estado,
    );

    final success = await controller.saveVenta(venta);

    setState(() {
      loading = false;
    });

    if (success) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al guardar la venta")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primary = Colors.green.shade700;

    return Scaffold(
      appBar: AppBar(title: Text(ventaActual != null ? "Editar Venta" : "Nueva Venta")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: TextFormField(
                controller: clienteController,
                decoration: const InputDecoration(
                  labelText: "Cliente",
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) => value!.isEmpty ? "Ingresa un cliente" : null,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text("Estado: "),
                DropdownButton<String>(
                  value: estado,
                  items: const [
                    DropdownMenuItem(value: "pendiente", child: Text("Pendiente")),
                    DropdownMenuItem(value: "pagada", child: Text("Pagada")),
                    DropdownMenuItem(value: "cancelada", child: Text("Cancelada")),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        estado = value;
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Detalles de la venta:", style: TextStyle(fontWeight: FontWeight.bold)),
                ElevatedButton(
                  onPressed: _agregarDetalle,
                  child: const Text("Agregar producto"),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: detalles.isEmpty
                  ? const Center(child: Text("No hay productos agregados"))
                  : ListView.builder(
                      itemCount: detalles.length,
                      itemBuilder: (context, i) {
                        final d = detalles[i];
                        return ListTile(
                          title: Text("Producto ${d.Producto_id}"),
                          subtitle: Text("${d.Cantidad} x \$${d.PrecioUnitario}"),
                          trailing: Text("\$${d.Subtotal}"),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
            Text(
              "Total: \$${total.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: primary),
                onPressed: loading ? null : _guardarVenta,
                child: loading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text("Guardar Venta"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
