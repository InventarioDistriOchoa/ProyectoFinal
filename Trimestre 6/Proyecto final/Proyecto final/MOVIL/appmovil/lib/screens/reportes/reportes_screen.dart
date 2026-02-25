import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../config/app_colors.dart';
import '../../controllers/reportes_controller.dart';

class ReportesScreen extends StatefulWidget {
  const ReportesScreen({super.key});

  @override
  State<ReportesScreen> createState() => _ReportesScreenState();
}

class _ReportesScreenState extends State<ReportesScreen> {
  // ✅ Solo 5 tabs (0..4)
  // Esta pantalla no está en el nav, así que dejamos un index válido.
  int _currentIndex = 0;

  // Alertas (buscador + paginación)
  final _searchCtrl = TextEditingController();
  int _page = 1;
  static const int _itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<ReportesController>().cargarReportes();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onMainNavTap(int i) {
    if (i == _currentIndex) return;
    setState(() => _currentIndex = i);

    // ✅ Rutas para ambos (admin / empleado)
    if (i == 0) Navigator.pushReplacementNamed(context, '/dashboard'); // Inicio
    if (i == 1) Navigator.pushReplacementNamed(context, '/stock'); // Stock
    if (i == 2) Navigator.pushReplacementNamed(context, '/registro-productos'); // Productos
    if (i == 3) Navigator.pushReplacementNamed(context, '/ventas'); // Ventas
    if (i == 4) Navigator.pushReplacementNamed(context, '/registro-entradas'); // Entradas
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<ReportesController>();
    final isAdmin = ctrl.isAdmin;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0.6,
        backgroundColor: Colors.white,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.negroSuave),
        title: const Text(
          '📊 Reportes del Inventario',
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
                    onRetry: () =>
                        context.read<ReportesController>().cargarReportes(),
                  )
                : LayoutBuilder(
                    builder: (context, c) {
                      final wide = c.maxWidth >= 900;

                      final leftColumn = <Widget>[
                        if (isAdmin) _ActionRowWebLike(ctrl: ctrl),

                        _ChartCard(
                          title: 'Productos más vendidos',
                          subtitle: 'Unidades vendidas (top).',
                          child: SizedBox(
                            height: 280,
                            child: ctrl.productosMasVendidos.isEmpty
                                ? const _EmptyChart(
                                    text: 'No hay ventas registradas.',
                                  )
                                : _BarChartLabelOnBar(
                                    data: ctrl.productosMasVendidos,
                                  ),
                          ),
                        ),

                        _AlertasCardWebLike(
                          ctrl: ctrl,
                          searchCtrl: _searchCtrl,
                          page: _page,
                          itemsPerPage: _itemsPerPage,
                          onPageChanged: (p) => setState(() => _page = p),
                          onSearchChanged: () => setState(() => _page = 1),
                        ),

                        _ChartCard(
                          title: 'Entradas por mes',
                          subtitle: 'Entradas mensuales.',
                          child: SizedBox(
                            height: 280,
                            child: ctrl.entradasVsVentas.isEmpty
                                ? const _EmptyChart(
                                    text: 'No hay datos suficientes.',
                                  )
                                : _LineChartEntradasSolo(
                                    data: ctrl.entradasVsVentas,
                                  ),
                          ),
                        ),

                        _ResumenCardWebLike(ctrl: ctrl),
                      ];

                      final rightColumn = <Widget>[
                        _ChartCard(
                          title: 'Distribución por categoría',
                          subtitle: 'Cantidad de productos por categoría.',
                          child: SizedBox(
                            height: 320,
                            child: ctrl.categoriasCount.isEmpty
                                ? const _EmptyChart(text: 'No hay categorías.')
                                : _CategoriasDoughnut(
                                    categoriasCount: ctrl.categoriasCount,
                                  ),
                          ),
                        ),

                        _ChartCard(
                          title: 'Stock actual',
                          subtitle: 'Disponible actual.',
                          child: SizedBox(
                            height: 380,
                            child: ctrl.stockActual.isEmpty
                                ? const _EmptyChart(text: 'No hay productos.')
                                : _BarHorizontalLabelOnBar(
                                    data: ctrl.stockActual,
                                  ),
                          ),
                        ),

                        _ChartCard(
                          title: 'Estado del stock',
                          subtitle: 'Conteo por semáforo.',
                          child: SizedBox(
                            height: 280,
                            child: ctrl.stockPorEstado.isEmpty
                                ? const _EmptyChart(
                                    text: 'No hay datos de estado.',
                                  )
                                : _PieChartSimple(data: ctrl.stockPorEstado),
                          ),
                        ),

                        _ChartCard(
                          title: 'Entradas vs Ventas por mes',
                          subtitle: 'Comparación mensual.',
                          child: SizedBox(
                            height: 300,
                            child: ctrl.entradasVsVentas.isEmpty
                                ? const _EmptyChart(
                                    text: 'No hay datos suficientes.',
                                  )
                                : _LineChartSimple(data: ctrl.entradasVsVentas),
                          ),
                        ),
                      ];

                      if (!wide) {
                        return ListView(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                          children: [
                            if (isAdmin) ...[
                              _ActionRowWebLike(ctrl: ctrl),
                              const SizedBox(height: 12),
                            ],
                            ...leftColumn
                                .where((w) => w is! _ActionRowWebLike)
                                .map(
                                  (w) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: w,
                                  ),
                                ),
                            ...rightColumn.map(
                              (w) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: w,
                              ),
                            ),
                          ],
                        );
                      }

