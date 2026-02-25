// lib/screens/productos/registro_producto_screen.dart
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../config/app_colors.dart';
import '../../config/env_config.dart';

class RegistroProductoScreen extends StatefulWidget {
  const RegistroProductoScreen({super.key});

  @override
  State<RegistroProductoScreen> createState() => _RegistroProductoScreenState();
}

class _RegistroProductoScreenState extends State<RegistroProductoScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();
  final TextEditingController _responsableController = TextEditingController();

  String? _categoriaSeleccionada;
  List<dynamic> _categorias = [];
  bool _loadingCategorias = false;
  bool _submitting = false;

  String _usuario = '';
  String _rol = '';
  String? _token;

  // Bottom nav (0: Inicio, 1: Productos (actual), 2: Lista)
  int _currentIndex = 1;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _precioController.dispose();
    _responsableController.dispose();
    super.dispose();
  }

  Future<void> _initData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final nombreUsuario = prefs.getString('nombre') ?? '';
    final rolUsuario = prefs.getString('rol') ?? '';

    if (token == null) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/select-role');
      return;
    }

    setState(() {
      _token = token;
      _usuario = nombreUsuario;
      _rol = rolUsuario.toLowerCase();
      _responsableController.text = nombreUsuario; // responsable auto
    });

    await _cargarCategorias();
  }

  Future<void> _cargarCategorias() async {
    if (_token == null) return;

    try {
      setState(() => _loadingCategorias = true);

      final uri = Uri.parse('${EnvConfig.baseUrl}/categoria/categoria');

      final res = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          _categorias = (data['body'] as List?) ?? [];
        });
      } else {
        await _showAlert(
          title: 'Error',
          message: 'No se pudieron cargar las categorías.',
          success: false,
        );
      }
    } catch (e) {
      debugPrint('Error categorías: $e');
      await _showAlert(
        title: 'Error',
        message: 'Ocurrió un problema al cargar las categorías.',
        success: false,
      );
    } finally {
      if (mounted) {
        setState(() => _loadingCategorias = false);
      }
    }
  }

  Future<void> _registrarProducto() async {
    if (!_formKey.currentState!.validate()) return;
    if (_token == null) return;

    final nombre = _nombreController.text.trim();
    final precioStr = _precioController.text.trim();
    final categoriaId = int.tryParse(_categoriaSeleccionada ?? '');
    final precioNum = double.tryParse(precioStr);

    if (categoriaId == null || precioNum == null) {
      await _showAlert(
        title: 'Error',
        message: 'Datos inválidos, revisa precio y categoría.',
        success: false,
      );
      return;
    }

    final nuevoProducto = {
      'Nombre': nombre,
      'Precio': precioNum,
      'Categoria_id': categoriaId,
      'Cantidad_Actual': 0,
    };

    try {
      setState(() => _submitting = true);

      final uri = Uri.parse('${EnvConfig.baseUrl}/producto/producto');

      final res = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode(nuevoProducto),
      );

      final data = jsonDecode(res.body);

      if (res.statusCode == 200 || res.statusCode == 201) {
        final nombreCategoria = _categorias
                .firstWhere(
                  (cat) => cat['idCategoria'].toString() == categoriaId.toString(),
                  orElse: () => null,
                )?['Nombre_Categoria'] ??
            '';

        await _showAlert(
          title: '¡Producto registrado!',
          message: 'Nombre: $nombre\nCategoría: $nombreCategoria\nPrecio: \$${precioNum.toStringAsFixed(2)}',
          success: true,
        );

        if (mounted) {
          _nombreController.clear();
          _precioController.clear();
          setState(() {
            _categoriaSeleccionada = null;
          });
        }
      } else if (res.statusCode == 409) {
        final desactivado = data['desactivado'] == true;
        final idProducto = data['idProducto'];

        if (desactivado && idProducto != null) {
          final confirmar = await _showConfirm(
            title: 'Producto ya existe',
            message: 'El producto $nombre existe pero está desactivado.\n\n¿Deseas reactivarlo?',
          );

          if (confirmar == true) {
            await _reactivarProducto(idProducto);
          }
        } else {
          await _showAlert(
            title: 'Producto existente',
            message: 'El producto que intentas registrar ya existe y está activo.',
            success: false,
          );
        }
      } else {
        await _showAlert(
          title: 'Error',
          message: data['message'] ?? 'No se pudo registrar el producto.',
          success: false,
        );
      }
    } catch (e) {
      debugPrint('Error registro producto: $e');
      await _showAlert(
        title: 'Error',
        message: 'No se pudo registrar el producto.',
        success: false,
      );
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  Future<void> _reactivarProducto(dynamic idProducto) async {
    if (_token == null) return;

    try {
      final uri = Uri.parse('${EnvConfig.baseUrl}/producto/producto/activar/$idProducto');

      final res = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      final data = jsonDecode(res.body);

      if (res.statusCode == 200) {
        await _showAlert(
          title: '¡Producto reactivado!',
          message: 'El producto ha sido activado nuevamente.',
          success: true,
        );
      } else {
        await _showAlert(
          title: 'Error',
          message: data['message'] ?? 'No se pudo reactivar el producto.',
          success: false,
        );
      }
    } catch (e) {
      debugPrint('Error reactivar producto: $e');
      await _showAlert(
        title: 'Error',
        message: 'Hubo un problema al reactivar el producto.',
        success: false,
      );
    }
  }

  // ==== Helpers de diálogos ====

  Future<void> _showAlert({
    required String title,
    required String message,
    required bool success,
  }) async {
    return showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                success ? Icons.check_circle : Icons.error_rounded,
                color: success ? AppColors.verde : AppColors.rojo,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                'Aceptar',
                style: TextStyle(
                  color: success ? AppColors.verde : AppColors.rojo,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<bool?> _showConfirm({
    required String title,
    required String message,
  }) async {
    return showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text(
                'Sí, reactivar',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  // ==== Bottom nav ====

  void _onNavTap(int index) {
    if (index == _currentIndex) return;

    setState(() => _currentIndex = index);

    if (index == 0) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else if (index == 1) {
      // Pantalla actual (registro) -> no navega
    } else if (index == 2) {
      Navigator.pushReplacementNamed(context, '/lista-productos');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo imagen
          SizedBox.expand(
            child: Image.asset(
              'assets/img/banner-distriochoa.png',
              fit: BoxFit.cover,
            ),
          ),
          // Blur + capa oscura
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                color: Colors.black.withOpacity(0.25),
              ),
            ),
          ),

          // CONTENIDO PRINCIPAL (form + footer) debajo del header
          Positioned.fill(
            top: 80,
            bottom: 70,
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 500),
                        child: _buildFormCard(),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8, left: 8, right: 8),
                  child: Text(
                    '© 2025 DistriOchoa. Todos los derechos reservados.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade200,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // HEADER (sin perfil / sin logout aquí)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  height: 70,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.75),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/dashboard');
                        },
                      ),
                      Image.asset(
                        'assets/img/logo.png',
                        width: 40,
                        height: 40,
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'DistriOchoa',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.negroSuave,
                              ),
                            ),
                            Text(
                              _usuario.isEmpty ? 'Cargando...' : '$_usuario ($_rol)',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.grisOscuro,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      // ✅ Solo logo a la derecha (sin avatar/perfil/logout)
                      Image.asset(
                        'assets/img/logo.png',
                        width: 34,
                        height: 34,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ===== Widgets auxiliares =====

  InputDecoration _roundedDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white.withOpacity(0.97),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(24)),
        borderSide: BorderSide(color: AppColors.verde, width: 1.6),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _bottomNavItem(index: 0, icon: Icons.home_outlined, label: 'Inicio'),
          _bottomNavItem(index: 1, icon: Icons.add_box_outlined, label: 'Productos'),
          _bottomNavItem(index: 2, icon: Icons.view_list_outlined, label: 'Lista'),
        ],
      ),
    );
  }

  Widget _bottomNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final bool selected = _currentIndex == index;

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
              Icon(
                icon,
                size: 22,
                color: selected ? AppColors.verde : AppColors.negroSuave,
              ),
              const SizedBox(height: 2),
              Text(
                label,
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

  Widget _buildFormCard() {
    return Form(
      key: _formKey,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.92),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.30),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Registrar Producto',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),

            // Nombre
            TextFormField(
              controller: _nombreController,
              decoration: _roundedDecoration('Nombre del producto'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Campo obligatorio' : null,
            ),
            const SizedBox(height: 12),

            // Categoría
            _loadingCategorias
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : DropdownButtonFormField<String>(
                    decoration: _roundedDecoration('Categoría'),
                    initialValue: _categoriaSeleccionada,
                    items: _categorias
                        .map(
                          (cat) => DropdownMenuItem<String>(
                            value: cat['idCategoria'].toString(),
                            child: Text(cat['Nombre_Categoria'] ?? ''),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _categoriaSeleccionada = v),
                    validator: (v) => (v == null || v.isEmpty) ? 'Selecciona una categoría' : null,
                  ),
            const SizedBox(height: 12),

            // Precio
            TextFormField(
              controller: _precioController,
              decoration: _roundedDecoration('Precio unitario'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Campo obligatorio' : null,
            ),
            const SizedBox(height: 12),

            // Cantidad actual
            TextFormField(
              decoration: _roundedDecoration('Cantidad actual'),
              readOnly: true,
              initialValue: '0',
            ),
            const SizedBox(height: 12),

            // Responsable
            TextFormField(
              controller: _responsableController,
              decoration: _roundedDecoration('Responsable'),
              readOnly: true,
            ),
            const SizedBox(height: 20),

            _submitting
                ? const CircularProgressIndicator()
                : Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _registrarProducto,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.verde,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'Registrar producto',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pushNamed(context, '/lista-productos'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text('Ver lista de productos'),
                        ),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
