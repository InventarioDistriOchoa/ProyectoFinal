import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../config/app_colors.dart';
import '../../config/env_config.dart';

import '../../controllers/entrada_controller.dart';
import '../../models/entrada_model.dart';

class EntradasListScreen extends StatefulWidget {
  const EntradasListScreen({super.key});

  @override
  State<EntradasListScreen> createState() => _EntradasListScreenState();
}

// ====== MODELOS LOCALES (para vista) ======

class _EntradaView {
  final int id;
  final String fecha;
  final int productoId;
  final String productoNombre;
  final int cantidad;
  final int proveedorId;
  final String proveedorNombre;
  final int responsableId;
  final String responsableNombre;

  _EntradaView({
    required this.id,
    required this.fecha,
    required this.productoId,
    required this.productoNombre,
    required this.cantidad,
    required this.proveedorId,
    required this.proveedorNombre,
    required this.responsableId,
    required this.responsableNombre,
  });
}

class _Proveedor {
  final int id;
  final String nombre;
  _Proveedor({required this.id, required this.nombre});
}

class _ProductoMini {
  final int id;
  final String nombre;
  _ProductoMini({required this.id, required this.nombre});
}

class _UsuarioMini {
  final int id;
  final String nombre;
  _UsuarioMini({required this.id, required this.nombre});
}

// ====== STATE ======