                      return SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                children: leftColumn
                                    .map(
                                      (w) => Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 12),
                                        child: w,
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                children: rightColumn
                                    .map(
                                      (w) => Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 12),
                                        child: w,
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
      ),

      // ✅ MISMO NAV PARA ADMIN Y EMPLEADO
      bottomNavigationBar: _MainBottomNav(
        currentIndex: _currentIndex,
        onTap: _onMainNavTap,
      ),
    );
  }
}

/* ============================
   NAV PRINCIPAL (AMBOS)
============================ */
class _MainBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _MainBottomNav({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex.clamp(0, 4),
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.verde,
      unselectedItemColor: Colors.grey.shade600,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w900),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_rounded),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.inventory_2_rounded),
          label: 'Stock',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_bag_rounded),
          label: 'Productos',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.point_of_sale_rounded),
          label: 'Ventas',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.input_rounded),
          label: 'Entradas',
        ),
      ],
    );
  }
}

/* ============================
   ACTION ROW (ADMIN)
============================ */
class _ActionRowWebLike extends StatelessWidget {
  final ReportesController ctrl;
  const _ActionRowWebLike({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.end,
      children: [
        _GreenActionBtn(
          icon: Icons.receipt_long_rounded,
          text: 'Facturas',
          onTap: () => Navigator.pushNamed(context, '/facturas'),
        ),
        _GreenActionBtn(
          icon: Icons.history_rounded,
          text: 'Historial',
          onTap: () => Navigator.pushNamed(context, '/historial'),
        ),
        _GreenActionBtn(
          icon: Icons.picture_as_pdf_rounded,
          text: 'Exportar PDF',
          onTap: () => ctrl.exportarPdf(context),
        ),
        _GreenActionBtn(
          icon: Icons.table_chart_rounded,
          text: 'Exportar Excel',
          onTap: () => ctrl.exportarExcel(context),
        ),
      ],
    );
  }
}

class _GreenActionBtn extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const _GreenActionBtn({
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.verde,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(text, style: const TextStyle(fontWeight: FontWeight.w900)),
    );
  }
}

/* ============================
   ALERTAS (buscador + paginación)
============================ */
class _AlertasCardWebLike extends StatelessWidget {
  final ReportesController ctrl;
  final TextEditingController searchCtrl;
  final int page;
  final int itemsPerPage;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onSearchChanged;

