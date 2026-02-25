// lib/screens/dashboard_screen.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_colors.dart';
import '../config/env_config.dart';
import 'package:provider/provider.dart';
import '../controllers/ventas_controller.dart';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String nombre = '';
  String rol = '';
  String? fotoUrl; // URL completa de la foto del usuario
  bool sidebarVisible = false;
  bool _loadingProfile = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final storedNombre = prefs.getString('nombre');
    final storedRol = prefs.getString('rol');

    if (token == null || storedNombre == null || storedRol == null) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/select-role');
      return;
    }

    setState(() {
      nombre = storedNombre;
      rol = storedRol.toLowerCase();
    });

    await _loadProfile(token);
  }

  Future<void> _loadProfile(String token) async {
    try {
      setState(() => _loadingProfile = true);

      // Igual que en React: GET /api/persona/me
      final uri = Uri.parse('${EnvConfig.baseUrl}/persona/me');
      final res = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final body = data['body'] ?? {};
        final foto = body['Foto'];
        if (foto != null && foto.toString().isNotEmpty) {
          setState(() {
            // En React: http://localhost:3001${foto}
            fotoUrl = '${EnvConfig.mediaBaseUrl}$foto';
          });
        }
      }
    } catch (e) {
      debugPrint('Error cargando perfil: $e');
    } finally {
      if (mounted) {
        setState(() => _loadingProfile = false);
      }
    }
  }

