import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppBottomNav extends StatefulWidget {
  final int currentIndex;
  final void Function(int) onTap;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<AppBottomNav> createState() => _AppBottomNavState();
}

class _AppBottomNavState extends State<AppBottomNav> {
  String rol = '';

  @override
  void initState() {
    super.initState();
    _loadRol();
  }

  Future<void> _loadRol() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => rol = (prefs.getString('rol') ?? '').toLowerCase());
  }

  bool get esAdmin => rol == 'admin' || rol == 'superadmin';

  @override
  Widget build(BuildContext context) {
    // Índices FIJOS para no romper rutas:
    // 0 dashboard, 1 stock, 2 entradas, 3 ventas, 4 devoluciones, 5 reportes, 6 admin (solo admin)
    final items = <BottomNavigationBarItem>[
      const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
      const BottomNavigationBarItem(icon: Icon(Icons.inventory_2), label: 'Stock'),
      const BottomNavigationBarItem(icon: Icon(Icons.input), label: 'Entradas'),
      const BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Ventas'),
      const BottomNavigationBarItem(icon: Icon(Icons.undo), label: 'Devoluc.'),
      const BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Reportes'),
      if (esAdmin) const BottomNavigationBarItem(icon: Icon(Icons.admin_panel_settings), label: 'Admin'),
    ];

    // si NO es admin, y el currentIndex viene en 6, lo bajamos para evitar crash
    final safeIndex = (widget.currentIndex >= items.length) ? 0 : widget.currentIndex;

    return BottomNavigationBar(
      currentIndex: safeIndex,
      onTap: widget.onTap,
      type: BottomNavigationBarType.fixed,
      items: items,
    );
  }
}
