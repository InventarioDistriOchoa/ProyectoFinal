import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_colors.dart';
import '../../controllers/proveedor_controller.dart';
import '../../models/proveedor_model.dart';
import '../../services/proveedor_service.dart';
import '../../widgets/admin_bottom_nav.dart';

class GestionProveedoresScreen extends StatefulWidget {
  const GestionProveedoresScreen({super.key});

  @override
  State<GestionProveedoresScreen> createState() => _GestionProveedoresScreenState();
}

class _GestionProveedoresScreenState extends State<GestionProveedoresScreen> {
  int _vista = 0; // 0 registro, 1 listado
  int _currentIndex = 3; // en tu AdminBottomNav: 0 dash, 1 usuarios, 2 roles, 3 proveedores, 4 docs

  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _direccionCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<ProveedorController>().cargar();
    });
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _direccionCtrl.dispose();
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

    final nombre = _nombreCtrl.text.trim();
    final direccion = _direccionCtrl.text.trim();
    final ctrl = context.read<ProveedorController>();

    try {
      await ctrl.crear(nombre, direccion);
      _snack('Proveedor registrado ✅');
      _nombreCtrl.clear();
      _direccionCtrl.clear();
      await ctrl.cargar();
      setState(() => _vista = 1);
    } on ProveedorConflictException catch (e) {
      if (e.desactivado && e.idProveedor != null) {
        final ok = await _confirm(
          title: 'Proveedor desactivado',
          message: '${e.message}\n\nEstá desactivado. ¿Deseas reactivarlo?',
          confirmText: 'Reactivar',
        );
        if (ok == true) {
          await ctrl.activar(e.idProveedor!);
          _snack('Reactivado ✅');
          _nombreCtrl.clear();
          _direccionCtrl.clear();
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

  Future<void> _eliminar(ProveedorModel p) async {
    final ok = await _confirm(
      title: '¿Desactivar proveedor?',
      message: '¿Seguro que deseas desactivar "${p.nombreEmpresa}"?\n\nPodrás reactivarlo más tarde.',
      confirmText: 'Sí, desactivar',
      danger: true,
    );
    if (ok != true) return;

    try {
      await context.read<ProveedorController>().eliminar(p.idProveedor);
      _snack('Proveedor desactivado ✅');
      await context.read<ProveedorController>().cargar();
    } catch (e) {
      _snack(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _editar(ProveedorModel p) async {
    final nombreCtrl = TextEditingController(text: p.nombreEmpresa);
    final direccionCtrl = TextEditingController(text: p.direccion);

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Editar Proveedor', style: TextStyle(fontWeight: FontWeight.w900)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nombreCtrl, decoration: _dec('Nombre Empresa')),
            const SizedBox(height: 10),
            TextField(controller: direccionCtrl, decoration: _dec('Dirección')),
          ],
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
      nombreCtrl.dispose();
      direccionCtrl.dispose();
      return;
    }

    final nNombre = nombreCtrl.text.trim();
    final nDir = direccionCtrl.text.trim();

    if (nNombre.length < 3) {
      _snack('El nombre debe tener al menos 3 caracteres');
      nombreCtrl.dispose();
      direccionCtrl.dispose();
      return;
    }

    try {
      await context.read<ProveedorController>().editar(p.idProveedor, nNombre, nDir);
      _snack('Actualizado ✅');
      await context.read<ProveedorController>().cargar();
    } catch (e) {
      _snack(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      nombreCtrl.dispose();
      direccionCtrl.dispose();
    }
  }

  void _onBottomNavTap(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);

    if (index == 0) Navigator.pushReplacementNamed(context, '/dashboard');
    if (index == 1) Navigator.pushReplacementNamed(context, '/usuarios');
    if (index == 2) Navigator.pushReplacementNamed(context, '/gestion-roles');
    if (index == 3) Navigator.pushReplacementNamed(context, '/proveedores');
    if (index == 4) Navigator.pushReplacementNamed(context, '/tipo-documento');
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<ProveedorController>();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'Proveedores',
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
            : ctrl.error.isNotEmpty
                ? Center(child: Text(ctrl.error))
                : Column(
                    children: [
                      const SizedBox(height: 10),
                      _tabs(),
                      const SizedBox(height: 10),
                      Expanded(
                        child: _vista == 0 ? _registro() : _listado(ctrl.proveedores),
                      ),
                    ],
                  ),
      ),
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
                    'Registro de Proveedor',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.verde),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nombreCtrl,
                    decoration: _dec('Nombre Empresa'),
                    validator: (v) {
                      final s = (v ?? '').trim();
                      if (s.isEmpty) return 'Campo obligatorio';
                      if (s.length < 3) return 'Mínimo 3 caracteres';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _direccionCtrl,
                    decoration: _dec('Dirección'),
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

  Widget _listado(List<ProveedorModel> proveedores) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: proveedores.length,
      itemBuilder: (_, i) {
        final p = proveedores[i];

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
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
                child: const Icon(Icons.storefront_outlined, color: AppColors.verde),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.nombreEmpresa,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      p.direccion.isEmpty ? 'Sin dirección' : p.direccion,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'ID: ${p.idProveedor}',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Editar',
                icon: const Icon(Icons.edit, color: Colors.orange),
                onPressed: () => _editar(p),
              ),
              IconButton(
                tooltip: 'Desactivar',
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => _eliminar(p),
              ),
            ],
          ),
        );
      },
    );
  }
}
