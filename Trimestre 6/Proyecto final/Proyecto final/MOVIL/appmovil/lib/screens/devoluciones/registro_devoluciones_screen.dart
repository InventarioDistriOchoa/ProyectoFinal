import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/app_colors.dart';
import '../../config/env_config.dart';
import '../../controllers/devolucion_controller.dart';
import '../../controllers/tipo_devolucion_controller.dart';
import '../../models/devolucion_model.dart';

class RegistroDevolucionesScreen extends StatefulWidget {
  const RegistroDevolucionesScreen({super.key});

  @override
  State<RegistroDevolucionesScreen> createState() => _RegistroDevolucionesScreenState();
}

class _RegistroDevolucionesScreenState extends State<RegistroDevolucionesScreen> {
  int _vista = 0; // 0 registro, 1 listado

  // Form
  final _formKey = GlobalKey<FormState>();
  final _motivoCtrl = TextEditingController();
  final _cantidadCtrl = TextEditingController(text: '1');

  DateTime _fecha = DateTime.now();
  int? _productoId;
  int? _tipoDevolucionId;

  // Perfil
  bool _loadingProfile = false;
  int? _personaId;
  String _nombreResponsable = '';
  String? _fotoUrl;

  // Productos
  bool _loadingProductos = false;
  List<Map<String, dynamic>> _productos = []; // {idProducto, Nombre}

  // Buscador
  final _searchCtrl = TextEditingController();
  String _query = '';

