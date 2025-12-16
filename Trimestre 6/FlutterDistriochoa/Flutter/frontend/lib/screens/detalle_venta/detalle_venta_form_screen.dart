import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/models/detalle_venta_model.dart';
import '/controllers/detalle_venta_controller.dart';

class DetalleVentaForm extends StatefulWidget {
  final DetalleVenta? detalle;

  DetalleVentaForm({this.detalle});

  @override
  State<DetalleVentaForm> createState() => _DetalleVentaFormState();
}

class _DetalleVentaFormState extends State<DetalleVentaForm> {
  final formKey = GlobalKey<FormState>();

  late TextEditingController cantidadCtrl;
  late TextEditingController precioCtrl;
  late TextEditingController subtotalCtrl;
  late TextEditingController ventaCtrl;
  late TextEditingController productoCtrl;

  @override
  void initState() {
    super.initState();

    cantidadCtrl = TextEditingController(
        text: widget.detalle?.Cantidad.toString() ?? "");
    precioCtrl = TextEditingController(
        text: widget.detalle?.PrecioUnitario.toString() ?? "");
    subtotalCtrl = TextEditingController(
        text: widget.detalle?.Subtotal.toString() ?? "");
    ventaCtrl =
        TextEditingController(text: widget.detalle?.Venta_id.toString() ?? "");
    productoCtrl = TextEditingController(
        text: widget.detalle?.Producto_id.toString() ?? "");
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Provider.of<DetalleVentaController>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.detalle == null ? "Crear Detalle" : "Editar Detalle"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: ListView(
            children: [
              campo("Cantidad", cantidadCtrl, TextInputType.number),
              campo("Precio Unitario", precioCtrl, TextInputType.number),
              campo("Subtotal", subtotalCtrl, TextInputType.number),
              campo("Venta ID", ventaCtrl, TextInputType.number),
              campo("Producto ID", productoCtrl, TextInputType.number),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (!formKey.currentState!.validate()) return;

                  DetalleVenta d = DetalleVenta(
                    idDetalleVenta: widget.detalle?.idDetalleVenta,
                    Cantidad: int.parse(cantidadCtrl.text),
                    PrecioUnitario: double.parse(precioCtrl.text),
                    Subtotal: double.parse(subtotalCtrl.text),
                    Venta_id: int.parse(ventaCtrl.text),
                    Producto_id: int.parse(productoCtrl.text),
                  );

                  ctrl.guardar(d);
                  Navigator.pop(context);
                },
                child: Text("Guardar"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget campo(
      String label, TextEditingController controller, TextInputType tipo) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        keyboardType: tipo,
        decoration: InputDecoration(labelText: label),
        validator: (value) =>
            value!.isEmpty ? "Este campo es obligatorio" : null,
      ),
    );
  }
}
