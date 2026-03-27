import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/persona_controller.dart';
import '../../models/persona_model.dart';
import 'persona_form_screen.dart';

class PersonaListScreen extends StatefulWidget {
  const PersonaListScreen({super.key});

  @override
  State<PersonaListScreen> createState() => _PersonaListScreenState();
}

class _PersonaListScreenState extends State<PersonaListScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar personas al iniciar
    final controller = Provider.of<PersonaController>(context, listen: false);
    controller.cargarDatos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Personas"), backgroundColor: Colors.green.shade700),
      body: Consumer<PersonaController>(
        builder: (context, controller, child) {
          if (controller.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.lista.isEmpty) {
            return const Center(child: Text("No hay personas registradas"));
          }

          return RefreshIndicator(
            onRefresh: () => controller.cargarDatos(),
            child: ListView.builder(
              itemCount: controller.lista.length,
              itemBuilder: (context, index) {
                final persona = controller.lista[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(persona.fotoPerfil),
                    ),
                    title: Text(persona.nombre),
                    subtitle: Text("${persona.correo}\nRol: ${persona.rol}\nTipo Doc: ${persona.tipoDocumento}"),
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
                                builder: (_) => PersonaForm(persona: persona),
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
                                content: const Text("¿Deseas eliminar esta persona?"),
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
                              await controller.eliminar(persona);
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
        backgroundColor: Colors.green.shade700,
        child: const Icon(Icons.add),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PersonaForm()),
          );
          if (result == true) {
            Provider.of<PersonaController>(context, listen: false).cargarDatos();
          }
        },
      ),
    );
  }
}
