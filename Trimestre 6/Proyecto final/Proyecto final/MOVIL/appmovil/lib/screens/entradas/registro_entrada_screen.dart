import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../config/app_colors.dart';
import '../../config/env_config.dart';

import '../../controllers/entrada_controller.dart';
import '../../models/entrada_model.dart';

class RegistroEntradaScreen extends StatefulWidget {
  const RegistroEntradaScreen({super.key});

  @override
  State<RegistroEntradaScreen> createState() => _RegistroEntradaScreenState();
}

class _RegistroEntradaScreenState extends State<RegistroEntradaScreen> {
  final _formKey = GlobalKey<FormState>();
  final EntradaController _entradaController = EntradaController();

  final TextEditingController _cantidadController = TextEditingController();

  String _fecha = '';
  String? _productoSeleccionado;
  String? _proveedorSeleccionado;

  List<dynamic> _productos = [];
  List<dynamic> _proveedores = [];

  bool _loadingProductos = false;
  bool _loadingProveedores = false;
  bool _submitting = false;

  String _usuario = '';
  String _rol = '';
  String? _token;

  // ✅ ya NO se carga perfil aquí
  int _currentIndex = 1;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  @override
  void dispose() {
    _cantidadController.dispose();
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

    final now = DateTime.now();
    final yyyy = now.year.toString().padLeft(4, '0');
    final mm = now.month.toString().padLeft(2, '0');
    final dd = now.day.toString().padLeft(2, '0');

    setState(() {
      _token = token;
      _usuario = nombreUsuario;
      _rol = rolUsuario.toLowerCase();
      _fecha = '$yyyy-$mm-$dd';
    });

    await Future.wait([
      _cargarProductos(),
      _cargarProveedores(),
    ]);
  }

