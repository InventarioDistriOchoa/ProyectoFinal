import 'package:flutter/material.dart';
import '../../models/categoria_model.dart';
import '../../services/categoria_service.dart';

class CategoriaFormScreen extends StatefulWidget {
  final Categoria? categoria;

  const CategoriaFormScreen({super.key, this.categoria});

  @override
  State<CategoriaFormScreen> createState() => _CategoriaFormScreenState();
}

class _CategoriaFormScreenState extends State<CategoriaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final CategoriaService _service = CategoriaService();

  late TextEditingController nombreController;
  late TextEditingController descripcionController;

  bool get isEditing => widget.categoria != null;

  @override
  void initState() {
    super.initState();

    nombreController = TextEditingController(
      text: widget.categoria?.nombre ?? "",
    );
    descripcionController = TextEditingController(
      text: widget.categoria?.descripcion ?? "",
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final categoria = Categoria(
      id: widget.categoria?.id,
      nombre: nombreController.text.trim(),
      descripcion: descripcionController.text.trim(),
    );

    try {
      if (isEditing) {
        await _service.update(categoria);
      } else {
        await _service.create(categoria);
      }

      Navigator.pop(context, true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing
              ? "Categoría actualizada"
              : "Categoría creada"),
        ),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primary = const Color(0xFF27AE60);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? "Editar Categoría" : "Nueva Categoría"),
        backgroundColor: primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nombreController,
                decoration: const InputDecoration(
                  labelText: "Nombre",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? "Este campo es obligatorio" : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: descripcionController,
                decoration: const InputDecoration(
                  labelText: "Descripción",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) =>
                    value!.isEmpty ? "Este campo es obligatorio" : null,
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _save,
                  child: Text(
                    isEditing ? "Actualizar" : "Guardar",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
