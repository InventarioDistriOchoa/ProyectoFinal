import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_colors.dart';
import '../../controllers/historial_controller.dart';
import '../../models/historial_models.dart';

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  int _currentIndex = 1; // 0=Inicio, 1=Reportes (Historial está dentro del módulo Reportes)
  final _searchCtrl = TextEditingController();
  final _accionTextoCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<HistorialController>().cargar();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _accionTextoCtrl.dispose();
    super.dispose();
  }

  void _onBottomNavTap(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);

    if (index == 0) Navigator.pushReplacementNamed(context, '/dashboard');
    if (index == 1) Navigator.pushReplacementNamed(context, '/reportes');
  }

  Future<void> _pickDate(BuildContext context, {required bool desde}) async {
    final ctrl = context.read<HistorialController>();
    final now = DateTime.now();

    final initial = (desde ? ctrl.fechaDesde : ctrl.fechaHasta) ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 1),
    );

    if (picked == null) return;
    if (desde) {
      ctrl.setFechaDesde(picked);
    } else {
      ctrl.setFechaHasta(picked);
    }
  }

  void _openDetalles(BuildContext context, HistorialRow item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DetallesSheet(item: item),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<HistorialController>();
    final wide = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0.6,
        backgroundColor: Colors.white,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.negroSuave),
        title: const Text(
          '🧾 Historial de Auditoría',
          style: TextStyle(color: AppColors.negroSuave, fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: ctrl.loading
            ? const Center(child: CircularProgressIndicator())
            : ctrl.error.isNotEmpty
                ? _ErrorState(
                    message: ctrl.error,
                    onRetry: () => context.read<HistorialController>().cargar(),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    children: [
                      _FiltersCard(
                        searchCtrl: _searchCtrl,
                        accionTextoCtrl: _accionTextoCtrl,
                        onChanged: () => setState(() {}),
                      ),
                      const SizedBox(height: 12),
                      _InfoBar(text: '${ctrl.filteredData.length} registros encontrados'),
                      const SizedBox(height: 12),

                      if (!wide)
                        ...ctrl.paginatedData.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _HistorialCard(
                              item: item,
                              color: ctrl.accionColor(item.accion),
                              accionTexto: ctrl.getAccionTexto(item),
                              onVer: () => _openDetalles(context, item),
                            ),
                          ),
                        )
                      else
                        _TablaWide(
                          items: ctrl.paginatedData,
                          accionTexto: (i) => ctrl.getAccionTexto(i),
                          color: (a) => ctrl.accionColor(a),
                          onVer: (i) => _openDetalles(context, i),
                        ),

                      const SizedBox(height: 10),
                      _Paginator(
                        page: ctrl.currentPage,
                        total: ctrl.totalPages,
                        onPrev: ctrl.prevPage,
                        onNext: ctrl.nextPage,
                      ),
                    ],
                  ),
      ),

      // ✅ SOLO 2 BOTONES: INICIO + REPORTES
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onBottomNavTap,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.verde,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.insert_chart_outlined_rounded),
            label: 'Reportes',
          ),
        ],
      ),
    );
  }
}

/* ==========================
   FILTERS
========================== */
class _FiltersCard extends StatelessWidget {
  final TextEditingController searchCtrl;
  final TextEditingController accionTextoCtrl;
  final VoidCallback onChanged;

