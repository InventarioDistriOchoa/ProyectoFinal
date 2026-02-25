import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/app_colors.dart';
import '../../config/env_config.dart';

class VentasHomeScreen extends StatefulWidget {
  const VentasHomeScreen({super.key});

  @override
  State<VentasHomeScreen> createState() => _VentasHomeScreenState();
}

class _VentasHomeScreenState extends State<VentasHomeScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  String _nombre = '';
  String _rol = '';
  String? _fotoUrl;
  bool _loadingProfile = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/select-role');
      return;
    }

    setState(() {
      _nombre = prefs.getString('nombre') ?? '';
      _rol = (prefs.getString('rol') ?? '').toLowerCase();
    });

    await _loadProfile(token);
  }

  Future<void> _loadProfile(String token) async {
    try {
      setState(() => _loadingProfile = true);
      final uri = Uri.parse('${EnvConfig.baseUrl}/persona/me');
      final res = await http.get(uri, headers: {'Authorization': 'Bearer $token'});
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final body = data['body'] ?? {};
        final foto = body['Foto'];
        if (foto != null && foto.toString().isNotEmpty) {
          setState(() => _fotoUrl = '${EnvConfig.mediaBaseUrl}$foto');
        }
      }
    } catch (_) {
      // silencio
    } finally {
      if (mounted) setState(() => _loadingProfile = false);
    }
  }

  Future<void> _cerrarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      if (token != null) {
        await http.post(
          Uri.parse('${EnvConfig.baseUrl}/persona/logout'),
          headers: {'Authorization': 'Bearer $token'},
        );
      }
    } catch (_) {
      // ok
    } finally {
      await prefs.clear();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/select-role');
    }
  }

  List<_SideItem> _itemsSidebar() {
    final mostrarUsuarios = _rol == 'admin' || _rol == 'superadmin';
    return [
      _SideItem('Inicio', Icons.home_outlined, () => Navigator.pushReplacementNamed(context, '/dashboard')),
      _SideItem('Productos', Icons.inventory_2_outlined, () => Navigator.pushReplacementNamed(context, '/lista-productos')),
      _SideItem('Entradas', Icons.input_outlined, () => Navigator.pushReplacementNamed(context, '/lista-entradas')),
      _SideItem('Ventas', Icons.point_of_sale_outlined, () => Navigator.pushReplacementNamed(context, '/ventas')),
      _SideItem('Devoluciones', Icons.undo_outlined, () => Navigator.pushReplacementNamed(context, '/devoluciones')),
      _SideItem('Categorías', Icons.category_outlined, () => Navigator.pushReplacementNamed(context, '/categorias')),
      _SideItem('Stock', Icons.all_inbox_outlined, () => Navigator.pushReplacementNamed(context, '/stock')),
      _SideItem('Reportes', Icons.bar_chart_outlined, () => Navigator.pushReplacementNamed(context, '/reportes')),
      if (mostrarUsuarios) _SideItem('Usuarios', Icons.people_alt_outlined, () => Navigator.pushReplacementNamed(context, '/usuarios')),
      _SideItem('Mi Perfil', Icons.person_outline, () => Navigator.pushNamed(context, '/my-profile')),
      _SideItem('Salir', Icons.logout_outlined, _cerrarSesion),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: [
              const SizedBox(height: 8),
              ..._itemsSidebar().map(
                (it) => ListTile(
                  leading: Icon(it.icon, color: AppColors.verde),
                  title: Text(it.label, style: const TextStyle(fontWeight: FontWeight.w800)),
                  onTap: () {
                    Navigator.pop(context);
                    it.onTap();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          // Fondo
          SizedBox.expand(
            child: Image.asset('assets/img/banner-distriochoa.png', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(color: Colors.black.withOpacity(0.28)),
            ),
          ),

          // Top bar glass
          Positioned(
            top: 14,
            left: 14,
            right: 14,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: Colors.white.withOpacity(0.22)),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.menu, color: Colors.white),
                        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                      ),
                      Image.asset('assets/img/logo.png', width: 34, height: 34),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Ventas',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.95),
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      PopupMenuButton<String>(
                        tooltip: 'Mi Perfil',
                        onSelected: (v) {
                          if (v == 'perfil') Navigator.pushNamed(context, '/my-profile');
                          if (v == 'logout') _cerrarSesion();
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: 'perfil', child: Text('Mi Perfil')),
                          PopupMenuDivider(),
                          PopupMenuItem(value: 'logout', child: Text('Cerrar sesión')),
                        ],
                        child: _loadingProfile
                            ? const CircleAvatar(
                                radius: 18,
                                backgroundColor: AppColors.verde,
                                child: SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                ),
                              )
                            : CircleAvatar(
                                radius: 18,
                                backgroundColor: Colors.white,
                                child: CircleAvatar(
                                  radius: 16,
                                  backgroundColor: AppColors.verde,
                                  backgroundImage: _fotoUrl != null
                                      ? NetworkImage(_fotoUrl!)
                                      : const AssetImage('assets/img/default-avatar.png') as ImageProvider,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Contenido
          Positioned.fill(
            top: 92,
            bottom: 18,
            child: Column(
              children: [
                const SizedBox(height: 10),
                const Text(
                  '🛒 Módulo Ventas',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white),
                ),
                const SizedBox(height: 6),
                Text(
                  _nombre.isEmpty ? 'Cargando...' : 'Hola $_nombre (${_rol.isEmpty ? 'rol' : _rol})',
                  style: TextStyle(color: Colors.white.withOpacity(0.85)),
                ),
                const SizedBox(height: 18),

                Expanded(
                  child: Center(
                    child: Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        _cardOpcion(
                          img: 'assets/img/icon-venta.png',
                          text: 'Registrar Venta',
                          subtitle: 'Crear + listado + editar + eliminar',
                          onTap: () => Navigator.pushNamed(context, '/registro-ventas'),
                        ),
                        _cardOpcion(
                          img: 'assets/img/icon-detalle-venta.png',
                          text: 'Detalle de Ventas',
                          subtitle: 'Ver movimientos y detalle',
                          onTap: () => Navigator.pushNamed(context, '/detalle-venta'),
                        ),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    '© 2025 DistriOchoa. Todos los derechos reservados.',
                    style: TextStyle(color: Colors.grey.shade200, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardOpcion({
    required String img,
    required String text,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            width: 250,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.14),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white.withOpacity(0.22)),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.18), blurRadius: 18, offset: const Offset(0, 8)),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(img, width: 78, height: 78),
                const SizedBox(height: 10),
                Text(
                  text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white.withOpacity(0.82), fontWeight: FontWeight.w600, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SideItem {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  _SideItem(this.label, this.icon, this.onTap);
}
