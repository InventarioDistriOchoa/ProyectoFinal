import 'dart:ui';
import 'package:flutter/material.dart';
import '/models/proveedor.dart';
import '/services/proveedores_service.dart';

class ProveedoresListaScreen extends StatefulWidget {
  const ProveedoresListaScreen({super.key});

  @override
  State<ProveedoresListaScreen> createState() => _ProveedoresListaScreenState();
}

class _ProveedoresListaScreenState extends State<ProveedoresListaScreen> {
  final ProveedoresService api = ProveedoresService(); // ← nuevo service
  List<Proveedor> proveedores = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    cargarProveedores();
  }

  void cargarProveedores() async {
    try {
      proveedores = await api.getProveedores();
    } catch (e) {
      print("Error cargando proveedores: $e");
    }
    setState(() => loading = false);
  }

  void eliminarProveedor(int id) async {
    try {
      await api.deleteProveedor(id);
      setState(() => proveedores.removeWhere((p) => p.idProveedor == id));
    } catch (e) {
      print("Error eliminando proveedor: $e");
    }
  }

  void abrirModalEditar(Proveedor proveedor) {
    final editNombre = TextEditingController(text: proveedor.nombreEmpresa);
    final editDireccion = TextEditingController(text: proveedor.direccion);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 330,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Editar Proveedor",
                    style: TextStyle(
                      fontSize: 20,
                      color: Color(0xFF2E7D32),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Nombre
                  TextField(
                    controller: editNombre,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.green.shade50,
                      labelText: "Nombre Empresa",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Dirección
                  TextField(
                    controller: editDireccion,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.green.shade50,
                      labelText: "Dirección",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Botones
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancelar"),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          proveedor.nombreEmpresa = editNombre.text;
                          proveedor.direccion = editDireccion.text;

                          try {
                            await api.updateProveedor(proveedor);
                            setState(() {});
                            Navigator.pop(context);
                          } catch (e) {
                            print("Error actualizando: $e");
                          }
                        },
                        child: const Text("Guardar"),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Fondo
          Positioned.fill(
            child: Image.asset(
              "assets/img/FONDO-USER2.jpg",
              fit: BoxFit.cover,
            ),
          ),

          // Desenfoque
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(color: Colors.black.withOpacity(0.25)),
            ),
          ),

          // Contenido
          SafeArea(
            child: loading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : Column(
                    children: [
                      const SizedBox(height: 10),
                      const Text(
                        "Lista de Proveedores",
                        style: TextStyle(
                          fontSize: 26,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),

                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.85),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(25),
                            ),
                          ),
                          child: ListView.builder(
                            padding: const EdgeInsets.all(10),
                            itemCount: proveedores.length,
                            itemBuilder: (_, index) {
                              final p = proveedores[index];
                              return Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: ListTile(
                                  leading: const Icon(Icons.store,
                                      color: Colors.green),
                                  title: Text(p.nombreEmpresa),
                                  subtitle: Text(p.direccion),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit,
                                            color: Colors.blue),
                                        onPressed: () => abrirModalEditar(p),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors.red),
                                        onPressed: () =>
                                            eliminarProveedor(p.idProveedor),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
