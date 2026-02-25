import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_colors.dart';
import '../../models/categoria_model.dart';
import '../../controllers/categoria_controller.dart';
import '../../services/categoria_service.dart';

class CategoriasScreen extends StatefulWidget {
  const CategoriasScreen({super.key});

  @override
  State<CategoriasScreen> createState() => _CategoriasScreenState();
}

class _CategoriasScreenState extends State<CategoriasScreen> {
  int _vista = 0; // 0 registro, 1 listado

  // Registro
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  // Filtros
  final _filtroNombreCtrl = TextEditingController();
  final _filtroIdCtrl = TextEditingController();

  // Carrusel
  final ScrollController _carruselCtrl = ScrollController();

  // Bottom nav (0 inicio, 1 categorias actual)
  int _currentIndex = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<CategoriaController>().cargar();
    });
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _descCtrl.dispose();
    _filtroNombreCtrl.dispose();
    _filtroIdCtrl.dispose();
    _carruselCtrl.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);

    if (index == 0) Navigator.pushReplacementNamed(context, '/dashboard');
    if (index == 1) {} // actual
  }

  // ✅ ICONO POR NOMBRE (assets como tu web)
  String _iconoCategoriaAsset(String nombre) {
    final n = (nombre).toLowerCase();

    // Cambia estos nombres a los tuyos reales (según cómo los tengas guardados)
    if (n.contains('frutas')) return 'assets/img/frutas.png';
    if (n.contains('verduras')) return 'assets/img/verduras.png';
    if (n.contains('hierbas')) return 'assets/img/hierbas.png';
    if (n.contains('legumbres')) return 'assets/img/legumbres.png';

    // si no coincide -> default
    return 'assets/img/default.png';
  }

  Future<void> _registrar() async {
    if (!_formKey.currentState!.validate()) return;

    final nombre = _nombreCtrl.text.trim();
    final desc = _descCtrl.text.trim();

    if (nombre.length < 3) {
      _snack('El nombre debe tener al menos 3 caracteres');
      return;
    }

    final c = context.read<CategoriaController>();

    try {
      await c.crear(
        CategoriaModel(
          idCategoria: 0,
          nombreCategoria: nombre,
          descripcion: desc,
        ),
      );

      _snack('Categoría registrada ✅');
      _nombreCtrl.clear();
      _descCtrl.clear();

      await c.cargar();
      setState(() => _vista = 1);
    } on CategoriaConflictException catch (e) {
      if (e.desactivado && e.idCategoria != null) {
        final ok = await _confirm(
          title: 'La categoría ya existe',
          message: '${e.message}\n\nEstá desactivada. ¿Deseas reactivarla?',
          confirmText: 'Reactivar',
        );
        if (ok == true) {
          await c.activar(e.idCategoria!);
          _snack('Categoría reactivada ✅');
          _nombreCtrl.clear();
          _descCtrl.clear();
          await c.cargar();
          setState(() => _vista = 1);
        }
      } else {
        _snack(e.message);
      }
    } catch (e) {
      _snack(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _eliminar(CategoriaModel cat) async {
    final ok = await _confirm(
      title: '¿Eliminar categoría?',
      message:
          'La categoría "${cat.nombreCategoria}" podría tener productos relacionados.\n\n'
          'Si continúas, esos productos quedarán con la categoría "No seleccionada".',
      confirmText: 'Sí, eliminar',
      danger: true,
    );

    if (ok != true) return;

    final c = context.read<CategoriaController>();
    try {
      await c.eliminar(cat.idCategoria);
      _snack('Categoría eliminada ✅');
      await c.cargar();
    } catch (e) {
      _snack(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _editar(CategoriaModel cat) async {
    final nombreEdit = TextEditingController(text: cat.nombreCategoria);
    final descEdit = TextEditingController(text: cat.descripcion ?? '');

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Text(
            'Editar Categoría',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreEdit,
                decoration: _dec('Nombre Categoría'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descEdit,
                decoration: _dec('Descripción'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.verde,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Guardar', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ],
        );
      },
    );

    if (ok != true) {
      nombreEdit.dispose();
      descEdit.dispose();
      return;
    }

    final c = context.read<CategoriaController>();
    try {
      await c.editar(
        cat.idCategoria,
        CategoriaModel(
          idCategoria: cat.idCategoria,
          nombreCategoria: nombreEdit.text.trim(),
          descripcion: descEdit.text.trim(),
        ),
      );

      _snack('Categoría actualizada ✅');
      await c.cargar();
    } catch (e) {
      _snack(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      nombreEdit.dispose();
      descEdit.dispose();
    }
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
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
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

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<CategoriaController>();

    final filtroNombre = _filtroNombreCtrl.text.trim().toLowerCase();
    final filtroId = _filtroIdCtrl.text.trim();

    final filtradas = ctrl.categorias.where((c) {
      final okNombre = filtroNombre.isEmpty ||
          c.nombreCategoria.toLowerCase().contains(filtroNombre);
      final okId = filtroId.isEmpty || c.idCategoria.toString() == filtroId;
      return okNombre && okId;
    }).toList();

    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(
              'assets/img/banner-distriochoa.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(color: Colors.black.withOpacity(0.25)),
            ),
          ),

          Positioned.fill(
            top: 80,
            bottom: 70,
            child: ctrl.loading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      const SizedBox(height: 10),
                      _tabs(),
                      const SizedBox(height: 12),
                      Expanded(
                        child: _vista == 0 ? _registro() : _listado(filtradas),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          '© 2025 DistriOchoa. Todos los derechos reservados.',
                          style: TextStyle(color: Colors.grey.shade200, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 70,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.92),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pushReplacementNamed(context, '/dashboard'),
                  ),
                  Image.asset('assets/img/logo.png', width: 40, height: 40),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Gestión de Categorías',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppColors.verde,
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _bottomNav(),
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
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.92),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.20),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Text(
                    'Registro de Categoría',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.verde),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _nombreCtrl,
                    decoration: _dec('Nombre Categoría'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Campo obligatorio' : null,
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _descCtrl,
                    decoration: _dec('Descripción'),
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

  Widget _listado(List<CategoriaModel> cats) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _filtroNombreCtrl,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Buscar por nombre de categoría...',
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
                  controller: _filtroIdCtrl,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Buscar por ID...',
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
          const SizedBox(height: 14),

          Expanded(
            child: cats.isEmpty
                ? const Center(child: Text('No hay categorías que coincidan.'))
                : Stack(
                    children: [
                      ListView.separated(
                        controller: _carruselCtrl,
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 46, vertical: 10),
                        itemCount: cats.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (_, i) => _cardCategoria(cats[i]),
                      ),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          icon: const Icon(Icons.chevron_left, size: 34, color: Colors.white),
                          onPressed: () {
                            _carruselCtrl.animateTo(
                              (_carruselCtrl.offset - 300)
                                  .clamp(0, _carruselCtrl.position.maxScrollExtent),
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOut,
                            );
                          },
                        ),
                      ),

                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          icon: const Icon(Icons.chevron_right, size: 34, color: Colors.white),
                          onPressed: () {
                            _carruselCtrl.animateTo(
                              (_carruselCtrl.offset + 300)
                                  .clamp(0, _carruselCtrl.position.maxScrollExtent),
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOut,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _cardCategoria(CategoriaModel cat) {
    final asset = _iconoCategoriaAsset(cat.nombreCategoria);

    return Container(
      width: 220,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ✅ IMAGEN REAL POR CATEGORÍA (assets)
          Container(
            width: 84,
            height: 84,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.verde.withOpacity(0.10),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Image.asset(
              asset,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Image.asset(
                'assets/img/default.png',
                fit: BoxFit.contain,
              ),
            ),
          ),

          const SizedBox(height: 10),

          // ✅ Badge ID (moderno)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.06),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '#${cat.idCategoria}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            cat.nombreCategoria,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w900),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 8),

          Expanded(
            child: SingleChildScrollView(
              child: Text(
                (cat.descripcion == null || cat.descripcion!.trim().isEmpty)
                    ? 'Sin descripción'
                    : cat.descripcion!,
                textAlign: TextAlign.justify,
                style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
              ),
            ),
          ),

          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ✅ Botón redondo editar
              InkWell(
                onTap: () => _editar(cat),
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.10),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit, color: Colors.blue),
                ),
              ),
              const SizedBox(width: 12),

              // ✅ Botón redondo eliminar
              InkWell(
                onTap: () => _eliminar(cat),
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.10),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.delete_outline, color: Colors.red),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bottomNav() { 
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 255, 255),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, -3)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _navItem(index: 0, icon: Icons.home_outlined, label: 'Inicio'),
          _navItem(index: 1, icon: Icons.category_outlined, label: 'Categorías'),
        ],
      ),
    );
  }

  Widget _navItem({required int index, required IconData icon, required String label}) {
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
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
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
