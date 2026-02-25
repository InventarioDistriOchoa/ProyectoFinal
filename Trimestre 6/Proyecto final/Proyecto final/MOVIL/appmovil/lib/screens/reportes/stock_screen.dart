import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../config/app_colors.dart';
import '../../../models/stock_model.dart';
import '../../../controllers/stock_controller.dart';

class StockScreen extends StatefulWidget {
  const StockScreen({super.key});

  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _idController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _boot();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _idController.dispose();
    super.dispose();
  }

  Future<void> _boot() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final nombre = prefs.getString('nombre') ?? '';
    final rol = prefs.getString('rol') ?? '';

    if (token == null) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/select-role');
      return;
    }

    final c = context.read<StockController>();
    c.setSessionInfo(nombre: nombre, rol: rol);
    await c.init();
  }

  Color _estadoColor(String estado) {
    if (estado == 'verde') return Colors.green;
    if (estado == 'amarillo') return Colors.amber;
    if (estado == 'rojo') return Colors.red;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StockController>(
      builder: (context, c, _) {
        return Scaffold(
          backgroundColor: Colors.grey.shade100,

          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white.withOpacity(0.95),
            title: const Text(
              '📦 Stock de Productos',
              style: TextStyle(
                color: AppColors.negroSuave,
                fontWeight: FontWeight.w700,
              ),
            ),
            centerTitle: true,
            iconTheme: const IconThemeData(color: AppColors.negroSuave),
            actions: [
              PopupMenuButton<String>(
                tooltip: 'Mi Perfil',
                onSelected: (value) {
                  if (value == 'perfil') {
                    Navigator.pushNamed(context, '/my-profile');
                  } else if (value == 'inicio') {
                    Navigator.pushReplacementNamed(context, '/dashboard');
                  } else if (value == 'logout') {
                    Navigator.pushReplacementNamed(context, '/select-role');
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'perfil', child: Text('Mi Perfil')),
                  PopupMenuItem(value: 'inicio', child: Text('Volver al Inicio')),
                  PopupMenuDivider(),
                  PopupMenuItem(value: 'logout', child: Text('Cerrar sesión')),
                ],
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.verde,
                    backgroundImage: c.fotoUrl != null
                        ? NetworkImage(c.fotoUrl!)
                        : const AssetImage('assets/img/default-avatar.png')
                            as ImageProvider,
                  ),
                ),
              ),
            ],
          ),

          bottomNavigationBar: Container(
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 6,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _navItem(
                  label: 'Inicio',
                  icon: Icons.home_outlined,
                  selected: false,
                  onTap: () => Navigator.pushReplacementNamed(context, '/dashboard'),
                ),
                _navItem(
                  label: 'Stock',
                  icon: Icons.inventory_2_outlined,
                  selected: true,
                  onTap: () {},
                ),
                _navItem(
                  label: 'Reportes',
                  icon: Icons.bar_chart_outlined,
                  selected: false,
                  onTap: () => Navigator.pushReplacementNamed(context, '/reportes'),
                ),
              ],
            ),
          ),

          body: SafeArea(
            child: Column(
              children: [
                // Header tipo “Hola nombre / rol”
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Container(
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
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.verde.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.person, color: AppColors.verde),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '👋 Hola ${c.nombre}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.negroSuave,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Rol: ${c.rol}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.grisOscuro,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: c.cargarStock,
                          icon: const Icon(Icons.refresh),
                        )
                      ],
                    ),
                  ),
                ),

                // Buscadores (nombre + id)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: _nombreController,
                          onChanged: c.setSearchNombre,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.search),
                            hintText: 'Buscar por nombre',
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
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
                          controller: _idController,
                          keyboardType: TextInputType.number,
                          onChanged: c.setSearchId,
                          decoration: InputDecoration(
                            hintText: 'Buscar por ID',
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: c.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : (c.paginatedStock.isEmpty)
                          ? const Center(
                              child: Text(
                                'No hay productos en stock',
                                style: TextStyle(color: AppColors.grisOscuro),
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: c.cargarStock,
                              child: ListView.builder(
                                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                                itemCount: c.paginatedStock.length,
                                itemBuilder: (context, i) {
                                  final item = c.paginatedStock[i];
                                  return _stockCard(item, _estadoColor(item.estado));
                                },
                              ),
                            ),
                ),

                // Paginación
                if (!c.isLoading && c.filteredStock.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OutlinedButton(
                          onPressed: c.currentPage == 1 ? null : c.prevPage,
                          child: const Text('Anterior'),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${c.currentPage} / ${c.totalPages}',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(width: 10),
                        OutlinedButton(
                          onPressed: c.currentPage == c.totalPages ? null : c.nextPage,
                          child: const Text('Siguiente'),
                        ),
                      ],
                    ),
                  ),

                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    '© 2025 DistriOchoa. Todos los derechos reservados.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _stockCard(StockModel item, Color estadoColor) {
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
          // estado dot
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: estadoColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: estadoColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${item.id} • ${item.producto}',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Categoría: ${item.categoria ?? "Sin categoría"}',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _chip('Disponible', item.disponible.toString()),
                    _chip('Entradas', item.entradas.toString()),
                    _chip('Salidas', item.salidas.toString()),
                    _chip('Dev Proveedor', item.devolucionesProveedor.toString()),
                    _chip('Dev Cliente', item.devolucionesCliente.toString()),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _navItem({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.verde.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: selected ? AppColors.verde : Colors.black87, size: 22),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: selected ? AppColors.verde : Colors.black87,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
