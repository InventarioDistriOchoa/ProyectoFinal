import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';

import '../../config/app_colors.dart';
import '../../controllers/facturas_controller.dart';

class FacturasScreen extends StatefulWidget {
  const FacturasScreen({super.key});

  @override
  State<FacturasScreen> createState() => _FacturasScreenState();
}

class _FacturasScreenState extends State<FacturasScreen> {
  int _currentIndex = 0; // 0=Inicio, 1=Productos, 2=Ventas
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<FacturasController>().cargar();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onBottomTap(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);

    // ✅ Solo 3 rutas
    if (index == 0) Navigator.pushReplacementNamed(context, '/dashboard');       // Inicio
    if (index == 1) Navigator.pushReplacementNamed(context, '/registro-productos');       // Productos (CAMBIA si tu ruta es otra)
    if (index == 2) Navigator.pushReplacementNamed(context, '/ventas');          // Ventas (CAMBIA si tu ruta es otra)
  }

  Future<void> _verPdf(BuildContext context, String idVenta) async {
    try {
      final ctrl = context.read<FacturasController>();

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      final Uint8List bytes = await ctrl.descargarPdf(idVenta);

      if (mounted) Navigator.pop(context);

      await Printing.layoutPdf(
        onLayout: (_) async => bytes,
        name: 'Factura_$idVenta.pdf',
      );
    } catch (e) {
      if (mounted) {
        // cierra cualquier dialog abierto
        Navigator.of(context, rootNavigator: true).popUntil((r) => r.isFirst);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    }
  }

  void _verDetalles(BuildContext context, String idVenta) {
    Navigator.pushNamed(
      context,
      '/detalle-venta', // ✅ listado detalle venta (CAMBIA si tu ruta real es otra)
      arguments: {'idVenta': idVenta},
    );
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<FacturasController>();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0.6,
        backgroundColor: Colors.white,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.negroSuave),
        title: const Text(
          '📑 Facturas Registradas',
          style: TextStyle(
            color: AppColors.negroSuave,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SafeArea(
        child: ctrl.loading
            ? const Center(child: CircularProgressIndicator())
            : ctrl.error.isNotEmpty
                ? _ErrorState(
                    message: ctrl.error,
                    onRetry: () => context.read<FacturasController>().cargar(),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    children: [
                      TextField(
                        controller: _searchCtrl,
                        onChanged: (v) => ctrl.setFiltro(v),
                        decoration: InputDecoration(
                          hintText: 'Buscar por fecha, venta o responsable',
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      if (ctrl.ventasFiltradas.isEmpty)
                        Text(
                          'No hay facturas disponibles.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w800,
                          ),
                        )
                      else
                        ...ctrl.ventasFiltradas.map((v) {
                          final fecha = v.fecha == null
                              ? '—'
                              : '${v.fecha!.year.toString().padLeft(4, '0')}-${v.fecha!.month.toString().padLeft(2, '0')}-${v.fecha!.day.toString().padLeft(2, '0')}';
                          final responsable = ctrl.responsableDe(v.personaId);

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _FacturaCard(
                              idVenta: v.idVenta,
                              fecha: fecha,
                              total: v.total,
                              responsable: responsable,
                              onVerPdf: () => _verPdf(context, v.idVenta),
                              onVerDetalles: () => _verDetalles(context, v.idVenta),
                            ),
                          );
                        }),
                    ],
                  ),
      ),

      // ✅ Bottom Nav SOLO: Inicio, Productos, Ventas
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onBottomTap,
        selectedItemColor: AppColors.verde,
        unselectedItemColor: Colors.grey.shade600,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w900),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_rounded),
            label: 'Productos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.point_of_sale_rounded),
            label: 'Ventas',
          ),
        ],
      ),
    );
  }
}

class _FacturaCard extends StatelessWidget {
  final String idVenta;
  final String fecha;
  final double total;
  final String responsable;
  final VoidCallback onVerPdf;
  final VoidCallback onVerDetalles;

  const _FacturaCard({
    required this.idVenta,
    required this.fecha,
    required this.total,
    required this.responsable,
    required this.onVerPdf,
    required this.onVerDetalles,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
        border: const Border(
          left: BorderSide(color: AppColors.verde, width: 6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.verde.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.receipt_long_rounded, color: AppColors.verde),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Factura #$idVenta',
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text('Fecha: $fecha', style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('Total: \$${total.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('Responsable: $responsable', style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.verde,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: onVerPdf,
                  child: const Text('Ver PDF', style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.verde,
                    side: const BorderSide(color: AppColors.verde),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: onVerDetalles,
                  child: const Text('Ver Detalles', style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 48, color: Colors.red),
            const SizedBox(height: 10),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.verde,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: onRetry,
              child: const Text('Reintentar', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ],
        ),
      ),
    );
  }
}
