import 'package:flutter/material.dart';
import '../../models/persona_model.dart';
import '../../services/persona_service.dart';

class PersonaForm extends StatefulWidget {
  final Persona? persona;

  const PersonaForm({super.key, this.persona});

  @override
  State<PersonaForm> createState() => _PersonaFormState();
}

class _PersonaFormState extends State<PersonaForm> {
  final _formKey = GlobalKey<FormState>();
  final PersonaService _service = PersonaService();

  late TextEditingController nombreCtrl;
  late TextEditingController correoCtrl;
  late TextEditingController passCtrl;
  late TextEditingController tipoDocCtrl;
  late TextEditingController rolCtrl;

  @override
  void initState() {
    super.initState();
    nombreCtrl = TextEditingController(text: widget.persona?.nombre ?? "");
    correoCtrl = TextEditingController(text: widget.persona?.correo ?? "");
    passCtrl = TextEditingController(text: widget.persona?.password ?? "");
    tipoDocCtrl = TextEditingController(text: widget.persona?.tipoDocumento ?? "");
    rolCtrl = TextEditingController(text: widget.persona?.rol ?? "");
  }

  void guardar() async {
    if (_formKey.currentState!.validate()) {
      final persona = Persona(
        id: widget.persona?.id ?? 0,
        nombre: nombreCtrl.text,
        correo: correoCtrl.text,
        password: passCtrl.text,
        tipoDocumento: tipoDocCtrl.text,
        rol: rolCtrl.text,
        fotoPerfil: '', // siempre vacío, no se pide
      );

      if (widget.persona == null) {
        await _service.create(persona);
      } else {
        await _service.update(persona);
      }

      if (mounted) Navigator.pop(context);
    }
  }

  InputDecoration decor(String label, IconData icono) {
    return InputDecoration(
      prefixIcon: Icon(icono, color: Colors.green),
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.green.shade400, width: 2),
        borderRadius: BorderRadius.circular(15),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.persona == null ? "Registrar Persona" : "Editar Persona"),
        backgroundColor: Colors.green.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          color: Colors.white,
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.green.shade300, width: 3),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  TextFormField(
                    controller: nombreCtrl,
                    decoration: decor("Nombre", Icons.person),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: correoCtrl,
                    decoration: decor("Correo", Icons.email),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: passCtrl,
                    obscureText: true,
                    decoration: decor("Contraseña", Icons.lock),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: tipoDocCtrl,
                    decoration: decor("Tipo Documento", Icons.credit_card),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: rolCtrl,
                    decoration: decor("Rol", Icons.shield),
                  ),
                  const SizedBox(height: 22),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.all(15),
                    ),
                    onPressed: guardar,
                    child: const Text(
                      "Guardar",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