  const _AlertasCardWebLike({
    required this.ctrl,
    required this.searchCtrl,
    required this.page,
    required this.itemsPerPage,
    required this.onPageChanged,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    final query = searchCtrl.text.trim().toLowerCase();

    final filtered = ctrl.alertasStock.where((a) {
      return a.producto.toLowerCase().contains(query);
    }).toList();

    final totalPages = max(1, (filtered.length / itemsPerPage).ceil());
    final safePage = page.clamp(1, totalPages);

    final start = (safePage - 1) * itemsPerPage;
    final end = min(start + itemsPerPage, filtered.length);
    final List pageItems =
        (start < filtered.length) ? filtered.sublist(start, end) : [];

    return _ChartCard(
      title: 'Alertas de Stock',
      subtitle: 'Busca productos en observación o críticos.',
      child: Column(
        children: [
          TextField(
            controller: searchCtrl,
            onChanged: (_) => onSearchChanged(),
            decoration: InputDecoration(
              hintText: 'Buscar producto...',
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
          const SizedBox(height: 12),
          if (filtered.isEmpty)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: Color(0xFF20C997)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Todo el stock está en óptimas condiciones ✅',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
            )
          else
            Column(
              children: [
                ...pageItems.map(
                  (a) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _AlertaItem(producto: a.producto, estado: a.estado),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton(
                      onPressed:
                          safePage <= 1 ? null : () => onPageChanged(safePage - 1),
                      child: const Text('Anterior'),
                    ),
                    Text(
                      '$safePage / $totalPages',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    OutlinedButton(
                      onPressed: safePage >= totalPages
                          ? null
                          : () => onPageChanged(safePage + 1),
                      child: const Text('Siguiente'),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _AlertaItem extends StatelessWidget {
  final String producto;
  final String estado;
  const _AlertaItem({required this.producto, required this.estado});

  @override
  Widget build(BuildContext context) {
    Color c;
    IconData icon;
    String label;

    final st = estado.toLowerCase().trim();
    if (st == 'rojo') {
      c = const Color(0xFFDC3545);
      icon = Icons.report_gmailerrorred_rounded;
      label = 'Crítico';
    } else if (st == 'amarillo') {
      c = const Color(0xFFFFC107);
      icon = Icons.error_outline_rounded;
      label = 'Observación';
    } else {
      c = const Color(0xFF20C997);
      icon = Icons.check_circle_outline_rounded;
      label = 'Óptimo';
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: c.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: c),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(producto, style: const TextStyle(fontWeight: FontWeight.w900)),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: c.withOpacity(0.12),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: c.withOpacity(0.35)),
            ),
            child: Text(label,
                style: TextStyle(fontWeight: FontWeight.w900, color: c)),
          ),
        ],
      ),
    );
  }
}

/* ============================
   RESUMEN
============================ */
class _ResumenCardWebLike extends StatelessWidget {
  final ReportesController ctrl;
  const _ResumenCardWebLike({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final r = ctrl.resumen;

    Widget item(IconData icon, Color c, String text, String value) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
        ),
        child: Row(
          children: [
            Icon(icon, color: c),
            const SizedBox(width: 10),
            Expanded(child: Text(text, style: const TextStyle(fontWeight: FontWeight.w800))),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
          ],
        ),
      );
    }

    return _ChartCard(
      title: 'Resumen general',
      subtitle: 'Lo más importante del inventario.',
      child: Column(
        children: [
          item(Icons.inventory_2_rounded, AppColors.verde, 'Productos registrados', r.productos.toString()),
          item(Icons.category_rounded, Colors.blue, 'Categorías activas', r.categorias.toString()),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.all_inbox_rounded, color: Colors.orange),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text('Stock total disponible', style: TextStyle(fontWeight: FontWeight.w800)),
                ),
                Text(r.stockTotal.toString(), style: const TextStyle(fontWeight: FontWeight.w900)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/* ============================
   CARD GENERAL
============================ */
class _ChartCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _ChartCard({
    required this.title,
    required this.subtitle,
    required this.child,
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.verde.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.insights_rounded, color: AppColors.verde),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: TextStyle(color: Colors.grey.shade700)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _EmptyChart extends StatelessWidget {
  final String text;
  const _EmptyChart({required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w700),
        textAlign: TextAlign.center,
      ),
    );
  }
}

/* ============================
   CHARTS (BARRAS / DONAS / LINEAS)
============================ */
class _BarChartLabelOnBar extends StatelessWidget {
  final List<BarItem> data;
  const _BarChartLabelOnBar({required this.data});

  @override
  Widget build(BuildContext context) {
    final maxY = data.map((e) => e.value).fold<double>(0.0, (p, n) => n > p ? n : p);
    final top = (maxY <= 0) ? 1.0 : (maxY * 1.2);

    return BarChart(
      BarChartData(
        maxY: top,
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: false),
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            tooltipPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final label = data[groupIndex].label;
              final short = label.length > 14 ? '${label.substring(0, 14)}…' : label;
              return BarTooltipItem(
                '$short\n',
                const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 11),
                children: [
                  TextSpan(
                    text: rod.toY.toInt().toString(),
                    style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white70, fontSize: 10),
                  ),
                ],
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 34,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: TextStyle(color: Colors.grey.shade600, fontSize: 10),
              ),
            ),
          ),
          bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        barGroups: List.generate(data.length, (i) {
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: data[i].value,
                width: 16,
                borderRadius: BorderRadius.circular(8),
                color: AppColors.verde,
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _BarHorizontalLabelOnBar extends StatelessWidget {
  final List<BarItem> data;
  const _BarHorizontalLabelOnBar({required this.data});

  @override
  Widget build(BuildContext context) {
    final list = data.length > 12 ? data.take(12).toList() : data;

    final maxY = list.map((e) => e.value).fold<double>(0.0, (p, n) => n > p ? n : p);
    final top = (maxY <= 0) ? 1.0 : (maxY * 1.2);

    return BarChart(
      BarChartData(
        maxY: top,
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: false),
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            tooltipPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final label = list[groupIndex].label;
              final short = label.length > 14 ? '${label.substring(0, 14)}…' : label;
              final val = list[groupIndex].value;

              return BarTooltipItem(
                '$short\n',
                const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 11),
                children: [
                  TextSpan(
                    text: val.toInt().toString(),
                    style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white70, fontSize: 10),
                  ),
                ],
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 34,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: TextStyle(color: Colors.grey.shade600, fontSize: 10),
              ),
            ),
          ),
          bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        barGroups: List.generate(list.length, (i) {
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: list[i].value,
                width: 14,
                borderRadius: BorderRadius.circular(8),
                color: const Color(0xFF20C997),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _CategoriasDoughnut extends StatelessWidget {
  final Map<String, int> categoriasCount;
  const _CategoriasDoughnut({required this.categoriasCount});

  @override
  Widget build(BuildContext context) {
    final labels = categoriasCount.keys.toList();
    final values = categoriasCount.values.toList();
    final total = values.fold<int>(0, (p, n) => p + n);

    final colors = <Color>[
      const Color(0xFFFFC107),
      const Color(0xFF198754),
      const Color(0xFF0D6EFD),
      const Color(0xFFFD7E14),
      const Color(0xFF6F42C1),
      const Color(0xFF20C997),
      const Color(0xFFDC3545),
    ];

    return Column(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              centerSpaceRadius: 46,
              sectionsSpace: 2,
              sections: List.generate(labels.length, (i) {
                final v = values[i].toDouble();
                final pct = total == 0 ? 0 : (v / total) * 100;
                return PieChartSectionData(
                  value: v,
                  color: colors[i % colors.length],
                  title: pct >= 8 ? '${pct.toStringAsFixed(0)}%' : '',
                  radius: 72,
                  titleStyle: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 11),
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: List.generate(labels.length, (i) {
            final c = colors[i % colors.length];
            final label = labels[i];
            return _LegendDot(
              color: c,
              label: label.length > 14 ? '${label.substring(0, 14)}…' : label,
            );
          }),
        ),
      ],
    );
  }
}

class _LineChartEntradasSolo extends StatelessWidget {
  final List<LineaMesItem> data;
  const _LineChartEntradasSolo({required this.data});

  @override
  Widget build(BuildContext context) {
    final maxY = data.map((e) => e.entradas).fold<double>(0, (p, n) => n > p ? n : p);

    return LineChart(
      LineChartData(
        maxY: (maxY <= 0) ? 1 : maxY * 1.2,
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 34,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: TextStyle(color: Colors.grey.shade600, fontSize: 10),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= data.length) return const SizedBox.shrink();
                final label = data[idx].mes;
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    label.length > 6 ? label.substring(0, 6) : label,
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 10),
                  ),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            color: const Color(0xFF0D6EFD),
            barWidth: 3,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(show: true, color: const Color(0xFF0D6EFD).withOpacity(0.12)),
            spots: List.generate(data.length, (i) => FlSpot(i.toDouble(), data[i].entradas)),
          ),
        ],
      ),
    );
  }
}

class _PieChartSimple extends StatelessWidget {
  final StockEstadoData data;
  const _PieChartSimple({required this.data});

  @override
  Widget build(BuildContext context) {
    final total = data.verde + data.amarillo + data.rojo;
    if (total <= 0) return const _EmptyChart(text: 'Sin datos.');

    return Column(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              centerSpaceRadius: 42,
              sectionsSpace: 2,
              sections: [
                PieChartSectionData(
                  value: data.verde.toDouble(),
                  color: const Color(0xFF20C997),
                  title: '${((data.verde / total) * 100).toStringAsFixed(0)}%',
                  radius: 70,
                  titleStyle: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white),
                ),
                PieChartSectionData(
                  value: data.amarillo.toDouble(),
                  color: const Color(0xFFFFC107),
                  title: '${((data.amarillo / total) * 100).toStringAsFixed(0)}%',
                  radius: 70,
                  titleStyle: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white),
                ),
                PieChartSectionData(
                  value: data.rojo.toDouble(),
                  color: const Color(0xFFDC3545),
                  title: '${((data.rojo / total) * 100).toStringAsFixed(0)}%',
                  radius: 70,
                  titleStyle: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        const Wrap(
          spacing: 10,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            _LegendDot(color: Color(0xFF20C997), label: 'Verde'),
            _LegendDot(color: Color(0xFFFFC107), label: 'Amarillo'),
            _LegendDot(color: Color(0xFFDC3545), label: 'Rojo'),
          ],
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(999)),
          ),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(fontWeight: FontWeight.w900, color: color)),
        ],
      ),
    );
  }
}