class _EntradasListScreenState extends State<EntradasListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _idController = TextEditingController();

  final EntradaController _entradaController = EntradaController();

  // catálogos para mapear nombres (mínimo para que funcione)
  List<_ProductoMini> _productos = [];
  List<_Proveedor> _proveedores = [];
  List<_UsuarioMini> _usuarios = [];

  // View data
  List<_EntradaView> _todasEntradas = [];
  List<_EntradaView> _entradasVisibles = [];

  bool _cargando = true;
  bool _eliminando = false;

  String _busqueda = '';
  String _idExacto = '';

  @override
  void initState() {
    super.initState();
    _initData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _idController.dispose();
    super.dispose();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // ====== CARGA ======

  Future<void> _initData() async {
    setState(() => _cargando = true);

    final token = await _getToken();
    if (token == null) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/select-role');
      return;
    }

    await Future.wait([
      _entradaController.cargarEntradas(),
      _fetchCatalogos(token),
    ]);

    _mapearTodo();
    _aplicarFiltros();

    if (mounted) setState(() => _cargando = false);
  }

  Future<void> _fetchCatalogos(String token) async {
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    try {
      final resP = await http.get(
        Uri.parse('${EnvConfig.baseUrl}/producto/producto'),
        headers: headers,
      );
      final resPr = await http.get(
        Uri.parse('${EnvConfig.baseUrl}/proveedor/proveedor'),
        headers: headers,
      );
      final resU = await http.get(
        Uri.parse('${EnvConfig.baseUrl}/persona/persona'),
        headers: headers,
      );

      if (resP.statusCode == 200) {
        final dataP = jsonDecode(resP.body);
        final list = (dataP['body'] as List?) ?? [];
        _productos = list
            .map((p) => _ProductoMini(
                  id: _toInt(p['idProducto']),
                  nombre: p['Nombre']?.toString() ?? '—',
                ))
            .toList();
      }

      if (resPr.statusCode == 200) {
        final dataPr = jsonDecode(resPr.body);
        final list = (dataPr['body'] as List?) ?? [];
        _proveedores = list
            .map((pr) => _Proveedor(
                  id: _toInt(pr['idProveedor']),
                  nombre: pr['Nombre_Empresa']?.toString() ?? '—',
                ))
            .toList();
      }

      if (resU.statusCode == 200) {
        final dataU = jsonDecode(resU.body);
        final list = (dataU['body'] as List?) ?? [];
        _usuarios = list
            .map((u) => _UsuarioMini(
                  id: _toInt(u['idPersona']),
                  nombre: u['Nombre']?.toString() ?? '—',
                ))
            .toList();
      }
    } catch (e) {
      debugPrint('❌ Error catálogos: $e');
    }
  }

  int _toInt(dynamic v) =>
      v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0;

  void _mapearTodo() {
    final entradas = _entradaController.entradas;

    _todasEntradas = entradas.map<_EntradaView>((EntradaModel e) {
      final prod = _productos.firstWhere(
        (p) => p.id == e.productoId,
        orElse: () => _ProductoMini(id: 0, nombre: '—'),
      );
      final prov = _proveedores.firstWhere(
        (p) => p.id == e.proveedorId,
        orElse: () => _Proveedor(id: 0, nombre: '—'),
      );
      final user = _usuarios.firstWhere(
        (u) => u.id == (e.personaId ?? 0),
        orElse: () => _UsuarioMini(id: 0, nombre: '—'),
      );

      return _EntradaView(
        id: e.idEntrada,
        fecha: e.fecha,
        productoId: e.productoId,
        productoNombre: prod.nombre,
        cantidad: e.cantidad,
        proveedorId: e.proveedorId,
        proveedorNombre: prov.nombre,
        responsableId: e.personaId ?? 0,
        responsableNombre: user.nombre,
      );
    }).toList()
      ..sort((a, b) => b.id.compareTo(a.id));
  }

  void _aplicarFiltros() {
    List<_EntradaView> filtradas = List.of(_todasEntradas);

    final q = _busqueda.trim().toLowerCase();
    if (q.isNotEmpty) {
      filtradas = filtradas.where((e) {
        return e.productoNombre.toLowerCase().contains(q) ||
            e.proveedorNombre.toLowerCase().contains(q) ||
            e.responsableNombre.toLowerCase().contains(q) ||
            e.fecha.toLowerCase().contains(q) ||
            e.id.toString().contains(q);
      }).toList();
    }

    final id = _idExacto.trim();
    if (id.isNotEmpty) {
      filtradas = filtradas.where((e) => e.id.toString() == id).toList();
    }

    setState(() => _entradasVisibles = filtradas);
  }

  // ====== ACCIONES ======

  Future<void> _editarProveedor(_EntradaView entrada) async {
    int selectedProvId = entrada.proveedorId;

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
                'Editar proveedor • Entrada #${entrada.id}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              const Text(
                '⚠️ Solo puedes modificar el proveedor de esta entrada',
                style: TextStyle(fontSize: 13, color: Colors.orange),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                initialValue: selectedProvId == 0 ? null : selectedProvId,
                items: _proveedores
                    .map(
                      (p) => DropdownMenuItem<int>(
                        value: p.id,
                        child: Text(p.nombre),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) selectedProvId = v;
                },
                decoration: InputDecoration(
                  labelText: 'Proveedor',
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
                        final success = await _actualizarProveedorEntrada(
                          entradaId: entrada.id,
                          proveedorId: selectedProvId,
                        );
                        if (success && ctx.mounted) Navigator.of(ctx).pop(true);
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

    if (ok == true) {
      await _initData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Proveedor actualizado ✅')),
        );
      }
    }
  }

  Future<bool> _actualizarProveedorEntrada({
    required int entradaId,
    required int proveedorId,
  }) async {
    try {
      await _entradaController.actualizarProveedorEntrada(
        entradaId: entradaId,
        proveedorId: proveedorId,
      );
      return _entradaController.error == null;
    } catch (_) {
      return false;
    }
  }

  Future<void> _eliminarEntrada(_EntradaView entrada) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar entrada?'),
        content: Text(
          'Vas a eliminar la entrada #${entrada.id}.\nEsta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _eliminando = true);
    final ok = await _deleteEntrada(entrada.id);
    setState(() => _eliminando = false);

    if (ok) {
      await _initData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Entrada eliminada ✅')),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo eliminar ❌')),
        );
      }
    }
  }

  Future<bool> _deleteEntrada(int id) async {
    try {
      await _entradaController.eliminarEntrada(id);
      return _entradaController.error == null;
    } catch (_) {
      return false;
    }
  }

  void _abrirDetalleEntrada(_EntradaView e) {
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
          minChildSize: 0.40,
          maxChildSize: 0.75,
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
                    'Entrada #${e.id}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      Chip(
                        label: Text(e.fecha),
                        avatar: const Icon(Icons.calendar_today, size: 18),
                        backgroundColor: Colors.grey.shade100,
                      ),
                      Chip(
                        label: Text('${e.cantidad} uds'),
                        avatar:
                            const Icon(Icons.inventory_2_outlined, size: 18),
                        backgroundColor: Colors.blue.shade50,
                      ),
                      Chip(
                        label: Text(e.proveedorNombre),
                        avatar: const Icon(Icons.storefront, size: 18),
                        backgroundColor: Colors.orange.shade50,
                      ),
                      Chip(
                        label: Text(e.responsableNombre),
                        avatar: const Icon(Icons.person, size: 18),
                        backgroundColor: Colors.green.shade50,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Producto',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(e.productoNombre, style: const TextStyle(fontSize: 15)),
                  const SizedBox(height: 18),
                  const Text(
                    'Acciones',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _editarProveedor(e);
                          },
                          icon: const Icon(Icons.edit),
                          label: const Text('Editar proveedor'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.verde,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _eliminarEntrada(e);
                          },
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.red),
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

  // ====== UI ======

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white.withOpacity(0.95),
        title: const Text(
          'Lista de entradas',
          style: TextStyle(
            color: AppColors.negroSuave,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.negroSuave),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/registro-entradas'),
        backgroundColor: AppColors.verde,
        icon: const Icon(Icons.add),
        label: const Text('Registrar'),
      ),

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
              label: 'Entradas',
              icon: Icons.input_outlined,
              selected: true,
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) {
                        _busqueda = v;
                        _aplicarFiltros();
                      },
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: 'Buscar (producto, proveedor, responsable...)',
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
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _idController,
                      keyboardType: TextInputType.number,
                      onChanged: (v) {
                        _idExacto = v;
                        _aplicarFiltros();
                      },
                      decoration: InputDecoration(
                        hintText: 'ID exacto',
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
                ],
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: _cargando
                  ? const Center(child: CircularProgressIndicator())
                  : _entradasVisibles.isEmpty
                      ? const Center(
                          child: Text(
                            'No hay entradas para mostrar.',
                            style: TextStyle(color: AppColors.grisOscuro),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _initData,
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                            itemCount: _entradasVisibles.length,
                            itemBuilder: (context, index) {
                              final e = _entradasVisibles[index];
                              return _buildAnimatedCard(e, index);
                            },
                          ),
                        ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                '© 2025 DistriOchoa. Todos los derechos reservados.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ====== Card ======

  Widget _buildAnimatedCard(_EntradaView e, int index) {
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
        onTap: () => _abrirDetalleEntrada(e),
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
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.verde.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.input_outlined, color: AppColors.verde),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      e.productoNombre,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Prov: ${e.proveedorNombre}',
                      style:
                          TextStyle(fontSize: 13, color: Colors.grey.shade600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          e.fecha,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.grisOscuro,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${e.cantidad} uds',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.grisOscuro,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.more_vert, size: 22),
                    onPressed: () => _abrirDetalleEntrada(e),
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
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
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
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