  const _FiltersCard({
    required this.searchCtrl,
    required this.accionTextoCtrl,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<HistorialController>();

    String dateFmt(DateTime? d) {
      if (d == null) return '—';
      return '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    }

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
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Filtros', style: TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          TextField(
            controller: searchCtrl,
            onChanged: (v) {
              ctrl.setSearch(v);
              onChanged();
            },
            decoration: InputDecoration(
              hintText: 'Buscar en todo (usuario, módulo, acción...)',
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
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: ctrl.accionFilter.isEmpty ? null : ctrl.accionFilter,
                  decoration: InputDecoration(
                    labelText: 'Tipo de acción',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'CREATE', child: Text('Crear')),
                    DropdownMenuItem(value: 'UPDATE', child: Text('Actualizar')),
                    DropdownMenuItem(value: 'DELETE', child: Text('Eliminar')),
                    DropdownMenuItem(value: 'ACTIVATE', child: Text('Activar')),
                  ],
                  onChanged: (v) => ctrl.setAccion(v ?? ''),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: ctrl.usuarioFilter.isEmpty ? null : ctrl.usuarioFilter,
                  decoration: InputDecoration(
                    labelText: 'Usuario',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  items: ctrl.usuariosDisponibles
                      .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                      .toList(),
                  onChanged: (v) => ctrl.setUsuario(v ?? ''),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: accionTextoCtrl,
            onChanged: (v) => ctrl.setAccionTexto(v),
            decoration: InputDecoration(
              hintText: 'Palabra en acción (ej: “reactivó”, “desactivó”)',
              filled: true,
              fillColor: Colors.white,
              prefixIcon: const Icon(Icons.filter_alt_rounded),
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
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => (context.findAncestorStateOfType<_HistorialScreenState>())
                      ?._pickDate(context, desde: true),
                  icon: const Icon(Icons.date_range_rounded),
                  label: Text('Desde: ${dateFmt(ctrl.fechaDesde)}'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => (context.findAncestorStateOfType<_HistorialScreenState>())
                      ?._pickDate(context, desde: false),
                  icon: const Icon(Icons.event_rounded),
                  label: Text('Hasta: ${dateFmt(ctrl.fechaHasta)}'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    searchCtrl.clear();
                    accionTextoCtrl.clear();
                    ctrl.limpiarFiltros();
                  },
                  child: const Text('Limpiar filtros'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/* ==========================
   INFO BAR
========================== */
class _InfoBar extends StatelessWidget {
  final String text;
  const _InfoBar({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontWeight: FontWeight.w800))),
        ],
      ),
    );
  }
}

/* ==========================
   CARD MOBILE
========================== */
class _HistorialCard extends StatelessWidget {
  final HistorialRow item;
  final Color color;
  final String accionTexto;
  final VoidCallback onVer;

  const _HistorialCard({
    required this.item,
    required this.color,
    required this.accionTexto,
    required this.onVer,
  });

  @override
  Widget build(BuildContext context) {
    final usuario = item.persona?.nombre?.trim().isNotEmpty == true
        ? item.persona!.nombre!
        : 'Usuario desconocido';

    final fecha =
        '${item.createdAt.year.toString().padLeft(4, '0')}-${item.createdAt.month.toString().padLeft(2, '0')}-${item.createdAt.day.toString().padLeft(2, '0')} '
        '${item.createdAt.hour.toString().padLeft(2, '0')}:${item.createdAt.minute.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 5))
        ],
        border: Border(left: BorderSide(color: color, width: 6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(usuario, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text(accionTexto, style: TextStyle(fontWeight: FontWeight.w900, color: color)),
          const SizedBox(height: 6),
          Text('Módulo: ${item.coleccion}', style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('Fecha: $fecha', style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.verde,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: onVer,
              child: const Text('Ver detalles', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ),
        ],
      ),
    );
  }
}

/* ==========================
   TABLE WIDE
========================== */
class _TablaWide extends StatelessWidget {
  final List<HistorialRow> items;
  final String Function(HistorialRow) accionTexto;
  final Color Function(String) color;
  final void Function(HistorialRow) onVer;

  const _TablaWide({
    required this.items,
    required this.accionTexto,
    required this.color,
    required this.onVer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 5)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: DataTable(
          headingRowColor: WidgetStatePropertyAll(AppColors.verde.withOpacity(0.12)),
          columns: const [
            DataColumn(label: Text('Usuario', style: TextStyle(fontWeight: FontWeight.w900))),
            DataColumn(label: Text('Acción', style: TextStyle(fontWeight: FontWeight.w900))),
            DataColumn(label: Text('Módulo', style: TextStyle(fontWeight: FontWeight.w900))),
            DataColumn(label: Text('Fecha', style: TextStyle(fontWeight: FontWeight.w900))),
            DataColumn(label: Text('Detalles', style: TextStyle(fontWeight: FontWeight.w900))),
          ],
          rows: items.map((item) {
            final usuario = item.persona?.nombre ?? '—';
            final c = color(item.accion);
            final f = item.createdAt;
            final fecha =
                '${f.year}-${f.month.toString().padLeft(2, '0')}-${f.day.toString().padLeft(2, '0')} '
                '${f.hour.toString().padLeft(2, '0')}:${f.minute.toString().padLeft(2, '0')}';

            return DataRow(
              cells: [
                DataCell(Text(usuario)),
                DataCell(Text(accionTexto(item), style: TextStyle(color: c, fontWeight: FontWeight.w900))),
                DataCell(Text(item.coleccion)),
                DataCell(Text(fecha)),
                DataCell(
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.verde, foregroundColor: Colors.white),
                    onPressed: () => onVer(item),
                    child: const Text('Ver'),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

/* ==========================
   Paginator
========================== */
class _Paginator extends StatelessWidget {
  final int page;
  final int total;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _Paginator({
    required this.page,
    required this.total,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: page <= 1 ? null : onPrev,
            child: const Text('⟵ Anterior'),
          ),
        ),
        const SizedBox(width: 10),
        Text('$page / $total', style: const TextStyle(fontWeight: FontWeight.w900)),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton(
            onPressed: page >= total ? null : onNext,
            child: const Text('Siguiente ⟶'),
          ),
        ),
      ],
    );
  }
}

/* ==========================
   Detalles Sheet
========================== */
class _DetallesSheet extends StatelessWidget {
  final HistorialRow item;
  const _DetallesSheet({required this.item});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.read<HistorialController>();

    final prevRaw = ctrl.parseMaybeJson(item.datosAnteriores);
    final nextRaw = ctrl.parseMaybeJson(item.datosNuevos);
    final keys = <String>{...prevRaw.keys, ...nextRaw.keys}.toList()..sort();

    String tituloPrev = 'Datos anteriores';
    String tituloNext = 'Datos nuevos';

    if (item.accion == 'CREATE') {
      tituloPrev = 'Antes de la creación';
      tituloNext = 'Registro creado';
    } else if (item.accion == 'UPDATE') {
      tituloPrev = 'Valores antes de la actualización';
      tituloNext = 'Valores después de la actualización';
    } else if (item.accion == 'DELETE') {
      tituloPrev = 'Registro antes de desactivarse';
      tituloNext = 'Estado final tras la desactivación';
    } else if (item.accion == 'ACTIVATE') {
      tituloPrev = 'Registro antes de la activación';
      tituloNext = 'Estado después de la activación';
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          children: [
            Container(
              width: 42,
              height: 5,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(99)),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Detalles #${item.idAuditoria}',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                  ),
                ),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
              ],
            ),
            const SizedBox(height: 6),
            _kv('Usuario', item.persona?.nombre ?? '—'),
            _kv('Correo', item.persona?.correo ?? '—'),
            _kv('Acción', ctrl.getAccionTexto(item)),
            _kv('Módulo', item.coleccion),
            _kv('Fecha', item.createdAt.toLocal().toString()),
            const SizedBox(height: 12),
            Expanded(
              child: LayoutBuilder(
                builder: (context, c) {
                  final wide = c.maxWidth >= 900;

                  final left = _dataBox(
                    title: tituloPrev,
                    entries: keys
                        .where((k) => prevRaw.containsKey(k))
                        .where((k) => k != 'Contrasena')
                        .map((k) => _entry(ctrl, k, prevRaw[k]))
                        .toList(),
                  );

                  final right = _dataBox(
                    title: tituloNext,
                    entries: keys
                        .where((k) => nextRaw.containsKey(k))
                        .where((k) => k != 'Contrasena')
                        .map((k) => _entry(ctrl, k, nextRaw[k]))
                        .toList(),
                  );

                  if (!wide) {
                    return ListView(
                      children: [
                        left,
                        const SizedBox(height: 12),
                        right,
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(child: left),
                      const SizedBox(width: 12),
                      Expanded(child: right),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          SizedBox(width: 92, child: Text('$k:', style: const TextStyle(fontWeight: FontWeight.w800))),
          Expanded(child: Text(v)),
        ],
      ),
    );
  }

  static Widget _dataBox({required String title, required List<Widget> entries}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          if (entries.isEmpty)
            Text('No se registraron datos.', style: TextStyle(color: Colors.grey.shade600, fontStyle: FontStyle.italic))
          else
            ...entries,
        ],
      ),
    );
  }

  static Widget _entry(HistorialController ctrl, String key, dynamic value) {
    final label = ctrl.labelMap[key] ?? key;
    final rendered = ctrl.renderValue(key, value);

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.w800))),
          const SizedBox(width: 8),
          Expanded(child: Text(rendered)),
        ],
      ),
    );
  }
}

/* ==========================
   ERROR
========================== */
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
