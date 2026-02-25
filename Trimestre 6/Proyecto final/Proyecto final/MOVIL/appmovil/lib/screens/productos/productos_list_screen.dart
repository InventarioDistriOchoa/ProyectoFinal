import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/app_colors.dart';
import '../../config/env_config.dart';
import '../../config/api_endpoints.dart';

class ProductosListScreen extends StatefulWidget {
  const ProductosListScreen({super.key});

  @override
  State<ProductosListScreen> createState() => _ProductosListScreenState();
}

// ====== MODELOS LOCALES ======

class _Producto {
  final int idProducto;
  final String nombre;
  final double precio;
  final int cantidad;
  final int categoriaId;
  final String categoriaNombre;

  _Producto({
    required this.idProducto,
    required this.nombre,
    required this.precio,
    required this.cantidad,
    required this.categoriaId,
    required this.categoriaNombre,
  });
}

class _Categoria {
  final int id;
  final String nombre;

  _Categoria({required this.id, required this.nombre});
}

// ====== STATE ======

class _ProductosListScreenState extends State<ProductosListScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<_Producto> _todosProductos = [];
  List<_Producto> _productosVisibles = [];
  List<_Categoria> _categorias = [];

  bool _cargando = true;
  bool _cargandoCategorias = false;
  bool _eliminando = false;

  String _busqueda = '';
  int? _categoriaSeleccionadaId;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    setState(() => _cargando = true);
    await Future.wait([
      _cargarCategorias(),
      _cargarProductos(),
    ]);
    _aplicarFiltros();
    if (mounted) {
      setState(() => _cargando = false);
    }
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token'); // mismo que usas en login/dashboard
  }

  Future<void> _cargarCategorias() async {
    try {
      setState(() => _cargandoCategorias = true);
      final token = await _getToken();
      if (token == null) return;

      final uri =
          Uri.parse('${EnvConfig.baseUrl}${ApiEndpoints.categorias}');
      final res = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final List list = data['body'] ?? data['data'] ?? [];
        _categorias = list
            .map((e) => _Categoria(
                  id: e['idCategoria'] is int
                      ? e['idCategoria']
                      : int.tryParse(e['idCategoria'].toString()) ?? 0,
                  nombre: e['Nombre_Categoria']?.toString() ?? '',
                ))
            .toList();
      }
    } catch (e) {
      debugPrint('Error cargando categorías: $e');
    } finally {
      if (mounted) {
        setState(() => _cargandoCategorias = false);
      }
    }
  }

  Future<void> _cargarProductos() async {
  try {
    final token = await _getToken();
    if (token == null) {
      debugPrint('⚠️ Token nulo al cargar productos');
      return;
    }

    final uri =
        Uri.parse('${EnvConfig.baseUrl}${ApiEndpoints.productos}');
    final res = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    debugPrint('➡️ [PRODUCTOS] status: ${res.statusCode}');
    debugPrint('➡️ [PRODUCTOS] body: ${res.body}');

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);

      // Ajusta esta línea si tu backend usa otra clave
      final List list = data['body'] ?? data['data'] ?? [];

      final List<_Producto> mapeados = list.map<_Producto>((p) {
        // ID
        final int idProd = p['idProducto'] is int
            ? p['idProducto']
            : int.tryParse(p['idProducto'].toString()) ?? 0;

        // Precio (puede venir como num o como String)
        final dynamic precioRaw = p['Precio'];
        double precio;
        if (precioRaw is num) {
          precio = precioRaw.toDouble();
        } else {
          precio = double.tryParse(precioRaw.toString()) ?? 0;
        }

        // Cantidad (num o String)
        final dynamic cantidadRaw = p['Cantidad_Actual'];
        int cantidad;
        if (cantidadRaw is int) {
          cantidad = cantidadRaw;
        } else {
          cantidad = int.tryParse(cantidadRaw.toString()) ?? 0;
        }

        // Categoria_id (num o String)
        final dynamic catRaw = p['Categoria_id'];
        int categoriaId;
        if (catRaw is int) {
          categoriaId = catRaw;
        } else {
          categoriaId = int.tryParse(catRaw.toString()) ?? 0;
        }

        // Nombre de categoría (puede no estar cargada aún, no pasa nada)
        final categoriaNombre = _categorias
                .firstWhere(
                  (c) => c.id == categoriaId,
                  orElse: () => _Categoria(id: 0, nombre: '—'),
                )
                .nombre;

        return _Producto(
          idProducto: idProd,
          nombre: p['Nombre']?.toString() ?? '',
          precio: precio,
          cantidad: cantidad,
          categoriaId: categoriaId,
          categoriaNombre: categoriaNombre,
        );
      }).toList();

      if (mounted) {
        setState(() {
          _todosProductos = mapeados;
        });
        _aplicarFiltros();
      }
    } else {
      debugPrint('❌ Error cargando productos: ${res.body}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudieron cargar los productos'),
          ),
        );
      }
    }
  } catch (e, st) {
    debugPrint('❌ EXCEPCIÓN cargando productos: $e');
    debugPrint(st.toString());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al cargar productos'),
        ),
      );
    }
  }
}


  void _aplicarFiltros() {
    List<_Producto> filtrados = List.of(_todosProductos);

    if (_busqueda.trim().isNotEmpty) {
      final query = _busqueda.trim().toLowerCase();
      filtrados = filtrados.where((p) {
        return p.nombre.toLowerCase().contains(query) ||
            p.categoriaNombre.toLowerCase().contains(query) ||
            p.precio.toString().contains(query);
      }).toList();
    }

    if (_categoriaSeleccionadaId != null) {
      filtrados = filtrados
          .where((p) => p.categoriaId == _categoriaSeleccionadaId)
          .toList();
    }

    setState(() {
      _productosVisibles = filtrados;
    });
  }

  Future<void> _eliminarProducto(_Producto producto) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar producto?'),
        content: Text(
            'Vas a eliminar "${producto.nombre}". Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      setState(() => _eliminando = true);
      final token = await _getToken();
      if (token == null) return;

      final uri = Uri.parse(
          '${EnvConfig.baseUrl}${ApiEndpoints.productos}/${producto.idProducto}');
      final res = await http.delete(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (res.statusCode == 200 || res.statusCode == 204) {
        _todosProductos.removeWhere(
            (p) => p.idProducto == producto.idProducto);
        _aplicarFiltros();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Producto eliminado correctamente'),
            ),
          );
        }
      } else {
        debugPrint('Error al eliminar: ${res.body}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se pudo eliminar el producto'),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error al eliminar producto: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al eliminar producto'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _eliminando = false);
      }
    }
  }

  void _abrirDetalleProducto(_Producto producto) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          minChildSize: 0.35,
          maxChildSize: 0.7,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Text(
                    producto.nombre,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      Chip(
                        label: Text(producto.categoriaNombre),
                        avatar: const Icon(Icons.category, size: 18),
                        backgroundColor: Colors.grey.shade100,
                      ),
                      Chip(
                        label: Text('\$${producto.precio.toStringAsFixed(2)}'),
                        avatar: const Icon(Icons.attach_money, size: 18),
                        backgroundColor: Colors.green.shade50,
                      ),
                      Chip(
                        label: Text('${producto.cantidad} uds'),
                        avatar:
                            const Icon(Icons.inventory_2_outlined, size: 18),
                        backgroundColor: Colors.blue.shade50,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Acciones',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                         onPressed: () {
  Navigator.of(context).pop();
  _abrirModalEditarProducto(producto);
},

                          icon: const Icon(Icons.edit),
                          label: const Text('Editar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.verde,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _eliminarProducto(producto);
                          },
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          label: const Text(
                            'Eliminar',
                            style: TextStyle(color: Colors.red),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }



Future<void> _abrirModalEditarProducto(_Producto producto) async {
  final nombreCtrl = TextEditingController(text: producto.nombre);
  final precioCtrl =
      TextEditingController(text: producto.precio.toStringAsFixed(2));
  final cantidadCtrl =
      TextEditingController(text: producto.cantidad.toString());

  int categoriaId = producto.categoriaId;

  final ok = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Colors.white,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 12,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              'Editar producto #${producto.idProducto}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: nombreCtrl,
              decoration: InputDecoration(
                labelText: 'Nombre',
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: precioCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Precio',
                      prefixText: '\$ ',
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: cantidadCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Cantidad',
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Categoría
            DropdownButtonFormField<int>(
              initialValue: categoriaId == 0 ? null : categoriaId,
              items: _categorias
                  .map(
                    (c) => DropdownMenuItem<int>(
                      value: c.id,
                      child: Text(c.nombre),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                if (v != null) categoriaId = v;
              },
              decoration: InputDecoration(
                labelText: 'Categoría',
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.verde,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () async {
                      final nombre = nombreCtrl.text.trim();
                      final precio =
                          double.tryParse(precioCtrl.text.trim()) ?? -1;
                      final cant =
                          int.tryParse(cantidadCtrl.text.trim()) ?? -1;

                      if (nombre.isEmpty || precio < 0 || cant < 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Campos inválidos'),
                          ),
                        );
                        return;
                      }

                      final success = await _actualizarProducto(
                        id: producto.idProducto,
                        nombre: nombre,
                        precio: precio,
                        cantidad: cant,
                        categoriaId: categoriaId,
                      );

                      if (success && ctx.mounted) {
                        Navigator.of(ctx).pop(true);
                      }
                    },
                    icon: const Icon(Icons.save),
                    label: const Text('Guardar'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );

  nombreCtrl.dispose();
  precioCtrl.dispose();
  cantidadCtrl.dispose();

  if (ok == true) {
    await _cargarProductos();
    _aplicarFiltros();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto actualizado ✅')),
      );
    }
  }
}

Future<bool> _actualizarProducto({
  required int id,
  required String nombre,
  required double precio,
  required int cantidad,
  required int categoriaId,
}) async {
  try {
    final token = await _getToken();
    if (token == null) return false;

    // ⚠️ Ajusta el endpoint si tu backend usa otro (ej: /producto/producto/:id)
    final uri =
        Uri.parse('${EnvConfig.baseUrl}${ApiEndpoints.productos}/$id');

    // ⚠️ Ajusta las keys EXACTAS a lo que tu API espera en PUT
    final body = jsonEncode({
      "Nombre": nombre,
      "Precio": precio,
      "Cantidad_Actual": cantidad,
      "Categoria_id": categoriaId,
    });

    final res = await http.put(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    debugPrint('➡️ [PUT PRODUCTO] status: ${res.statusCode}');
    debugPrint('➡️ [PUT PRODUCTO] body: ${res.body}');

    return res.statusCode == 200 || res.statusCode == 204;
  } catch (e) {
    debugPrint('❌ Error actualizando producto: $e');
    return false;
  }
}

  // ====== UI ======

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white.withOpacity(0.95),
        title: const Text(
          'Lista de productos',
          style: TextStyle(
            color: AppColors.negroSuave,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.negroSuave),
      ),

      // ➕ FAB Registrar producto
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/registro-productos');
        },
        backgroundColor: AppColors.verde,
        icon: const Icon(Icons.add),
        label: const Text('Registrar'),
      ),

      // 🔽 Bottom nav
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _navItem(
              label: 'Inicio',
              icon: Icons.home_outlined,
              selected: false,
              onTap: () => Navigator.pushNamed(context, '/dashboard'),
            ),
            _navItem(
              label: 'Productos',
              icon: Icons.list_alt,
              selected: true, // pantalla actual
              onTap: () {},
            ),
            _navItem(
              label: 'Reportes',
              icon: Icons.bar_chart_outlined,
              selected: false,
              onTap: () => Navigator.pushNamed(context, '/reportes'),
            ),
          ],
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [
            // 🔍 Buscador
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  _busqueda = value;
                  _aplicarFiltros();
                },
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Buscar por nombre, categoría o precio',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // 🏷️ Filtros por categoría
            SizedBox(
              height: 46,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: const Text('Todas'),
                      selected: _categoriaSeleccionadaId == null,
                      onSelected: (_) {
                        setState(() => _categoriaSeleccionadaId = null);
                        _aplicarFiltros();
                      },
                    ),
                  ),
                  ..._categorias.map(
                    (cat) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(cat.nombre),
                        selected: _categoriaSeleccionadaId == cat.id,
                        onSelected: (_) {
                          setState(
                              () => _categoriaSeleccionadaId = cat.id);
                          _aplicarFiltros();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 4),

            // Contenido
            Expanded(
              child: _cargando
                  ? const Center(child: CircularProgressIndicator())
                  : _productosVisibles.isEmpty
                      ? const Center(
                          child: Text(
                            'No hay productos para mostrar.',
                            style: TextStyle(color: AppColors.grisOscuro),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _initData,
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(
                                16, 8, 16, 24),
                            itemCount: _productosVisibles.length,
                            itemBuilder: (context, index) {
                              final producto =
                                  _productosVisibles[index];

                              return _buildAnimatedCard(producto, index);
                            },
                          ),
                        ),
            ),

            // Footer
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                '© 2025 DistriOchoa. Todos los derechos reservados.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ====== Widgets auxiliares ======

  Widget _buildAnimatedCard(_Producto producto, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 350 + index * 40),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: () => _abrirDetalleProducto(producto),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icono redondo
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.verde.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.shopping_bag_outlined,
                  color: AppColors.verde,
                ),
              ),
              const SizedBox(width: 12),

              // Info principal
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      producto.nombre,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      producto.categoriaNombre,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '\$${producto.precio.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.verde,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${producto.cantidad} uds',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.grisOscuro,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Botones rápidos
              Column(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.more_vert,
                      size: 22,
                    ),
                    onPressed: () => _abrirDetalleProducto(producto),
                  ),
                  if (_eliminando)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
        decoration: BoxDecoration(
          color:
              selected ? AppColors.verde.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: selected ? AppColors.verde : Colors.black87,
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: selected ? AppColors.verde : Colors.black87,
                fontWeight:
                    selected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
