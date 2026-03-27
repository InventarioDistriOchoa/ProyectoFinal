import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// 🌐 CONFIGURACIÓN API
const String API_BASE_URL = 'http://localhost/DISTRIOCHOA/Backend';
const String INSERTAR_CATEGORIA_URL = '$API_BASE_URL/insertar_categoria.php';

class InsertarCategoriaScreen extends StatefulWidget {
  const InsertarCategoriaScreen({super.key});

  @override
  State<InsertarCategoriaScreen> createState() => _InsertarCategoriaScreenState();
}

class _InsertarCategoriaScreenState extends State<InsertarCategoriaScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();

  bool _isLoading = false;

  // ✅ ENVÍO FORMATO POST NORMAL (SIN JSON)
  Future<void> _createCategoria() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(INSERTAR_CATEGORIA_URL),
        body: {
          "nombre": _nombreController.text,
          "descripcion": _descripcionController.text,
        },
      );

      if (mounted) {
        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Categoría creada con éxito!')),
          );

          Navigator.pop(context, true); // ✅ REGRESA Y REFRESCA LISTA
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('❌ Error al crear categoría')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('⚠️ Error de conexión: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Nueva Categoría'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la Categoría',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'El nombre es obligatorio' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _descripcionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción (opcional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isLoading ? null : _createCategoria,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Guardar Categoría'),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }
}
