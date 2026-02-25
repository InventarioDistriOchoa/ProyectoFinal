import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_colors.dart';
import '../../controllers/usuario_controller.dart';
import '../../models/usuario_model.dart';
import '../../widgets/admin_bottom_nav.dart';
import '../../config/env_config.dart';

class GestionUsuariosScreen extends StatefulWidget {
  const GestionUsuariosScreen({super.key});

  @override
  State<GestionUsuariosScreen> createState() => _GestionUsuariosScreenState();
}

class _GestionUsuariosScreenState extends State<GestionUsuariosScreen> {
  int _vista = 0; // 0 registro, 1 listado
  int _currentIndex = 1; // 0 dash, 1 usuarios, 2 roles, 3 proveedores, 4 docs

  final _formKey = GlobalKey<FormState>();

  final _nombreCtrl = TextEditingController();
  final _correoCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _docCtrl = TextEditingController();

  bool _showPass = false;

  int? _tipoDocId;
  int? _rolId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<UsuariosController>().cargarTodo();
    });
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _correoCtrl.dispose();
    _passCtrl.dispose();
    _docCtrl.dispose();
    super.dispose();
  }

  void _snack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  InputDecoration _dec(String label, {Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      suffixIcon: suffix,
    );
  }

  bool _emailOk(String v) =>
      RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(v);

  bool _passOk(String v) =>
      RegExp(r'^(?=.*[A-Z])(?=.*\d).{8,}$').hasMatch(v);

  bool _docOk(String v) => RegExp(r'^\d{5,10}$').hasMatch(v);

  // ✅ ARMA LA URL CORRECTA PARA FOTO (quita /api del baseUrl)
  String _buildFotoUrl(String? foto) {
    final raw = (foto ?? '').trim();

    // Si ya viene completa
    if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;

    // Base sin /api
    final base = EnvConfig.baseUrl
        .replaceAll('/api', '')
        .replaceAll(RegExp(r'\/+$'), '');

    // Default
    if (raw.isEmpty) return '$base/uploads/default-avatar.png';

    // Si viene con / al inicio
    if (raw.startsWith('/')) return '$base$raw';

    // Si viene sin /
    return '$base/$raw';
  }

  Future<void> _registrar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_tipoDocId == null || _rolId == null) {
      _snack('Seleccione tipo de documento y rol');
      return;
    }

    final ctrl = context.read<UsuariosController>();

    try {
      await ctrl.crear(
        nombre: _nombreCtrl.text.trim(),
        correo: _correoCtrl.text.trim(),
        contrasena: _passCtrl.text,
        numeroDocumento: _docCtrl.text.trim(),
        tipoDocumentoId: _tipoDocId!,
        rolId: _rolId!,
      );

      _snack('Usuario registrado ✅');
      _nombreCtrl.clear();
      _correoCtrl.clear();
      _passCtrl.clear();
      _docCtrl.clear();

      setState(() {
        _tipoDocId = null;
        _rolId = null;
        _vista = 1;
      });

      await ctrl.recargarUsuarios();
    } catch (e) {
      _snack(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _eliminar(UsuarioModel u) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('¿Eliminar usuario?',
            style: TextStyle(fontWeight: FontWeight.w900)),
        content: Text('¿Seguro que deseas eliminar a "${u.nombre}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sí, eliminar',
                style: TextStyle(
                    fontWeight: FontWeight.w900, color: Colors.red)),
          ),
        ],
      ),
    );

    if (ok != true) return;

    try {
      await context.read<UsuariosController>().eliminar(u.idPersona);
      _snack('Eliminado ✅');
      await context.read<UsuariosController>().recargarUsuarios();
    } catch (e) {
      _snack(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _editar(UsuarioModel u) async {
    final nombreCtrl = TextEditingController(text: u.nombre);
    final correoCtrl = TextEditingController(text: u.correo);
    final docCtrl = TextEditingController(text: u.numeroDocumento);
    final passCtrl = TextEditingController(text: '');
    int tipo = u.tipoDocumentoId;
    int rol = u.rolId;

    final ctrl = context.read<UsuariosController>();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Editar Usuario',
            style: TextStyle(fontWeight: FontWeight.w900)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nombreCtrl, decoration: _dec('Nombre')),
              const SizedBox(height: 10),
              TextField(controller: correoCtrl, decoration: _dec('Correo')),
              const SizedBox(height: 10),
              TextField(controller: docCtrl, decoration: _dec('Número Documento')),
              const SizedBox(height: 10),
              DropdownButtonFormField<int>(
                initialValue: tipo,
                items: ctrl.tiposDoc
                    .map((t) => DropdownMenuItem(
                          value: t.idTipoDocumento,
                          child: Text(t.descripcion),
                        ))
                    .toList(),
                onChanged: (v) => tipo = v ?? tipo,
                decoration: _dec('Tipo Documento'),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<int>(
                initialValue: rol,
                items: ctrl.roles
                    .map((r) => DropdownMenuItem(
                          value: r.idRol,
                          child: Text(r.descripcionRol),
                        ))
                    .toList(),
                onChanged: (v) => rol = v ?? rol,
                decoration: _dec('Rol'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: passCtrl,
                obscureText: true,
                decoration: _dec('Contraseña (opcional)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.verde,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Guardar',
                style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );

    if (ok != true) {
      nombreCtrl.dispose();
      correoCtrl.dispose();
      docCtrl.dispose();
      passCtrl.dispose();
      return;
    }

    if (nombreCtrl.text.trim().length < 3) {
      _snack('El nombre debe tener al menos 3 caracteres');
    } else if (!_emailOk(correoCtrl.text.trim())) {
      _snack('Correo inválido');
    } else if (!_docOk(docCtrl.text.trim())) {
      _snack('Documento entre 5 y 10 dígitos');
    } else if (passCtrl.text.isNotEmpty && !_passOk(passCtrl.text)) {
      _snack('Contraseña mínimo 8 caracteres, 1 mayúscula y 1 número');
    } else {
      try {
        await context.read<UsuariosController>().editar(
              idPersona: u.idPersona,
              nombre: nombreCtrl.text.trim(),
              correo: correoCtrl.text.trim(),
              numeroDocumento: docCtrl.text.trim(),
              tipoDocumentoId: tipo,
              rolId: rol,
              contrasena: passCtrl.text.isEmpty ? null : passCtrl.text,
            );
        _snack('Actualizado ✅');
        await context.read<UsuariosController>().recargarUsuarios();
      } catch (e) {
        _snack(e.toString().replaceFirst('Exception: ', ''));
      }
    }

    nombreCtrl.dispose();
    correoCtrl.dispose();
    docCtrl.dispose();
    passCtrl.dispose();
  }

  void _onBottomNavTap(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);

    if (index == 0) Navigator.pushReplacementNamed(context, '/dashboard');
    if (index == 1) Navigator.pushReplacementNamed(context, '/usuarios');
    if (index == 2) Navigator.pushReplacementNamed(context, '/roles');
    if (index == 3) Navigator.pushReplacementNamed(context, '/proveedores');
    if (index == 4) Navigator.pushReplacementNamed(context, '/tipo-documento');
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<UsuariosController>();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'Usuarios',
          style:
              TextStyle(color: AppColors.negroSuave, fontWeight: FontWeight.w900),
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
                        child: _vista == 0 ? _registro(ctrl) : _listado(ctrl),
                      ),
                    ],
                  ),
      ),
      bottomNavigationBar:
          AdminBottomNav(currentIndex: _currentIndex, onTap: _onBottomNavTap),
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

  Widget _registro(UsuariosController ctrl) {
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
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Registro de Usuario',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: AppColors.verde,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nombreCtrl,
                    decoration: _dec('Nombre'),
                    validator: (v) {
                      final s = (v ?? '').trim();
                      if (s.isEmpty) return 'Campo obligatorio';
                      if (s.length < 3) return 'Mínimo 3 caracteres';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _correoCtrl,
                    decoration: _dec('Correo'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      final s = (v ?? '').trim();
                      if (s.isEmpty) return 'Campo obligatorio';
                      if (!_emailOk(s)) return 'Correo inválido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _passCtrl,
                    obscureText: !_showPass,
                    decoration: _dec(
                      'Contraseña',
                      suffix: IconButton(
                        icon: Icon(
                            _showPass ? Icons.visibility_off : Icons.visibility),
                        onPressed: () =>
                            setState(() => _showPass = !_showPass),
                      ),
                    ),
                    validator: (v) {
                      final s = (v ?? '');
                      if (s.isEmpty) return 'Campo obligatorio';
                      if (!_passOk(s)) {
                        return 'Mín. 8 caracteres, 1 mayúscula y 1 número';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _docCtrl,
                    decoration: _dec('Número de Documento'),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      final s = (v ?? '').trim();
                      if (s.isEmpty) return 'Campo obligatorio';
                      if (!_docOk(s)) return 'Documento entre 5 y 10 dígitos';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    initialValue: _tipoDocId,
                    items: ctrl.tiposDoc
                        .map((t) => DropdownMenuItem(
                              value: t.idTipoDocumento,
                              child: Text(t.descripcion),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _tipoDocId = v),
                    decoration: _dec('Tipo de Documento'),
                    validator: (v) => v == null ? 'Seleccione...' : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    initialValue: _rolId,
                    items: ctrl.roles
                        .map((r) => DropdownMenuItem(
                              value: r.idRol,
                              child: Text(r.descripcionRol),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _rolId = v),
                    decoration: _dec('Rol'),
                    validator: (v) => v == null ? 'Seleccione...' : null,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.verde,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      onPressed: _registrar,
                      child: const Text('Registrar',
                          style: TextStyle(fontWeight: FontWeight.w900)),
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

  Widget _listado(UsuariosController ctrl) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: ctrl.usuarios.length,
      itemBuilder: (_, i) {
        final u = ctrl.usuarios[i];
        final fotoUrl = _buildFotoUrl(u.foto);

        // ✅ Debug opcional (si quieres ver qué URL está armando)
        // print('FOTO RAW: ${u.foto} -> URL: $fotoUrl');

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
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: Image.network(
                  fotoUrl,
                  width: 52,
                  height: 52,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 52,
                    height: 52,
                    color: AppColors.verde.withOpacity(0.12),
                    child: const Icon(Icons.person, color: AppColors.verde),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(u.nombre,
                        style: const TextStyle(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 2),
                    Text(
                      u.correo,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      ctrl.tipoDocLabel(u.tipoDocumentoId),
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    Text(
                      ctrl.rolLabel(u.rolId),
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Editar',
                icon: const Icon(Icons.edit, color: Colors.orange),
                onPressed: () => _editar(u),
              ),
              IconButton(
                tooltip: 'Eliminar',
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => _eliminar(u),
              ),
            ],
          ),
        );
      },
    );
  }
}
