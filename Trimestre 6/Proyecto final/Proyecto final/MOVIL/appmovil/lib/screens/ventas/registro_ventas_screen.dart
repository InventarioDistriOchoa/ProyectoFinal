import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_colors.dart';
import '../../config/api_endpoints.dart';
import '../../services/api_service.dart';
import '../../controllers/ventas_controller.dart';

class RegistroVentasScreen extends StatefulWidget {
  const RegistroVentasScreen({super.key});

  @override
  State<RegistroVentasScreen> createState() => _RegistroVentasScreenState();
}

class _RegistroVentasScreenState extends State<RegistroVentasScreen> {
  int _vista = 0; // 0 registro, 1 listado
  final _cantidadCtrl = TextEditingController(text: '1');

  String? _productoId;
  List<Map<String, dynamic>> _productos = [];

  final ApiService _api = ApiService();

  int _currentIndex = 1; // 0 inicio, 1 ventas (aquí), 2 detalle

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<VentasController>().init(); // ✅ ahora carga /persona/me
      await _cargarProductos();
      if (mounted) setState(() {}); // refresca por si ya llegó el responsable
    });
  }

  @override
  void dispose() {
    _cantidadCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargarProductos() async {
    try {
      final res = await _api.get(ApiEndpoints.productos, useToken: true);
      if (res.statusCode >= 200 && res.statusCode < 300) {
        final decoded = jsonDecode(res.body);
        final List data = (decoded['body'] as List?) ?? [];
        setState(() {
          _productos = data.map((e) => Map<String, dynamic>.from(e)).toList();
        });
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudieron cargar los productos (${res.statusCode})')),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error cargando productos')),
      );
    }
  }

  void _onNavTap(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);

    if (index == 0) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else if (index == 1) {
      Navigator.pushReplacementNamed(context, '/registro-ventas');
    } else if (index == 2) {
      Navigator.pushReplacementNamed(context, '/detalle-venta');
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<VentasController>();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'Ventas',
          style: TextStyle(
            color: AppColors.negroSuave,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: AppColors.negroSuave),
      ),
      body: SafeArea(
        child: c.loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  const SizedBox(height: 10),
                  _tabs(),
                  const SizedBox(height: 10),

                  // ✅ Si no llegó el responsable, te lo digo claro
                  if (c.personaId == 0)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.orange.withOpacity(0.35)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.warning_amber_rounded, color: Colors.orange),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'No se encontró responsable. Revisa que /persona/me esté devolviendo idPersona.',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 10),
                  Expanded(
                    child: _vista == 0 ? _registro(c) : _listado(c),
                  ),
                ],
              ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _tabs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _tabBtn('Registro', _vista == 0, () => setState(() => _vista = 0)),
        const SizedBox(width: 10),
        _tabBtn('Listado', _vista == 1, () => setState(() => _vista = 1)),
      ],
    );
  }

  Widget _tabBtn(String t, bool on, VoidCallback tap) {
    return ElevatedButton(
      onPressed: tap,
      style: ElevatedButton.styleFrom(
        backgroundColor: on ? AppColors.verde : Colors.white,
        foregroundColor: on ? Colors.white : AppColors.verde,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.verde),
        ),
      ),
      child: Text(t, style: const TextStyle(fontWeight: FontWeight.w800)),
    );
  }

  // =======================
  //   REGISTRO
  // =======================
  Widget _registro(VentasController c) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Datos de la venta',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppColors.verde,
                  ),
                ),
                const SizedBox(height: 12),

                // ✅ Fecha (sin controller nuevo en build)
                TextFormField(
                  readOnly: true,
                  initialValue: c.fecha,
                  decoration: InputDecoration(
                    labelText: 'Fecha',
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onTap: () async {
                    final now = DateTime.now();
                    final picked = await showDatePicker(
                      context: context,
                      firstDate: DateTime(now.year - 2),
                      lastDate: DateTime(now.year + 2),
                      initialDate: DateTime.parse(c.fecha),
                    );
                    if (picked != null) {
                      c.setFecha(picked.toIso8601String().split('T').first);
                      if (mounted) setState(() {}); // refresca el initialValue
                    }
                  },
                ),

                const SizedBox(height: 12),

                // ✅ Responsable (sin controller nuevo en build)
                TextFormField(
                  readOnly: true,
                  initialValue: c.responsableNombre.isEmpty ? '—' : c.responsableNombre,
                  decoration: InputDecoration(
                    labelText: 'Responsable',
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                const Divider(),

                const Text(
                  'Agregar producto al carrito',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),

                DropdownButtonFormField<String>(
                  initialValue: _productoId,
                  items: _productos.map((p) {
                    final nombre = (p['Nombre'] ?? p['nombre'] ?? 'Producto').toString();
                    final precio = (p['Precio'] ??
                            p['PrecioVenta'] ??
                            p['precio'] ??
                            p['precioVenta'] ??
                            0)
                        .toString();
                    return DropdownMenuItem<String>(
                      value: (p['idProducto'] ?? p['ID_Producto'] ?? p['id'] ?? '').toString(),
                      child: Text('$nombre - \$$precio'),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => _productoId = v),
                  decoration: InputDecoration(
                    labelText: 'Producto',
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _cantidadCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Cantidad',
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.verde,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: const BorderSide(color: AppColors.verde),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () {
                          try {
                            if (_productoId == null || _productoId!.isEmpty) {
                              throw Exception('Selecciona un producto');
                            }

                            final cant = int.tryParse(_cantidadCtrl.text.trim()) ?? 0;
                            if (cant <= 0) throw Exception('Cantidad inválida');

                            final p = _productos.firstWhere(
                              (x) =>
                                  (x['idProducto'] ?? x['ID_Producto'] ?? x['id']).toString() ==
                                  _productoId,
                            );

                            final stockVal = (p['Cantidad_Actual'] ??
                                    p['cantidad_actual'] ??
                                    p['stock'] ??
                                    p['disponible'] ??
                                    0)
                                .toString();
                            final stock = int.tryParse(stockVal) ?? 0;

                            final nombre = (p['Nombre'] ?? p['nombre'] ?? 'Producto').toString();

                            final precioRaw = (p['Precio'] ??
                                    p['PrecioVenta'] ??
                                    p['precio'] ??
                                    p['precioVenta'] ??
                                    0)
                                .toString();
                            final precio = double.tryParse(precioRaw) ?? 0;

                            c.agregarAlCarrito(
                              productoId: int.tryParse(_productoId!) ?? 0,
                              nombre: nombre,
                              precio: precio,
                              cantidad: cant,
                              stockDisponible: stock,
                            );

                            _cantidadCtrl.text = '1';
                            setState(() => _productoId = null);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Producto agregado ✅')),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
                            );
                          }
                        },
                        child: const Text('Agregar', style: TextStyle(fontWeight: FontWeight.w800)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Carrito
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.shopping_cart_outlined, color: AppColors.verde),
                    const SizedBox(width: 8),
                    const Text(
                      'Carrito',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.verde),
                    ),
                    const Spacer(),
                    if (c.totalItems > 0)
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.red,
                        child: Text(
                          '${c.totalItems}',
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                if (c.carrito.isEmpty)
                  const Text('No hay productos en el carrito.')
                else
                  Column(
                    children: c.carrito.map((it) {
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(it.nombre, style: const TextStyle(fontWeight: FontWeight.w800)),
                        subtitle: Text('${it.cantidad} x \$${it.precio}  •  Subtotal: \$${it.subtotal.toStringAsFixed(0)}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () => c.quitarDelCarrito(it.productoId),
                        ),
                      );
                    }).toList(),
                  ),
                const Divider(),
                Row(
                  children: [
                    Text('Total: ', style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w700)),
                    Text(
                      '\$${c.totalVenta.toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.verde),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.verde,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      ),
                      onPressed: (c.carrito.isEmpty || c.personaId == 0)
                          ? null
                          : () async {
                              try {
                                await c.registrarVentaCompleta();
                                if (!mounted) return;
                                setState(() => _vista = 1);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Venta registrada ✅')),
                                );
                              } catch (e) {
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
                                );
                              }
                            },
                      child: const Text('Registrar venta', style: TextStyle(fontWeight: FontWeight.w900)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =======================
  //   LISTADO
  // =======================
  Widget _listado(VentasController c) {
    final filtradas = c.ventas.where((v) {
      final q = c.search.toLowerCase();
      final bySearch = q.isEmpty || v.fecha.toLowerCase().contains(q) || v.total.toString().contains(q);
      final byId = c.idFilter.isEmpty || v.idVenta.toString().contains(c.idFilter);
      return bySearch && byId;
    }).toList()
      ..sort((a, b) => b.idVenta.compareTo(a.idVenta));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  onChanged: (v) => setState(() => c.search = v),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Buscar (fecha, total...)',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.number,
                  onChanged: (v) => setState(() => c.idFilter = v),
                  decoration: InputDecoration(
                    hintText: 'ID',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: filtradas.isEmpty
              ? const Center(child: Text('No hay ventas.'))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: filtradas.length,
                  itemBuilder: (_, i) {
                    final v = filtradas[i];
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3))
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
                            child: const Icon(Icons.receipt_long, color: AppColors.verde),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Venta #${v.idVenta}', style: const TextStyle(fontWeight: FontWeight.w900)),
                                const SizedBox(height: 4),
                                Text('Fecha: ${v.fecha}', style: TextStyle(color: Colors.grey.shade700)),
                                const SizedBox(height: 2),
                                Text('Total: \$${v.total.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w800)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // =======================
  //   BOTTOM NAV
  // =======================
  Widget _buildBottomNav() {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, -3)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _bottomNavItem(index: 0, icon: Icons.home_outlined, label: 'Inicio'),
          _bottomNavItem(index: 1, icon: Icons.shopping_cart_outlined, label: 'Ventas'),
          _bottomNavItem(index: 2, icon: Icons.receipt_long_outlined, label: 'Detalle'),
        ],
      ),
    );
  }

  Widget _bottomNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final bool selected = _currentIndex == index;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _onNavTap(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          decoration: BoxDecoration(
            color: selected ? AppColors.verde.withOpacity(0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 22, color: selected ? AppColors.verde : AppColors.negroSuave),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  color: selected ? AppColors.verde : AppColors.negroSuave,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
