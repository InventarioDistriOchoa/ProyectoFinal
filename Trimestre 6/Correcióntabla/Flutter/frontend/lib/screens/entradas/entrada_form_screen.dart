import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/entrada_controller.dart';
import '../../models/entrada_model.dart';

class EntradaFormScreen extends StatefulWidget {
  final Entrada? entrada;
  const EntradaFormScreen({super.key, this.entrada});

  @override
  State<EntradaFormScreen> createState() => _EntradaFormScreenState();
}

class _EntradaFormScreenState extends State<EntradaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController descripcionController = TextEditingController();
  final TextEditingController cantidadController = TextEditingController();
  final TextEditingController productoIdController = TextEditingController();
  DateTime fecha = DateTime.now();

  bool loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.entrada != null) {
      descripcionController.text = widget.entrada!.descripcion;
      cantidadController.text = widget.entrada!.cantidad.toString();
      productoIdController.text = widget.entrada!.productoId.toString();
      fecha = DateTime.parse(widget.entrada!.fecha);
    }
  }

  Future<void> _guardarEntrada() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    final controller = Provider.of<EntradaController>(context, listen: false);

    final entrada = Entrada(
      idEntrada: widget.entrada?.idEntrada,
      fecha: fecha.toIso8601String(),
      descripcion: descripcionController.text,
      cantidad: int.parse(cantidadController.text),
      productoId: int.parse(productoIdController.text),
    );

    final success = await controller.guardar(entrada);

    setState(() => loading = false);

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final primary = Colors.green.shade700;

    return Scaffold(
      appBar: AppBar(
          title: Text(widget.entrada != null ? "Editar Entrada" : "Nueva Entrada")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: descripcionController,
                  decoration: const InputDecoration(labelText: "Descripción"),
                  validator: (value) =>
                      value!.isEmpty ? "Ingresa una descripción" : null,
                ),
                TextFormField(
                  controller: cantidadController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Cantidad"),
                  validator: (value) =>
                      value!.isEmpty ? "Ingresa cantidad" : null,
                ),
                TextFormField(
                  controller: productoIdController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Producto ID"),
                  validator: (value) =>
                      value!.isEmpty ? "Ingresa Producto ID" : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text("Fecha: "),
                    Text("${fecha.toLocal()}".split(' ')[0]),
                    IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: fecha,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null && picked != fecha) {
                          setState(() => fecha = picked);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: primary),
              onPressed: loading ? null : _guardarEntrada,
              child: loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Guardar Entrada"),
            ),
          ),
        ]),
      ),
    );
  }
}