class _LineChartSimple extends StatelessWidget {
  final List<LineaMesItem> data;
  const _LineChartSimple({required this.data});

  @override
  Widget build(BuildContext context) {
    final maxY = data
        .map((e) => e.entradas > e.ventas ? e.entradas : e.ventas)
        .fold<double>(0, (p, n) => n > p ? n : p);

    return LineChart(
      LineChartData(
        maxY: (maxY <= 0) ? 1 : maxY * 1.2,
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 34,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: TextStyle(color: Colors.grey.shade600, fontSize: 10),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= data.length) return const SizedBox.shrink();
                final label = data[idx].mes;
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    label.length > 6 ? label.substring(0, 6) : label,
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 10),
                  ),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            color: const Color(0xFF0D6EFD),
            barWidth: 3,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(show: true, color: const Color(0xFF0D6EFD).withOpacity(0.12)),
            spots: List.generate(data.length, (i) => FlSpot(i.toDouble(), data[i].entradas)),
          ),
          LineChartBarData(
            isCurved: true,
            color: const Color(0xFFDC3545),
            barWidth: 3,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(show: true, color: const Color(0xFFDC3545).withOpacity(0.10)),
            spots: List.generate(data.length, (i) => FlSpot(i.toDouble(), data[i].ventas)),
          ),
        ],
      ),
    );
  }
}

/* ============================
   ERROR STATE
============================ */
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