  Future<void> _cargarProductos() async {
    if (_token == null) return;
    try {
      setState(() => _loadingProductos = true);

      final uri = Uri.parse('${EnvConfig.baseUrl}/producto/producto');
      final res = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $_token'},
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          _productos = (data['body'] as List?) ?? [];
        });
      } else {
        await _showAlert(
          title: 'Error',
          message: 'No se pudieron cargar los productos.',
          success: false,
        );
      }
    } catch (e) {
      debugPrint('Error productos: $e');
      await _showAlert(
        title: 'Error',
        message: 'Ocurrió un problema al cargar los productos.',
        success: false,
      );
    } finally {
      if (mounted) setState(() => _loadingProductos = false);
    }
  }

  Future<void> _cargarProveedores() async {
    if (_token == null) return;
    try {
      setState(() => _loadingProveedores = true);

      final uri = Uri.parse('${EnvConfig.baseUrl}/proveedor/proveedor');
      final res = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $_token'},
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          _proveedores = (data['body'] as List?) ?? [];
        });
      } else {
        await _showAlert(
          title: 'Error',
          message: 'No se pudieron cargar los proveedores.',
          success: false,
        );
      }
    } catch (e) {
      debugPrint('Error proveedores: $e');
      await _showAlert(
        title: 'Error',
        message: 'Ocurrió un problema al cargar los proveedores.',
        success: false,
      );
    } finally {
      if (mounted) setState(() => _loadingProveedores = false);
    }
  }

  // ✅ AQUÍ YA USAS CONTROLLER/MODEL
  Future<void> _registrarEntrada() async {
    if (!_formKey.currentState!.validate()) return;
    if (_token == null) return;

    final cantidadNum = int.tryParse(_cantidadController.text.trim());
    final productoId = int.tryParse(_productoSeleccionado ?? '');
    final proveedorId = int.tryParse(_proveedorSeleccionado ?? '');

    if (cantidadNum == null || productoId == null || proveedorId == null) {
      await _showAlert(
        title: 'Error',
        message: 'Datos inválidos, revisa cantidad, producto y proveedor.',
        success: false,
      );
      return;
    }

    final entrada = EntradaModel(
      idEntrada: 0, // el backend lo asigna
      fecha: _fecha,
      cantidad: cantidadNum,
      productoId: productoId,
      proveedorId: proveedorId,
    );

    try {
      setState(() => _submitting = true);

      await _entradaController.registrarEntrada(entrada);

      if (_entradaController.error == null) {
        final nombreProducto = _productos
                .firstWhere(
                  (p) => p['idProducto'].toString() == productoId.toString(),
                  orElse: () => null,
                )?['Nombre'] ??
            '';
        final nombreProveedor = _proveedores
                .firstWhere(
                  (pr) => pr['idProveedor'].toString() == proveedorId.toString(),
                  orElse: () => null,
                )?['Nombre_Empresa'] ??
            '';

        await _showAlert(
          title: '¡Entrada registrada!',
          message:
              'Fecha: $_fecha\nProducto: $nombreProducto\nCantidad: $cantidadNum\nProveedor: $nombreProveedor\nResponsable: $_usuario',
          success: true,
        );

        if (mounted) {
          setState(() {
            _productoSeleccionado = null;
            _proveedorSeleccionado = null;
          });
          _cantidadController.clear();
        }
      } else {
        await _showAlert(
          title: 'Error',
          message: _entradaController.error ?? 'No se pudo registrar la entrada.',
          success: false,
        );
      }
    } catch (e) {
      debugPrint('Error registro entrada: $e');
      await _showAlert(
        title: 'Error',
        message: 'No se pudo registrar la entrada.',
        success: false,
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

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

  void _onNavTap(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);

    if (index == 0) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else if (index == 1) {
      // estamos aquí
    } else if (index == 2) {
      Navigator.pushReplacementNamed(context, '/lista-entradas');
    }
  }

  @override
  Widget build(BuildContext context) {
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
              child: Container(
                color: Colors.black.withOpacity(0.25),
              ),
            ),
          ),
          Positioned.fill(
            top: 80,
            bottom: 60,
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

          // ✅ HEADER sin perfil/logout, solo logo a la derecha
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 70,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color.fromARGB(94, 255, 255, 255).withOpacity(0.92),
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
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/dashboard');
                    },
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
                  Image.asset(
                    'assets/img/logo.png',
                    width: 34,
                    height: 34,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
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
          _bottomNavItem(index: 1, icon: Icons.login_rounded, label: 'Entradas'),
          _bottomNavItem(index: 2, icon: Icons.list_alt_outlined, label: 'Lista'),
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
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Registrar Entrada',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),

            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Fecha',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
              ),
              readOnly: true,
              controller: TextEditingController(text: _fecha),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _cantidadController,
              decoration: const InputDecoration(
                labelText: 'Cantidad',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
              ),
              keyboardType: const TextInputType.numberWithOptions(signed: false),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Campo obligatorio' : null,
            ),
            const SizedBox(height: 12),

            _loadingProductos
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Producto',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                      ),
                    ),
                    initialValue: _productoSeleccionado,
                    items: _productos
                        .map(
                          (p) => DropdownMenuItem<String>(
                            value: p['idProducto'].toString(),
                            child: Text(p['Nombre'] ?? ''),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _productoSeleccionado = v),
                    validator: (v) => (v == null || v.isEmpty) ? 'Selecciona un producto' : null,
                  ),
            const SizedBox(height: 12),

            _loadingProveedores
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Proveedor',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                      ),
                    ),
                    initialValue: _proveedorSeleccionado,
                    items: _proveedores
                        .map(
                          (pr) => DropdownMenuItem<String>(
                            value: pr['idProveedor'].toString(),
                            child: Text(pr['Nombre_Empresa'] ?? ''),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _proveedorSeleccionado = v),
                    validator: (v) => (v == null || v.isEmpty) ? 'Selecciona un proveedor' : null,
                  ),
            const SizedBox(height: 12),

            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Responsable',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
              ),
              readOnly: true,
              controller: TextEditingController(text: _usuario),
            ),
            const SizedBox(height: 20),

            _submitting
                ? const CircularProgressIndicator()
                : Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _registrarEntrada,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.verde,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'Registrar entrada',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pushNamed(context, '/lista-entradas'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text('Ver lista de entradas'),
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
