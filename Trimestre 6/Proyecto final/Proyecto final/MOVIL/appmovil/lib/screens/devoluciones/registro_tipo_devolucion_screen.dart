import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_colors.dart';
import '../../controllers/tipo_devolucion_controller.dart';
import '../../services/tipo_devolucion_service.dart';

class RegistroTipoDevolucionScreen extends StatefulWidget {
  const RegistroTipoDevolucionScreen({super.key});

  @override
  State<RegistroTipoDevolucionScreen> createState() => _RegistroTipoDevolucionScreenState();
}

class _RegistroTipoDevolucionScreenState extends State<RegistroTipoDevolucionScreen> {
  int _vista = 0; // 0 registro, 1 listado
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();

  final _searchCtrl = TextEditingController();
  String _query = '';

  // Bottom nav
  int _currentIndex = 2; // 0 inicio, 1 devoluciones, 2 tipo

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<TipoDevolucionController>().cargar();
    });
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

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

  Future<void> _registrar() async {
    if (!_formKey.currentState!.validate()) return;

    final nombre = _nombreCtrl.text.trim();
    if (nombre.isEmpty) {
      _snack('El nombre es obligatorio');
      return;
    }

    final ctrl = context.read<TipoDevolucionController>();

    try {
      await ctrl.crear(nombre);
      _snack('Tipo de devolución creado ✅');
      _nombreCtrl.clear();
      await ctrl.cargar();
      setState(() => _vista = 1);
    } on TipoDevolucionConflictException catch (e) {
      if (e.desactivado && e.idTipoDevolucion != null) {
        final ok = await _confirm(
          title: 'Ya existe',
          message: '${e.message}\n\nEstá desactivado. ¿Deseas reactivarlo?',
          confirmText: 'Reactivar',
        );

        if (ok == true) {
          await ctrl.activar(e.idTipoDevolucion!);
          _snack('Tipo reactivado ✅');
          _nombreCtrl.clear();
          await ctrl.cargar();
          setState(() => _vista = 1);
        }
      } else {
        _snack(e.message);
      }
    } catch (e) {
      _snack(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _editar(int id, String nombreActual) async {
    final nombreEdit = TextEditingController(text: nombreActual);

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text('Editar Tipo #$id', style: const TextStyle(fontWeight: FontWeight.w900)),
        content: TextField(controller: nombreEdit, decoration: _dec('Nombre')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.verde, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Guardar', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );

    if (ok != true) {
      nombreEdit.dispose();
      return;
    }

    final nuevo = nombreEdit.text.trim();
    if (nuevo.isEmpty) {
      _snack('El nombre es obligatorio');
      nombreEdit.dispose();
      return;
    }

    try {
      await context.read<TipoDevolucionController>().editar(id, nuevo);
      _snack('Tipo actualizado ✅');
      await context.read<TipoDevolucionController>().cargar();
    } catch (e) {
      _snack(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      nombreEdit.dispose();
    }
  }

  Future<void> _eliminar(int id) async {
    final ok = await _confirm(
      title: '¿Eliminar tipo de devolución?',
      message: '¿Seguro que deseas eliminar el tipo #$id?',
      confirmText: 'Sí, eliminar',
      danger: true,
    );
    if (ok != true) return;

    try {
      await context.read<TipoDevolucionController>().eliminar(id);
      _snack('Tipo eliminado ✅');
      await context.read<TipoDevolucionController>().cargar();
    } catch (e) {
      _snack(e.toString().replaceFirst('Exception: ', ''));
    }
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
  // UI
  // -------------------------
  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<TipoDevolucionController>();

    final q = _query.trim().toLowerCase();
    final tipos = q.isEmpty
        ? ctrl.tipos
        : ctrl.tipos.where((t) {
            final s = '${t.idTipoDevolucion} ${t.nombreTipo}'.toLowerCase();
            return s.contains(q);
          }).toList();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'Tipo de Devolución',
          style: TextStyle(color: AppColors.negroSuave, fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: AppColors.negroSuave),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacementNamed(context, '/devoluciones'),
        ),
      ),
      body: SafeArea(
        child: ctrl.loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  const SizedBox(height: 10),
                  _tabs(),
                  const SizedBox(height: 10),
                  Expanded(child: _vista == 0 ? _registro() : _listado(tipos)),
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

  Widget _registro() {
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
                'Crear tipo de devolución',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.verde),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nombreCtrl,
                decoration: _dec('Nombre del tipo'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Campo obligatorio' : null,
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
                  child: const Text('Registrar tipo', style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _listado(List tipos) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
          child: TextField(
            controller: _searchCtrl,
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Buscar (id, nombre...)',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
            ),
          ),
        ),
        Expanded(
          child: tipos.isEmpty
              ? const Center(child: Text('No hay tipos de devolución.'))
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: tipos.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final t = tipos[i];
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
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.verde.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  'ID ${t.idTipoDevolucion}',
                                  style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.verde),
                                ),
                              ),
                              Text(
                                t.nombreTipo,
                                style: const TextStyle(fontWeight: FontWeight.w900),
                              ),
                              const SizedBox(width: 6),
                              InkWell(
                                borderRadius: BorderRadius.circular(999),
                                onTap: () => _editar(t.idTipoDevolucion, t.nombreTipo),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(color: Colors.orange.withOpacity(0.10), borderRadius: BorderRadius.circular(999)),
                                  child: const Icon(Icons.edit, size: 18, color: Colors.orange),
                                ),
                              ),
                              InkWell(
                                borderRadius: BorderRadius.circular(999),
                                onTap: () => _eliminar(t.idTipoDevolucion),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(color: Colors.red.withOpacity(0.10), borderRadius: BorderRadius.circular(999)),
                                  child: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
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
    );
  }
}
