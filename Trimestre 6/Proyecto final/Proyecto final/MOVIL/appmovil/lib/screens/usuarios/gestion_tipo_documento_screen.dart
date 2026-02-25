import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_colors.dart';
import '../../controllers/tipo_documento_controller.dart';
import '../../models/tipo_documento_model.dart';
import '../../services/tipo_documento_service.dart';
import '../../widgets/admin_bottom_nav.dart';

class GestionTipoDocumentoScreen extends StatefulWidget {
  const GestionTipoDocumentoScreen({super.key});

  @override
  State<GestionTipoDocumentoScreen> createState() => _GestionTipoDocumentoScreenState();
}

class _GestionTipoDocumentoScreenState extends State<GestionTipoDocumentoScreen> {
  int _vista = 0; // 0 registro, 1 listado
  int _currentIndex = 4; // en nuestro nav "Docs"

  final _formKey = GlobalKey<FormState>();
  final _descripcionCtrl = TextEditingController();

  String _iconoTipo(String descripcion) {
    final d = descripcion.toLowerCase().trim();
    if (d == 'cedula de ciudadania') return 'assets/img/icon-cedula.jpg';
    if (d == 'tarjeta de identidad') return 'assets/img/icon-tarjeta.png';
    if (d == 'cedula extranjera') return 'assets/img/icon-cedula-ext.png';
    if (d == 'pasaporte') return 'assets/img/icon-pasaporte.png';
    return 'assets/img/icon-default2.png';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<TipoDocumentoController>().cargar();
    });
  }

  @override
  void dispose() {
    _descripcionCtrl.dispose();
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

    final descripcion = _descripcionCtrl.text.trim();
    final ctrl = context.read<TipoDocumentoController>();

    try {
      await ctrl.crear(descripcion);
      _snack('Tipo de documento creado ✅');
      _descripcionCtrl.clear();
      await ctrl.cargar();
      setState(() => _vista = 1);
    } on TipoDocumentoConflictException catch (e) {
      if (e.desactivado && e.idTipoDocumento != null) {
        final ok = await _confirm(
          title: 'Ya existe',
          message: '${e.message}\n\nEstá desactivado. ¿Deseas reactivarlo?',
          confirmText: 'Reactivar',
        );
        if (ok == true) {
          await ctrl.activar(e.idTipoDocumento!);
          _snack('Reactivado ✅');
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

  Future<void> _eliminar(TipoDocumentoModel t) async {
    final ok = await _confirm(
      title: '¿Eliminar?',
      message: '¿Seguro que deseas eliminar (desactivar) "${t.descripcion}"?',
      confirmText: 'Sí, eliminar',
      danger: true,
    );
    if (ok != true) return;

    try {
      await context.read<TipoDocumentoController>().eliminar(t.idTipoDocumento);
      _snack('Eliminado ✅');
      await context.read<TipoDocumentoController>().cargar();
    } catch (e) {
      _snack(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _editar(TipoDocumentoModel t) async {
    final editCtrl = TextEditingController(text: t.descripcion);

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Editar Tipo de Documento', style: TextStyle(fontWeight: FontWeight.w900)),
        content: TextField(
          controller: editCtrl,
          decoration: _dec('Descripción'),
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

    final nueva = editCtrl.text.trim();
    if (nueva.length < 3) {
      _snack('La descripción debe tener al menos 3 caracteres');
      editCtrl.dispose();
      return;
    }

    try {
      await context.read<TipoDocumentoController>().editar(t.idTipoDocumento, nueva);
      _snack('Actualizado ✅');
      await context.read<TipoDocumentoController>().cargar();
    } catch (e) {
      _snack(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      editCtrl.dispose();
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
    final ctrl = context.watch<TipoDocumentoController>();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'Tipos de Documento',
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
                      Expanded(child: _vista == 0 ? _registro() : _listado(ctrl.tipos)),
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
                    'Registro de Tipo de Documento',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.verde),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descripcionCtrl,
                    decoration: _dec('Descripción'),
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

  Widget _listado(List<TipoDocumentoModel> tipos) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: tipos.length,
      itemBuilder: (_, i) {
        final t = tipos[i];
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
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Image.asset(
                    _iconoTipo(t.descripcion),
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.badge_outlined, color: AppColors.verde),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.descripcion,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: ${t.idTipoDocumento}',
                      style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Editar',
                icon: const Icon(Icons.edit, color: Colors.orange),
                onPressed: () => _editar(t),
              ),
              IconButton(
                tooltip: 'Eliminar',
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => _eliminar(t),
              ),
            ],
          ),
        );
      },
    );
  }
}
