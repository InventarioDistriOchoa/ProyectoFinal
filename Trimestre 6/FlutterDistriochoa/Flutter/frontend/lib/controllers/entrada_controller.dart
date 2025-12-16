import 'package:flutter/material.dart';
import '../models/entrada_model.dart';
import '../services/entrada_service.dart';

class EntradaController extends ChangeNotifier {
  final EntradaService service = EntradaService();

  List<Entrada> lista = [];
  bool loading = false;

  Future<void> cargarDatos() async {
    loading = true;
    notifyListeners();

    try {
      lista = await service.getAll();
    } catch (e) {
      lista = [];
      debugPrint("Error cargando entradas: $e");
    }

    loading = false;
    notifyListeners();
  }

  Future<void> guardar(Entrada e) async {
    if (e.idEntrada == null) {
      await service.create(e);
    } else {
      await service.update(e);
    }
    await cargarDatos();
  }

  Future<void> eliminar(Entrada e) async {
    await service.delete(e.idEntrada!);
    await cargarDatos();
  }
}
