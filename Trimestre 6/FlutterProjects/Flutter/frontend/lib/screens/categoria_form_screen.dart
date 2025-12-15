import 'package:flutter/material.dart';
import '../models/categoria_model.dart';
import '../services/categoria_service.dart';

class CategoriaForm extends StatefulWidget {
  final Categoria? categoria;

  const CategoriaForm({super.key, this.categoria});

  @override
  State<CategoriaForm> createState() => _CategoriaFormState();
}

class _CategoriaFormState extends State<CategoriaForm> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final CategoriaService _service = CategoriaService();

  bool _loading = false;

  final Color primaryGreen = const Color(0xFF27AE60);
  final Color greenHover = const Color(0xFF219150);

  @override
  void initState() {
    super.initState();
    
    // Prellenar si venimos a editar
    if (widget.categoria != null) {
      _nombreController.text = widget.categoria!.nombreCategoria;
      _descripcionController.text = widget.categoria!.descripcion;
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final nombre = _nombreController.text.trim();
    final descripcion = _descripcionController.text.trim();

    setState(() => _loading = true);

    try {
      if (widget.categoria == null) {
        // Crear
        await _service.crearCategoria(nombre, descripcion);
      } else {
        // Editar
        await _service.actualizarCategoria(
          widget.categoria!.idCategoria,
          nombre,
          descripcion,
        );
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final esEditar = widget.categoria != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        title: Text(esEditar ? "Editar Categoría" : "Nueva Categoría"),
        backgroundColor: primaryGreen,
        elevation: 4,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            width: 420,
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.10),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    esEditar ? "Editar Categoría" : "Nueva Categoría",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 25),

                  // NOMBRE
                  TextFormField(
                    controller: _nombreController,
                    decoration: const InputDecoration(
                      labelText: "Nombre",
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? "Ingresa un nombre" : null,
                  ),
                  const SizedBox(height: 20),

                  // DESCRIPCIÓN
                  TextFormField(
                    controller: _descripcionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: "Descripción",
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? "Ingresa una descripción" : null,
                  ),
                  const SizedBox(height: 30),

                  // BOTÓN GUARDAR
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: _loading ? null : _guardar,
                      child: _loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              esEditar ? "Actualizar" : "Guardar",
                              style: const TextStyle(fontSize: 16),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
