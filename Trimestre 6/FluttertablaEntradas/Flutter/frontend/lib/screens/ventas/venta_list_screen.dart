import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/venta_controller.dart';
import '../../models/venta_model.dart';
import 'venta_form_screen.dart';

class VentaListScreen extends StatefulWidget {
  const VentaListScreen({super.key});

  @override
  State<VentaListScreen> createState() => _VentaListScreenState();
}

class _VentaListScreenState extends State<VentaListScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar ventas al iniciar la pantalla
    final controller = Provider.of<VentaController>(context, listen: false);
    controller.loadVentas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ventas"),
      ),
      body: Consumer<VentaController>(
        builder: (context, controller, child) {
          if (controller.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.ventas.isEmpty) {
            return const Center(child: Text("No hay ventas registradas"));
          }

          return RefreshIndicator(
            onRefresh: () => controller.loadVentas(),
            child: ListView.builder(
              itemCount: controller.ventas.length,
              itemBuilder: (context, index) {
                final venta = controller.ventas[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(venta.cliente),
                    subtitle: Text(
                        "Estado: ${venta.estado}\nTotal: \$${venta.total.toStringAsFixed(2)}"),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    VentaFormScreen(venta: venta),
                              ),
                            );
                            if (result == true) {
                              controller.loadVentas();
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text("Confirmar"),
                                content: const Text(
                                    "¿Deseas eliminar esta venta?"),
                                actions: [
                                  TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text("Cancelar")),
                                  TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text("Eliminar")),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              await controller.deleteVenta(venta.id!);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const VentaFormScreen(),
            ),
          );
          if (result == true) {
            Provider.of<VentaController>(context, listen: false).loadVentas();
          }
        },
      ),
    );
  }
}
