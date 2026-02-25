import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/app_colors.dart';
import '../../config/env_config.dart';
import '../../services/api_service.dart';
import '../../config/api_endpoints.dart';

class DetalleVentaScreen extends StatefulWidget {
  const DetalleVentaScreen({super.key});

  @override
  State<DetalleVentaScreen> createState() => _DetalleVentaScreenState();
}

class _DetalleVentaScreenState extends State<DetalleVentaScreen> {
  final ApiService _api = ApiService();

  bool loading = true;

  List<dynamic> ventas = [];
  List<dynamic> productos = [];
  List<dynamic> detalles = [];

  String ventaSeleccionada = '';
  String search = '';
  String idFilter = '';

  String token = '';

  int _currentIndex = 2; // 0 inicio, 1 ventas, 2 detalle (aquí)

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token') ?? '';
    await fetchAll();
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

  Future<void> fetchAll() async {
    setState(() => loading = true);
    try {
      final resV = await _api.get(ApiEndpoints.ventas, useToken: true);
      final resP = await _api.get(ApiEndpoints.productos, useToken: true);
      final resD = await _api.get(ApiEndpoints.detalleVentas, useToken: true);

      final dataV = jsonDecode(resV.body);
      final dataP = jsonDecode(resP.body);
      final dataD = jsonDecode(resD.body);

      ventas = (dataV['body'] as List?) ?? [];
      productos = (dataP['body'] as List?) ?? [];
      detalles = (dataD['body'] as List?) ?? [];
    } finally {
      setState(() => loading = false);
    }
  }

  String _fecha(dynamic raw) {
    final s = raw?.toString() ?? '';
    if (s.contains('T')) return s.split('T').first;
    return s;
  }

  Future<void> _verFactura(int ventaId) async {
    final url = '${EnvConfig.baseUrl}/factura/$ventaId/$token';
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir la factura')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final rows = detalles.map((d) {
      final venta = ventas.firstWhere(
        (v) => (v['idVenta']).toString() == (d['Venta_id']).toString(),
        orElse: () => null,
      );
      final prod = productos.firstWhere(
        (p) => (p['idProducto']).toString() == (d['Producto_id']).toString(),
        orElse: () => null,
      );

      return {
        'id': d['idDetalleVenta'],
        'ventaId': d['Venta_id'],
        'ventaLabel': '#${d['Venta_id']}',
        'fecha': venta != null ? _fecha(venta['Fecha']) : '—',
        'producto': prod != null ? (prod['Nombre'] ?? prod['nombre'] ?? '—') : '—',
        'cantidad': d['Cantidad'],
        'precioUnitario': d['PrecioUnitario'],
        'subtotal': d['Subtotal'],
      };
    }).toList();

    final filtrado = rows.where((r) {
      final byVenta = ventaSeleccionada.isEmpty || r['ventaId'].toString() == ventaSeleccionada;

      final q = search.trim().toLowerCase();
      final bySearch = q.isEmpty ||
          r['producto'].toString().toLowerCase().contains(q) ||
          r['fecha'].toString().toLowerCase().contains(q);

      final idq = idFilter.trim();
      final byId = idq.isEmpty ||
          r['id'].toString().contains(idq) ||
          r['ventaId'].toString().contains(idq);

      return byVenta && bySearch && byId;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'Detalle de Venta',
          style: TextStyle(color: AppColors.negroSuave, fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: AppColors.negroSuave),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                  child: DropdownButtonFormField<String>(
                    initialValue: ventaSeleccionada.isEmpty ? null : ventaSeleccionada,
                    items: [
                      const DropdownMenuItem(value: '', child: Text('Todas las ventas')),
                      ...ventas.map(
                        (v) => DropdownMenuItem(
                          value: v['idVenta'].toString(),
                          child: Text('#${v['idVenta']} - ${_fecha(v['Fecha'])}'),
                        ),
                      ),
                    ],
                    onChanged: (v) => setState(() => ventaSeleccionada = v ?? ''),
                    decoration: InputDecoration(
                      labelText: 'Filtrar por Venta',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          onChanged: (v) => setState(() => search = v),
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.search),
                            hintText: 'Buscar (producto, fecha...)',
                            filled: true,
                            fillColor: Colors.white,
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
                          onChanged: (v) => setState(() => idFilter = v),
                          decoration: InputDecoration(
                            hintText: 'ID/Venta',
                            filled: true,
                            fillColor: Colors.white,
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

                Expanded(
                  child: filtrado.isEmpty
                      ? const Center(child: Text('No hay detalles de venta.'))
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                          itemCount: filtrado.length,
                          itemBuilder: (_, i) {
                            final r = filtrado[i];
                            return Container(
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
                                  )
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Detalle #${r['id']} • Venta ${r['ventaLabel']}',
                                    style: const TextStyle(fontWeight: FontWeight.w900),
                                  ),
                                  const SizedBox(height: 4),
                                  Text('Fecha: ${r['fecha']}'),
                                  Text('Producto: ${r['producto']}'),
                                  Text(
                                    'Cantidad: ${r['cantidad']} • Precio: ${r['precioUnitario']} • Subtotal: ${r['subtotal']}',
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: () => _verFactura(int.parse(r['ventaId'].toString())),
                                          icon: const Icon(Icons.picture_as_pdf_outlined),
                                          label: const Text('Ver factura'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      bottomNavigationBar: _buildBottomNav(), // ✅ agregado
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, -3),
          ),
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
              Icon(
                icon,
                size: 22,
                color: selected ? AppColors.verde : AppColors.negroSuave,
              ),
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