Future<void> _cerrarSesion() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  try {
    if (token != null) {
      final uri = Uri.parse('${EnvConfig.baseUrl}/persona/logout');
      await http.post(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );
    }
  } catch (e) {
    debugPrint('Error cerrando sesión en backend: $e');
  } finally {
    // ✅ 1) VACÍA CARRITO / ESTADO DE VENTAS (Provider)
    if (mounted) {
      context.read<VentasController>().reset(); // <-- este método lo agregamos
    }

    // ✅ 2) Limpia sesión local
    await prefs.clear();

    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sesión cerrada ✅'),
        content: const Text('Has cerrado sesión correctamente.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/select-role');
  }
}


  bool get _mostrarModuloUsuarios =>
      rol == 'admin' || rol == 'superadmin';

  @override
  Widget build(BuildContext context) {
   print('🔥 DASHBOARD NUEVO OK 123 🔥');
    return Scaffold(
      body: Stack(
        children: [
          // 1) Fondo global
          Container(color: Colors.grey.shade100),

          // 2) CONTENIDO PRINCIPAL (tarjetas + footer)
          Positioned.fill(
            top: 80,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: Wrap(
                        spacing: 20,
                        runSpacing: 20,
                        alignment: WrapAlignment.center,
                        children: [
                          _dashboardCard(
                            imagePath: 'assets/img/icon-productos.png',
                            text: 'Registrar productos',
                            onTap: () {
                              Navigator.pushNamed(
                                  context, '/registro-productos');
                            },
                          ),
                          _dashboardCard(
                            imagePath: 'assets/img/lista-productos.png',
                            text: 'Ver lista de productos',
                            onTap: () {
                              Navigator.pushNamed(
                                  context, '/lista-productos');
                            },
                          ),
                          _dashboardCard(
                            imagePath: 'assets/img/icon-entradas.png',
                            text: 'Registrar Entradas',
                            onTap: () {
                              Navigator.pushNamed(
                                  context, '/registro-entradas');
                            },
                          ),
                          _dashboardCard(
                            imagePath: 'assets/img/lista-entradas.png',
                            text: 'Ver Entradas',
                            onTap: () {
                              Navigator.pushNamed(
                                  context, '/lista-entradas');
                            },
                          ),
                          _dashboardCard(
                            imagePath: 'assets/img/icon-stock.png',
                            text: 'Stock',
                            onTap: () {
                              Navigator.pushNamed(context, '/stock');
                            },
                          ),
                          if (_mostrarModuloUsuarios)
                            _dashboardCard(
                              imagePath: 'assets/img/icon-usuarios.png',
                              text: 'Registrar Usuarios',
                              onTap: () {
                                Navigator.pushNamed(context, '/home-usuarios');
                              },
                            ),
                          _dashboardCard(
                            imagePath: 'assets/img/icon-reportes.png',
                            text: 'Reportes',
                            onTap: () {
                              Navigator.pushNamed(context, '/reportes');
                            },
                          ),
                          _dashboardCard(
                            imagePath: 'assets/img/icon-salidas.png',
                            text: 'Registrar Salidas',
                            onTap: () {
                              Navigator.pushNamed(context, '/ventas');
                            },
                          ),
                      _dashboardCard(
                            imagePath: 'assets/img/icon-devoluciones.png',
                            text: 'Registrar Devoluciones',
                            onTap: () {
                              Navigator.pushNamed(context, '/devoluciones');
                            },

                          ),
                          _dashboardCard(
                            imagePath: 'assets/img/icono-categorias.png',
                            text: 'Categorías',
                            onTap: () {
                              Navigator.pushNamed(context, '/categorias');
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Footer
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    '© 2025 DistriOchoa. Todos los derechos reservados.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3) OVERLAY OSCURO POR ENCIMA DEL CONTENIDO (pero debajo del header)
          if (sidebarVisible)
            Positioned.fill(
              top: 70, // para que no tape el header
              child: GestureDetector(
                onTap: () => setState(() => sidebarVisible = false),
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                ),
              ),
            ),

          // 4) HEADER SUPERIOR
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 70,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
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
                  // Botón hamburguesa
                  IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () {
                      setState(() => sidebarVisible = !sidebarVisible);
                    },
                  ),

                  // Logo izquierda
                  Image.asset(
                    'assets/img/logo.png',
                    width: 40,
                    height: 40,
                  ),

                  // Centro: nombre de app + usuario
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
                          nombre.isEmpty ? 'Cargando...' : '$nombre ($rol)',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.grisOscuro,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Derecha: avatar con menú
                  PopupMenuButton<String>(
                    tooltip: 'Mi Perfil',
                    onSelected: (value) {
                      if (value == 'perfil') {
                        Navigator.pushNamed(context, '/my-profile');
                      } else if (value == 'logout') {
                        _cerrarSesion();
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: 'perfil',
                        child: Text('Mi Perfil'),
                      ),
                      PopupMenuDivider(),
                      PopupMenuItem(
                        value: 'logout',
                        child: Text('Cerrar sesión'),
                      ),
                    ],
                    child: _loadingProfile
                        ? const CircleAvatar(
                            radius: 20,
                            backgroundColor: AppColors.verde,
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                          )
                        : CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.white,
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: AppColors.verde,
                              backgroundImage: fotoUrl != null
                                  ? NetworkImage(fotoUrl!)
                                  : const AssetImage(
                                      'assets/img/default-avatar.png',
                                    ) as ImageProvider,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),

          // 5) SIDEBAR FLOANTE (encima de TODO) — MEJORADO
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            left: sidebarVisible ? 0 : -260,
            top: 0,
            bottom: 0,
            child: Container(
              width: 240,
              color: Colors.white,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  child: ListView(
                    padding: const EdgeInsets.only(
                      top: 70, // que arranque un poquito más abajo
                      bottom: 24,
                    ),
                    children: [
                      _sidebarItem(
                        label: 'Inicio',
                        icon: Icons.home_outlined,
                        onTap: () {
                          setState(() => sidebarVisible = false);
                        },
                      ),
                      _sidebarItem(
                        label: 'Productos',
                        icon: Icons.description_outlined,
                        onTap: () {
                          setState(() => sidebarVisible = false);
                          Navigator.pushNamed(context, '/lista-productos');
                        },
                      ),
                      _sidebarItem(
                        label: 'Entradas',
                        icon: Icons.description_outlined,
                        onTap: () {
                          setState(() => sidebarVisible = false);
                          Navigator.pushNamed(context, '/lista-entradas');
                        },
                      ),
                      _sidebarItem(
                        label: 'Ventas',
                        icon: Icons.shopping_cart_outlined,
                        onTap: () {
                          setState(() => sidebarVisible = false);
                          Navigator.pushNamed(context, '/ventas');
                        },
                      ),
                      _sidebarItem(
                        label: 'Devoluciones',
                        icon: Icons.undo,
                        onTap: () {
                          setState(() => sidebarVisible = false);
                          Navigator.pushNamed(context, '/devoluciones');
                        },
                      ),
                      _sidebarItem(
                        label: 'Categorías',
                        icon: Icons.category_outlined,
                        onTap: () {
                          setState(() => sidebarVisible = false);
                          Navigator.pushNamed(context, '/categorias');
                        },
                      ),
                      _sidebarItem(
                        label: 'Stock',
                        icon: Icons.inventory_2_outlined,
                        onTap: () {
                          setState(() => sidebarVisible = false);
                          Navigator.pushNamed(context, '/stock');
                        },
                      ),
                      _sidebarItem(
                        label: 'Reportes',
                        icon: Icons.show_chart_outlined,
                        onTap: () {
                          setState(() => sidebarVisible = false);
                          Navigator.pushNamed(context, '/reportes');
                        },
                      ),
                      if (_mostrarModuloUsuarios)
                        _sidebarItem(
                          label: 'Usuarios',
                          icon: Icons.people_outline,
                          onTap: () {
                            setState(() => sidebarVisible = false);
                            Navigator.pushNamed(context, '/usuarios');
                          },
                        ),
                      _sidebarItem(
                        label: 'Mi Perfil',
                        icon: Icons.person_outline,
                        onTap: () {
                          setState(() => sidebarVisible = false);
                          Navigator.pushNamed(context, '/my-profile');
                        },
                      ),
                      _sidebarItem(
                        label: 'Salir',
                        icon: Icons.logout,
                        onTap: _cerrarSesion,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===== Widgets auxiliares =====

  Widget _sidebarItem({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6), // más espacio entre tarjetas
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14, // más alto
          ),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16),
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
              Icon(icon, color: AppColors.verde, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16, // un poco más grande
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  

  Widget _dashboardCard({
    required String imagePath,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        width: 160,
        height: 160,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              width: 56,
              height: 56,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 8),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