  // Bottom nav
  int _currentIndex = 1; // 0 inicio, 1 devoluciones, 2 tipo

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initLoad();
    });
  }

  Future<void> _initLoad() async {
    await Future.wait([
      _loadProfile(),
      _loadProductos(),
      context.read<TipoDevolucionController>().cargar(),
      context.read<DevolucionController>().cargar(),
    ]);
  }

  @override
  void dispose() {
    _motivoCtrl.dispose();
    _cantidadCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  // -------------------------
  // Token helper
  // -------------------------
  Future<String> _token() async {
    final prefs = await SharedPreferences.getInstance();
    final t = prefs.getString('token');
    if (t == null) throw Exception('No hay token. Inicia sesión.');
    return t;
  }

  // -------------------------
  // Perfil persona/me
  // -------------------------
  Future<void> _loadProfile() async {
    try {
      setState(() => _loadingProfile = true);
      final token = await _token();
      final uri = Uri.parse('${EnvConfig.baseUrl}/persona/me');
      final res = await http.get(uri, headers: {'Authorization': 'Bearer $token'});

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final body = (data['body'] ?? {}) as Map<String, dynamic>;

        _personaId = (body['idPersona'] ?? 0) is int
            ? body['idPersona'] as int
            : int.tryParse(body['idPersona'].toString());

        _nombreResponsable = (body['Nombre'] ?? '').toString();

        final foto = body['Foto'];
        if (foto != null && foto.toString().trim().isNotEmpty) {
          final f = foto.toString();
          _fotoUrl = f.startsWith('http') ? f : '${EnvConfig.mediaBaseUrl}$f';
        }
      }
    } catch (_) {
      // silencio
    } finally {
      if (mounted) setState(() => _loadingProfile = false);
    }
  }

  // -------------------------
  // Productos GET directo (idProducto + Nombre)
  // -------------------------
  Future<void> _loadProductos() async {
    try {
      setState(() => _loadingProductos = true);
      final token = await _token();

      final uri = Uri.parse('${EnvConfig.baseUrl}/producto/producto');
      final res = await http.get(uri, headers: {'Authorization': 'Bearer $token'});

      final data = jsonDecode(res.body);
      if (res.statusCode == 200) {
        final body = (data['body'] as List?) ?? [];
        _productos = body.map((e) => (e as Map).cast<String, dynamic>()).toList();
      }
    } catch (_) {
      // silencio
    } finally {
      if (mounted) setState(() => _loadingProductos = false);
    }
  }

  String _productoNombre(int id) {
    final p = _productos.firstWhere((x) => (x['idProducto'] ?? -1) == id, orElse: () => {});
    return (p['Nombre'] ?? id.toString()).toString();
  }

  String _tipoNombre(int id) {
    final tCtrl = context.read<TipoDevolucionController>();
    final t = tCtrl.tipos.where((x) => x.idTipoDevolucion == id).toList();
    return t.isEmpty ? id.toString() : t.first.nombreTipo;
  }

  String _fmtDate(DateTime d) {
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '${d.year}-$mm-$dd';
  }

  Future<void> _pickFecha() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(ctx).colorScheme.copyWith(primary: AppColors.verde),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _fecha = picked);
  }

  // -------------------------
  // Crear
  // -------------------------
  Future<void> _registrar() async {
    if (!_formKey.currentState!.validate()) return;

    if (_personaId == null) {
      _snack('No se pudo obtener el responsable (persona).');
      return;
    }

    final motivo = _motivoCtrl.text.trim();
    final cantidad = int.tryParse(_cantidadCtrl.text.trim()) ?? 0;

    if (motivo.isEmpty || cantidad <= 0 || _productoId == null || _tipoDevolucionId == null) {
      _snack('Todos los campos son obligatorios');
      return;
    }

    try {
      await context.read<DevolucionController>().crear(
            DevolucionModel(
              idDevolucion: 0,
              fecha: _fmtDate(_fecha),
              motivo: motivo,
              cantidad: cantidad,
              productoId: _productoId!,
              tipoDevolucionId: _tipoDevolucionId!,
              personaId: _personaId!,
            ),
          );

      _snack('Devolución registrada ✅');
      _motivoCtrl.clear();
      _cantidadCtrl.text = '1';
      setState(() {
        _fecha = DateTime.now();
        _productoId = null;
        _tipoDevolucionId = null;
        _vista = 1;
      });
      await context.read<DevolucionController>().cargar();
    } catch (e) {
      _snack(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  // -------------------------
  // Eliminar
  // -------------------------
  Future<void> _eliminar(DevolucionModel d) async {
    final ok = await _confirm(
      title: '¿Eliminar devolución?',
      message: '¿Seguro que deseas eliminar la devolución #${d.idDevolucion}?',
      confirmText: 'Sí, eliminar',
      danger: true,
    );
    if (ok != true) return;

    try {
      await context.read<DevolucionController>().eliminar(d.idDevolucion);
      _snack('Devolución eliminada ✅');
      await context.read<DevolucionController>().cargar();
    } catch (e) {
      _snack(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  // -------------------------
  // Editar modal (sin overflow)
  // -------------------------
  Future<void> _editar(DevolucionModel d) async {
    final motivoCtrl = TextEditingController(text: d.motivo);
    final cantidadCtrl = TextEditingController(text: d.cantidad.toString());
    DateTime fechaEdit = DateTime.tryParse(d.fecha) ?? DateTime.now();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx2, setStateModal) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              title: Text('Editar Devolución #${d.idDevolucion}', style: const TextStyle(fontWeight: FontWeight.w900)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: ctx2,
                          initialDate: fechaEdit,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) setStateModal(() => fechaEdit = picked);
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(16)),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_month_outlined),
                            const SizedBox(width: 10),
                            Text(_fmtDate(fechaEdit), style: const TextStyle(fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(controller: motivoCtrl, decoration: _dec('Motivo')),
                    const SizedBox(height: 12),
                    TextField(
                      controller: cantidadCtrl,
                      keyboardType: TextInputType.number,
                      decoration: _dec('Cantidad'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx2, false), child: const Text('Cancelar')),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.verde, foregroundColor: Colors.white),
                  onPressed: () => Navigator.pop(ctx2, true),
                  child: const Text('Guardar', style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ],
            );
          },
        );
      },
    );

    if (ok != true) {
      motivoCtrl.dispose();
      cantidadCtrl.dispose();
      return;
    }

    final motivo = motivoCtrl.text.trim();
    final cant = int.tryParse(cantidadCtrl.text.trim()) ?? 0;

    if (motivo.isEmpty || cant <= 0) {
      _snack('La fecha, motivo y cantidad son obligatorios');
      motivoCtrl.dispose();
      cantidadCtrl.dispose();
      return;
    }

    try {
      await context.read<DevolucionController>().editar(
            d.idDevolucion,
            DevolucionModel(
              idDevolucion: d.idDevolucion,
              fecha: _fmtDate(fechaEdit),
              motivo: motivo,
              cantidad: cant,
              productoId: d.productoId,
              tipoDevolucionId: d.tipoDevolucionId,
              personaId: d.personaId,
            ),
          );

      _snack('Devolución actualizada ✅');
      await context.read<DevolucionController>().cargar();
    } catch (e) {
      _snack(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      motivoCtrl.dispose();
      cantidadCtrl.dispose();
    }
  }

  // -------------------------
  // UI helpers
  // -------------------------
  InputDecoration _dec(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
    );
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<bool?> _confirm({
    required String title,
    required String message,
    String confirmText = 'Aceptar',
    bool danger = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              confirmText,
              style: TextStyle(fontWeight: FontWeight.w900, color: danger ? Colors.red : AppColors.verde),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------
  // Bottom nav igual estilo ventas
  // -------------------------
  void _onNavTap(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);

    if (index == 0) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else if (index == 1) {
      Navigator.pushReplacementNamed(context, '/registro-devolucion');
    } else if (index == 2) {
      Navigator.pushReplacementNamed(context, '/registro-tipo-devolucion');
    }
  }

  Widget _buildBottomNav() {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, -3))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _bottomNavItem(index: 0, icon: Icons.home_outlined, label: 'Inicio'),
          _bottomNavItem(index: 1, icon: Icons.undo_outlined, label: 'Devoluciones'),
          _bottomNavItem(index: 2, icon: Icons.assignment_outlined, label: 'Tipos'),
        ],
      ),
    );
  }

  Widget _bottomNavItem({required int index, required IconData icon, required String label}) {
    final selected = _currentIndex == index;

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
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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

  // -------------------------
  // Build
  // -------------------------
  @override
  Widget build(BuildContext context) {
    final devCtrl = context.watch<DevolucionController>();
    final tipoCtrl = context.watch<TipoDevolucionController>();

    final devoluciones = devCtrl.devoluciones;

    final q = _query.trim().toLowerCase();
    final filtradas = q.isEmpty
        ? devoluciones
        : devoluciones.where((d) {
            final s = [
              d.idDevolucion.toString(),
              d.fecha,
              d.motivo,
              d.cantidad.toString(),
              _productoNombre(d.productoId),
              _tipoNombre(d.tipoDevolucionId),
              (d.personaId == _personaId && _nombreResponsable.isNotEmpty)
                  ? _nombreResponsable
                  : d.personaId.toString(),
            ].join(' ').toLowerCase();
            return s.contains(q);
          }).toList();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'Devoluciones',
          style: TextStyle(color: AppColors.negroSuave, fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: AppColors.negroSuave),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: _loadingProfile
                ? const CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.verde,
                    child: SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                    ),
                  )
                : CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 15,
                      backgroundColor: AppColors.verde,
                      backgroundImage: _fotoUrl != null
                          ? NetworkImage(_fotoUrl!)
                          : const AssetImage('assets/img/default-avatar.png') as ImageProvider,
                    ),
                  ),
          ),
        ],
      ),
      body: SafeArea(
        child: (devCtrl.loading || tipoCtrl.loading)
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  const SizedBox(height: 10),
                  _tabs(),
                  const SizedBox(height: 10),
                  Expanded(child: _vista == 0 ? _registro(tipoCtrl) : _listado(filtradas)),
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

  // -------------------------
  // Registro (cards estilo ventas)
  // -------------------------
  Widget _registro(TipoDevolucionController tipoCtrl) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Datos de la devolución',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.verde),
              ),
              const SizedBox(height: 12),

              // Fecha
              TextFormField(
                readOnly: true,
                controller: TextEditingController(text: _fmtDate(_fecha)),
                decoration: _dec('Fecha'),
                onTap: _pickFecha,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _motivoCtrl,
                decoration: _dec('Motivo'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 12),

              // Cantidad + Producto + Tipo  (sin overflow: usamos Wrap)
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  SizedBox(
                    width: 170,
                    child: TextFormField(
                      controller: _cantidadCtrl,
                      keyboardType: TextInputType.number,
                      decoration: _dec('Cantidad'),
                      validator: (v) {
                        final n = int.tryParse((v ?? '').trim()) ?? 0;
                        if (n <= 0) return 'Cantidad inválida';
                        return null;
                      },
                    ),
                  ),
                  SizedBox(
                    width: 260,
                    child: _loadingProductos
                        ? Container(
                            height: 56,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(16)),
                            child: const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                          )
                        : DropdownButtonFormField<int>(
                            isExpanded: true,
                            initialValue: _productoId,
                            decoration: _dec('Producto'),
                            items: _productos.map((p) {
                              final id = p['idProducto'];
                              final idInt = id is int ? id : int.tryParse(id.toString()) ?? 0;
                              final nombre = (p['Nombre'] ?? '').toString();
                              return DropdownMenuItem(
                                value: idInt,
                                child: Text(nombre, maxLines: 1, overflow: TextOverflow.ellipsis),
                              );
                            }).toList(),
                            onChanged: (v) => setState(() => _productoId = v),
                            validator: (v) => v == null ? 'Seleccione' : null,
                          ),
                  ),
                  SizedBox(
                    width: 260,
                    child: DropdownButtonFormField<int>(
                      isExpanded: true,
                      initialValue: _tipoDevolucionId,
                      decoration: _dec('Tipo Devolución'),
                      items: tipoCtrl.tipos
                          .map((t) => DropdownMenuItem(
                                value: t.idTipoDevolucion,
                                child: Text(t.nombreTipo, maxLines: 1, overflow: TextOverflow.ellipsis),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _tipoDevolucionId = v),
                      validator: (v) => v == null ? 'Seleccione' : null,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              TextFormField(
                enabled: false,
                initialValue: _nombreResponsable.isEmpty ? 'Cargando...' : _nombreResponsable,
                decoration: _dec('Responsable'),
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.verde,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  onPressed: _registrar,
                  child: const Text('Registrar devolución', style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------
  // Listado (sin overflow)
  // -------------------------
  Widget _listado(List<DevolucionModel> devoluciones) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
          child: TextField(
            controller: _searchCtrl,
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Buscar (motivo, producto, tipo, fecha...)',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
            ),
          ),
        ),
        Expanded(
          child: devoluciones.isEmpty
              ? const Center(child: Text('No hay devoluciones.'))
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: devoluciones.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _cardDevolucion(devoluciones[i]),
                ),
        ),
      ],
    );
  }

  Widget _cardDevolucion(DevolucionModel d) {
    final responsable = (_personaId != null && d.personaId == _personaId && _nombreResponsable.isNotEmpty)
        ? _nombreResponsable
        : d.personaId.toString();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TOP (sin overflow): Wrap
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text('Devolución #${d.idDevolucion}', style: const TextStyle(fontWeight: FontWeight.w900)),
              _chip(d.fecha, Icons.calendar_month_outlined),
              _chip('Cant: ${d.cantidad}', Icons.numbers_outlined),
              const SizedBox(width: 6),
              _iconAction(Icons.edit, Colors.orange, () => _editar(d)),
              _iconAction(Icons.delete_outline, Colors.red, () => _eliminar(d)),
            ],
          ),

          const SizedBox(height: 10),
          Text(d.motivo, style: TextStyle(color: Colors.grey.shade800, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _pill('Producto: ${_productoNombre(d.productoId)}'),
              _pill('Tipo: ${_tipoNombre(d.tipoDevolucionId)}'),
              _pill('Responsable: $responsable'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _iconAction(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }

  Widget _chip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.verde.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.verde),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.verde)),
        ],
      ),
    );
  }

  Widget _pill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(text, style: TextStyle(color: Colors.grey.shade800, fontWeight: FontWeight.w700)),
    );
  }
}
