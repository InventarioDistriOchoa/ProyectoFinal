import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'insertar_categoria_screen.dart';
import 'actualizar_categoria_screen.dart';
import 'buscar_categoria_id_screen.dart';  // ✅ AGREGADO

// 🌐 CONFIGURACIÓN DE LA API
const String API_BASE_URL = 'http://localhost/DISTRIOCHOA/Backend';
const String LISTAR_CATEGORIAS_URL = '$API_BASE_URL/listar_categorias.php';
const String ELIMINAR_CATEGORIA_URL = '$API_BASE_URL/eliminar_categoria.php';

class Categoria {
  final int id;
  final String nombre;
  final String descripcion;

  Categoria({
    required this.id,
    required this.nombre,
    required this.descripcion,
  });

  factory Categoria.fromJson(Map<String, dynamic> json) {
    return Categoria(
      id: int.tryParse(json['id'].toString()) ?? 0,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String,
    );
  }
}

class ListarCategoriaScreen extends StatefulWidget {
  const ListarCategoriaScreen({super.key});

  @override
  State<ListarCategoriaScreen> createState() =>
      _ListarCategoriaScreenState();
}

class _ListarCategoriaScreenState extends State<ListarCategoriaScreen> {
  late Future<List<Categoria>> futureCategorias;

  @override
  void initState() {
    super.initState();
    futureCategorias = fetchCategorias();
  }

  Future<List<Categoria>> fetchCategorias() async {
    final response = await http.get(Uri.parse(LISTAR_CATEGORIAS_URL));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Categoria.fromJson(json)).toList();
    } else {
      throw Exception(
          'Fallo al cargar las categorías. Código: ${response.statusCode}');
    }
  }

  Future<void> deleteCategoria(int id) async {
    final url = Uri.parse('$ELIMINAR_CATEGORIA_URL?id=$id');

    final response = await http.get(url);

    if (mounted) {
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('✅ Categoría eliminada correctamente!')),
        );
        setState(() {
          futureCategorias = fetchCategorias();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  '❌ Error al eliminar. Código: ${response.statusCode}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🍎 Listado de Categorías'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(   // ✅ LUPA AGREGADA
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BuscarCategoriaIdScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () async {
              final bool? result = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const InsertarCategoriaScreen()),
              );

              if (result == true) {
                setState(() {
                  futureCategorias = fetchCategorias();
                });
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                futureCategorias = fetchCategorias();
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Categoria>>(
        future: futureCategorias,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Text(
                    'Error: ${snapshot.error}. Revisa la conexión a la API.'));
          } else if (snapshot.hasData) {
            if (snapshot.data!.isEmpty) {
              return const Center(
                  child: Text('No hay categorías registradas.'));
            }
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final categoria = snapshot.data![index];

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  child: ListTile(
                    leading:
                        CircleAvatar(child: Text(categoria.id.toString())),
                    title: Text(
                      categoria.nombre,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(categoria.descripcion),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ✅ BOTÓN EDITAR
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ActualizarCategoriaScreen(
                                  id: categoria.id,
                                  nombre: categoria.nombre,
                                  descripcion: categoria.descripcion,
                                ),
                              ),
                            );

                            if (result == true) {
                              setState(() {
                                futureCategorias = fetchCategorias();
                              });
                            }
                          },
                        ),

                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deleteCategoria(categoria.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }

          return const Center(child: Text('Cargando...'));
        },
      ),
    );
  }
}
