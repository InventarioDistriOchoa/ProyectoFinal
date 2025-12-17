import 'package:flutter/material.dart';
import '../models/persona_model.dart';
import '../services/persona_service.dart';

class PersonaController extends ChangeNotifier {
  final PersonaService service = PersonaService();

  List<Persona> lista = [];
  bool loading = false;

  Future<void> cargarDatos() async {
    loading = true;
    notifyListeners();

    try {
      lista = await service.getAll();
    } catch (e) {
      lista = [];
      debugPrint("Error cargando personas: $e");
    }

    loading = false;
    notifyListeners();
  }

  Future<void> guardar(Persona p) async {
    if (p.id == null) {
      await service.create(p);
    } else {
      await service.update(p);
    }
    await cargarDatos();
  }

  Future<void> eliminar(Persona p) async {
    await service.delete(p.id!);
    await cargarDatos();
  }
}
