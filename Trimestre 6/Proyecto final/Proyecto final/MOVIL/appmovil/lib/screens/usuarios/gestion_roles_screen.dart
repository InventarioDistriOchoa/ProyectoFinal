import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_colors.dart';
import '../../controllers/rol_controller.dart';
import '../../models/rol_model.dart';
import '../../services/rol_service.dart';
import '../../widgets/admin_bottom_nav.dart';

class GestionRolesScreen extends StatefulWidget {
  const GestionRolesScreen({super.key});

  @override
  State<GestionRolesScreen> createState() => _GestionRolesScreenState();
}

class _GestionRolesScreenState extends State<GestionRolesScreen> {
  int _vista = 0; // 0 registro, 1 listado

  final _formKey = GlobalKey<FormState>();
  final _descripcionCtrl = TextEditingController();

  final _searchCtrl = TextEditingController();
  String _query = '';

  // BottomNav (Admin). Aquí roles = index 2
  int _currentIndex = 2;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<RolController>().cargar();
    });
  }

  @override
  void dispose() {
    _descripcionCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  InputDecoration _dec(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    );
  }

  // iconos como en JSX (si tienes esos assets)
  String _iconoRol(String desc) {
    final d = desc.toLowerCase().trim();
    if (d == 'admin') return 'assets/img/icon-admin.png';
    if (d == 'superadmin') return 'assets/img/icon-superadmin.png';
    if (d == 'auxiliar') return 'assets/img/icon-usuario.png';
    return 'assets/img/icon-default.png';
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
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: danger ? Colors.red : AppColors.verde,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _registrar() async {
    if (!_formKey.currentState!.validate()) return;

    final descripcion = _descripcionCtrl.text.trim();
    if (descripcion.length < 3) {
      _snack('La descripción debe tener al menos 3 caracteres');
      return;
    }

    final ctrl = context.read<RolController>();

    try {
      await ctrl.crear(descripcion);
      _snack('Rol creado ✅');
      _descripcionCtrl.clear();
      await ctrl.cargar();
      setState(() => _vista = 1);
    } on RolConflictException catch (e) {
      if (e.desactivado && e.idRol != null) {
        final ok = await _confirm(
          title: 'Rol ya existe',
          message: '${e.message}\n\nEstá desactivado. ¿Deseas reactivarlo?',
          confirmText: 'Reactivar',
        );
        if (ok == true) {
          await ctrl.activar(e.idRol!);
          _snack('Rol reactivado ✅');
          _descripcionCtrl.clear();
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

  Future<void> _eliminar(RolModel r) async {
    final ok = await _confirm(
      title: '¿Eliminar este rol?',
      message: '¿Seguro que deseas desactivar el rol "${r.descripcionRol}"?',
      confirmText: 'Sí, eliminar',
      danger: true,
    );
    if (ok != true) return;

    try {
      await context.read<RolController>().eliminar(r.idRol);
      _snack('Rol desactivado ✅');
      await context.read<RolController>().cargar();
    } catch (e) {
      _snack(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _editar(RolModel r) async {
    final editCtrl = TextEditingController(text: r.descripcionRol);

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Editar Rol', style: TextStyle(fontWeight: FontWeight.w900)),
        content: TextField(
          controller: editCtrl,
          decoration: _dec('Descripción del Rol'),
        ),
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
      editCtrl.dispose();
      return;
    }

    final nuevo = editCtrl.text.trim();
    if (nuevo.length < 3) {
      _snack('La descripción debe tener al menos 3 caracteres');
      editCtrl.dispose();
      return;
    }

    try {
      await context.read<RolController>().editar(r.idRol, nuevo);
      _snack('Rol actualizado ✅');
      await context.read<RolController>().cargar();
    } catch (e) {
      _snack(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      editCtrl.dispose();
    }
  }

  // ✅ Navegación BottomNav
  void _onBottomNavTap(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);

    // Ajusta rutas a las tuyas reales:
    if (index == 0) Navigator.pushReplacementNamed(context, '/dashboard');
    if (index == 1) Navigator.pushReplacementNamed(context, '/usuarios'); // home admin usuarios
    if (index == 2) Navigator.pushReplacementNamed(context, '/roles');    // aquí mismo
    if (index == 3) Navigator.pushReplacementNamed(context, '/proveedores');
    if (index == 4) Navigator.pushReplacementNamed(context, '/tipo-documento');
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<RolController>();

    final q = _query.trim().toLowerCase();
    final roles = q.isEmpty
        ? ctrl.roles
        : ctrl.roles.where((r) {
            final s = '${r.idRol} ${r.descripcionRol}'.toLowerCase();
            return s.contains(q);
          }).toList();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'Gestión de Roles',
          style: TextStyle(color: AppColors.negroSuave, fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: AppColors.negroSuave),
        elevation: 0.6,
      ),
      body: SafeArea(
        child: ctrl.loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  const SizedBox(height: 10),
                  _tabs(),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ctrl.error.isNotEmpty
                        ? Center(child: Text(ctrl.error))
                        : _vista == 0
                            ? _registro()
                            : _listado(roles),
                  ),
                ],
              ),
      ),

      // ✅ BOTONES ABAJO (NAV)
      bottomNavigationBar: AdminBottomNav(
        currentIndex: _currentIndex,
        onTap: _onBottomNavTap,
      ),
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
      child: Text(t, style: const TextStyle(fontWeight: FontWeight.w900)),
    );
  }

  Widget _registro() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Registro de Rol',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.verde),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descripcionCtrl,
                    decoration: _dec('Descripción del Rol'),
                    validator: (v) {
                      final s = (v ?? '').trim();
                      if (s.isEmpty) return 'Campo obligatorio';
                      if (s.length < 3) return 'Mínimo 3 caracteres';
                      return null;
                    },
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
                      child: const Text('Registrar', style: TextStyle(fontWeight: FontWeight.w900)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _listado(List<RolModel> roles) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
      child: Column(
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Buscar rol (id, descripción)',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: roles.isEmpty
                ? const Center(child: Text('No hay roles registrados.'))
                : ListView.separated(
                    itemCount: roles.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final r = roles[i];
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3)),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 54,
                              height: 54,
                              decoration: BoxDecoration(
                                color: AppColors.verde.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Image.asset(
                                  _iconoRol(r.descripcionRol),
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) =>
                                      const Icon(Icons.admin_panel_settings, color: AppColors.verde),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    r.descripcionRol,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontWeight: FontWeight.w900),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'ID: ${r.idRol}',
                                    style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              tooltip: 'Editar',
                              icon: const Icon(Icons.edit, color: Colors.orange),
                              onPressed: () => _editar(r),
                            ),
                            IconButton(
                              tooltip: 'Eliminar',
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () => _eliminar(r),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
