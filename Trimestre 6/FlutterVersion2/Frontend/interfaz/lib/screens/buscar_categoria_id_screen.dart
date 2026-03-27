import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart'; // Necesario para TextInputFormatter

// 🌐 CONFIGURACIÓN DE LA API
// ¡AJUSTA ESTA URL! (Usa 10.0.2.2 si estás en el emulador de Android)
const String API_BASE_URL = 'http://localhost/DISTRIOCHOA/Backend';
const String SEARCH_URL = '$API_BASE_URL/buscar_categoria_id.php'; 

// --- Modelo de Datos Simplificado para mostrar el resultado ---
class CategoriaDetalle {
  final int id;
  final String nombre;
  final String descripcion;

  CategoriaDetalle({
    required this.id,
    required this.nombre,
    required this.descripcion,
  });

  factory CategoriaDetalle.fromJson(Map<String, dynamic> json) {
    return CategoriaDetalle(
      id: int.tryParse(json['id'].toString()) ?? 0,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String,
    );
  }
}

class BuscarCategoriaIdScreen extends StatefulWidget {
  const BuscarCategoriaIdScreen({super.key});

  @override
  State<BuscarCategoriaIdScreen> createState() => _BuscarCategoriaIdScreenState();
}

class _BuscarCategoriaIdScreenState extends State<BuscarCategoriaIdScreen> {
  final TextEditingController _idController = TextEditingController();
  CategoriaDetalle? _categoriaEncontrada;
  String? _mensajeError;
  bool _isLoading = false;

  // --- 🌐 FUNCIÓN HTTP: GET (Buscar) ---
  Future<void> _buscarCategoria() async {
    final String idText = _idController.text.trim();

    if (idText.isEmpty) {
      setState(() {
        _mensajeError = 'Por favor, introduce un ID.';
        _categoriaEncontrada = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _mensajeError = null;
      _categoriaEncontrada = null;
    });

    try {
      final url = Uri.parse('$SEARCH_URL?id=$idText');
      final response = await http.get(url);

      if (mounted) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (response.statusCode == 200 && responseData['success'] == true) {
          // Éxito: Categoría encontrada (código 200)
          setState(() {
            _categoriaEncontrada = CategoriaDetalle.fromJson(responseData['data']);
          });
        } else if (response.statusCode == 404) {
          // No encontrado (código 404)
          setState(() {
            _mensajeError = responseData['message'] ?? 'Categoría no encontrada.';
          });
        } else {
          // Error controlado por el backend o error 400
          setState(() {
            _mensajeError = responseData['message'] ?? 'Error al buscar la categoría. Código: ${response.statusCode}';
          });
        }
      }
    } catch (e) {
      // Error de conexión
      if (mounted) {
        setState(() {
          _mensajeError = 'Error de conexión: $e. Revisa tu URL y servidor.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // --- 🧱 WIDGETS ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔍 Buscar categoría por ID'),
        backgroundColor: Colors.blueGrey,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Campo de Texto para el ID
            TextField(
              controller: _idController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly], // Solo números
              decoration: InputDecoration(
                labelText: 'ID de la categoría',
                hintText: 'Ej. 1, 2, 3',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.numbers),
                errorText: (_mensajeError != null && _categoriaEncontrada == null) ? null : null, 
              ),
              onSubmitted: (_) => _buscarCategoria(),
            ),
            const SizedBox(height: 20),

            // Botón Buscar
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _buscarCategoria,
              icon: _isLoading 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.search),
              label: Text(_isLoading ? 'Buscando...' : 'Buscar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
            const SizedBox(height: 30),

            // Contenedor de Resultados/Errores
            _buildResultContainer(),
          ],
        ),
      ),
    );
  }

  // Widget para mostrar el resultado o el error
  Widget _buildResultContainer() {
    if (_isLoading) {
      return const Center(child: Text('Consultando servidor...'));
    } else if (_mensajeError != null && _categoriaEncontrada == null) {
      // Mostrar Error
      return Center(
        child: Text(
          '❌ $_mensajeError',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold),
        ),
      );
    } else if (_categoriaEncontrada != null) {
      // Mostrar Resultado Exitoso
      return Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('✅ Categoría Encontrada:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const Divider(),
              _buildInfoRow('ID:', _categoriaEncontrada!.id.toString()),
              _buildInfoRow('Nombre:', _categoriaEncontrada!.nombre),
              _buildInfoRow('Descripción:', _categoriaEncontrada!.descripcion),
            ],
          ),
        ),
      );
    } else {
      // Mensaje inicial o vacío
      return const Center(child: Text('Introduce un ID y pulsa Buscar.'));
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }
}