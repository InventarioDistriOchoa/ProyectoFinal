import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/entrada_controller.dart';
import '../../models/entrada_model.dart';
import 'entrada_form_screen.dart';

class EntradaListScreen extends StatefulWidget {
  const EntradaListScreen({super.key});

  @override
  State<EntradaListScreen> createState() => _EntradaListScreenState();
}

class _EntradaListScreenState extends State<EntradaListScreen> {
  @override
  void initState() {
    super.initState();
    final controller = Provider.of<EntradaController>(context, listen: false);
    controller.cargarDatos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Entradas")),
      body: Consumer<EntradaController>(
        builder: (context, controller, child) {
          if (controller.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.lista.isEmpty) {
            return const Center(child: Text("No hay entradas registradas"));
          }

          return RefreshIndicator(
            onRefresh: () => controller.cargarDatos(),
            child: ListView.builder(
              itemCount: controller.lista.length,
              itemBuilder: (context, index) {
                final entrada = controller.lista[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(entrada.descripcion),
                    subtitle: Text(
                        "Fecha: ${entrada.fecha}\nCantidad: ${entrada.cantidad}\nProducto ID: ${entrada.productoId}"),
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
                                builder: (_) => EntradaFormScreen(entrada: entrada),
                              ),
                            );
                            if (result == true) {
                              controller.cargarDatos();
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
                                    "¿Deseas eliminar esta entrada?"),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text("Cancelar"),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: const Text("Eliminar"),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              await controller.eliminar(entrada);
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
            MaterialPageRoute(builder: (_) => const EntradaFormScreen()),
          );
          if (result == true) {
            Provider.of<EntradaController>(context, listen: false).cargarDatos();
          }
        },
      ),
    );
  }
}
