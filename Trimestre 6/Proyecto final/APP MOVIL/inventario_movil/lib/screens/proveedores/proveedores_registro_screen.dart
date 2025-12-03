import 'dart:ui';
import 'package:flutter/material.dart';
import '/models/proveedor.dart';
import '/services/proveedores_service.dart';
import '/screens/proveedores/proveedores_lista_screen.dart';

class ProveedoresRegistroScreen extends StatefulWidget {
  const ProveedoresRegistroScreen({super.key});

  @override
  State<ProveedoresRegistroScreen> createState() =>
      _ProveedoresRegistroScreenState();
}

class _ProveedoresRegistroScreenState extends State<ProveedoresRegistroScreen> {
  final ProveedoresService api = ProveedoresService();
  final nombreCtrl = TextEditingController();
  final direccionCtrl = TextEditingController();

  void agregarProveedor() async {
    if (nombreCtrl.text.isEmpty || direccionCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Completa todos los campos")),
      );
      return;
    }

    final nuevo = Proveedor(
      idProveedor: 0,
      nombreEmpresa: nombreCtrl.text,
      direccion: direccionCtrl.text,
    );

    try {
      await api.createProveedor(nuevo);

      nombreCtrl.clear();
      direccionCtrl.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Proveedor registrado correctamente")),
      );
    } catch (e) {
      print("Error creando proveedor: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al registrar proveedor")),
      );
    }
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

          // Blur
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(color: Colors.black.withOpacity(0.25)),
            ),
          ),

          // Contenido
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.88),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "Registrar Proveedor",
                        style: TextStyle(
                          fontSize: 24,
                          color: Color(0xFF2E7D32),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Campo nombre
                      TextField(
                        controller: nombreCtrl,
                        decoration: InputDecoration(
                          labelText: "Nombre Empresa",
                          filled: true,
                          fillColor: Colors.green.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Campo dirección
                      TextField(
                        controller: direccionCtrl,
                        decoration: InputDecoration(
                          labelText: "Dirección",
                          filled: true,
                          fillColor: Colors.green.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Botón registrar
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 15),
                        ),
                        onPressed: agregarProveedor,
                        child: const Text("Registrar"),
                      ),

                      const SizedBox(height: 15),

                      // Botón ir a lista
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 15),
                        ),
                        child: const Text("Ver Lista"),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ProveedoresListaScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
