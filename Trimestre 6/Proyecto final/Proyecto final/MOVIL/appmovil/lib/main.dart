import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/app_theme.dart';
import 'config/nav_key.dart';

// Controllers
import 'controllers/auth_controller.dart';
import 'controllers/producto_controller.dart';
import 'controllers/entrada_controller.dart';
import 'controllers/stock_controller.dart';
import 'controllers/ventas_controller.dart';
import 'controllers/categoria_controller.dart';
import 'controllers/rol_controller.dart';
import 'controllers/tipo_documento_controller.dart';
import 'controllers/proveedor_controller.dart';
import 'controllers/usuario_controller.dart';
import 'controllers/facturas_controller.dart';
import 'controllers/profile_controller.dart';
import 'controllers/historial_controller.dart';

// ✅ Reportes controllers
import 'controllers/reportes_controller.dart';

// ✅ Devoluciones controllers
import 'controllers/devolucion_controller.dart';
import 'controllers/tipo_devolucion_controller.dart';

// ✅ Services devoluciones
import 'services/devolucion_service.dart';
import 'services/tipo_devolucion_service.dart';

// Pantallas
import 'screens/select_role_screen.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';

// Ventas
import 'screens/ventas/ventas_home_screen.dart';
import 'screens/ventas/registro_ventas_screen.dart';
import 'screens/ventas/detalle_venta_screen.dart';

// Productos
import 'screens/productos/registro_producto_screen.dart';
import 'screens/productos/productos_list_screen.dart';

// Entradas
import 'screens/entradas/registro_entrada_screen.dart';
import 'screens/entradas/entradas_list_screen.dart';

// Reportes / Stock
import 'screens/reportes/stock_screen.dart';

// Categorías
import 'screens/categorias/categorias_screen.dart';

// ✅ Devoluciones screens
import 'screens/devoluciones/devoluciones_home_screen.dart';
import 'screens/devoluciones/registro_devoluciones_screen.dart';
import 'screens/devoluciones/registro_tipo_devolucion_screen.dart';

// ✅ Usuarios screens
import 'screens/usuarios/usuarios_home_screen.dart';

// ✅ Gestion de Roles
import 'screens/usuarios/gestion_roles_screen.dart';


// ✅ Gestion de Tipos de Documento
import 'screens/usuarios/gestion_tipo_documento_screen.dart';

// ✅ Gestion de Proveedores
import 'screens/usuarios/gestion_proveedores_screen.dart';


// ✅ Gestion de Usuarios
import 'screens/usuarios/gestion_usuarios_screen.dart';



// ✅ Reportes
import 'screens/reportes/reportes_screen.dart';


// ✅ Facturas
import 'screens/reportes/facturas_screen.dart';


// ✅ My Profile
import 'screens/usuarios/my_profile_screen.dart';

// ✅ Historial
import 'screens/historial_screen.dart';

void main() {
  debugPrint('🔥 APP INICIAL OK 123 🔥');
  runApp(const InvexApp());
}

class InvexApp extends StatelessWidget {
  const InvexApp({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('🔥 INVEXAPP BUILD OK 123 🔥');

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => ProductoController()),
        ChangeNotifierProvider(create: (_) => EntradaController()),
        ChangeNotifierProvider(create: (_) => StockController()),
        ChangeNotifierProvider(create: (_) => VentasController()),
        ChangeNotifierProvider(create: (_) => CategoriaController()),
        ChangeNotifierProvider(create: (_) => RolController()),
        ChangeNotifierProvider(create: (_) => TipoDocumentoController()),
        ChangeNotifierProvider(create: (_) => ProveedorController()),
        ChangeNotifierProvider(create: (_) => UsuariosController()),
        ChangeNotifierProvider(create: (_) => ReportesController()),
        ChangeNotifierProvider(create: (_) => FacturasController()),
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider(create: (_) => HistorialController()),



        // ✅ Devoluciones
        ChangeNotifierProvider(
          create: (_) => DevolucionController(DevolucionService()),
        ),
        ChangeNotifierProvider(
          create: (_) => TipoDevolucionController(TipoDevolucionService()),
        ),
      ],
      child: MaterialApp(
        navigatorKey: navKey,

        debugShowCheckedModeBanner: false,
        title: 'App DistriOchoa🌿',
        theme: AppTheme.light,
        initialRoute: '/select-role',
        routes: {
          // ✅ Devoluciones  
          '/devoluciones': (_) => const DevolucionesHomeScreen(),
          '/registro-devolucion': (_) => const RegistroDevolucionesScreen(),
          '/registro-tipo-devolucion': (_) => const RegistroTipoDevolucionScreen(),

          '/select-role': (_) => const SelectRoleScreen(),
          '/login': (_) => const LoginScreen(),
          '/dashboard': (_) => const DashboardScreen(),

          // Productos
          '/lista-productos': (_) => const ProductosListScreen(),
          '/registro-productos': (_) => const RegistroProductoScreen(),

          // Entradas
          '/lista-entradas': (_) => const EntradasListScreen(),
          '/registro-entradas': (_) => const RegistroEntradaScreen(),

          // Reportes / Stock
          '/stock': (_) => const StockScreen(),

          // Ventas
          '/ventas': (_) => const VentasHomeScreen(),
          '/registro-ventas': (_) => const RegistroVentasScreen(),
          '/detalle-venta': (_) => const DetalleVentaScreen(),

          // Categorías
          '/categorias': (_) => const CategoriasScreen(),

          // Usuarios
          '/home-usuarios': (_) => const UsuariosHomeScreen(),
          '/gestion-roles': (_) => const GestionRolesScreen(),

          // Tipos de Documento
          '/tipo-documento': (_) => const GestionTipoDocumentoScreen(),

          // Proveedores
          '/proveedores': (_) => const GestionProveedoresScreen(),


          // ✅ Gestion de Usuarios
          '/usuarios': (_) => const GestionUsuariosScreen(),

          // ✅ Reportes
          '/reportes': (_) => const ReportesScreen(),
          '/facturas': (_) => const FacturasScreen(),

          // ✅ My Profile
          '/my-profile': (_) => const MyProfileScreen(),

          // ✅ Historial
          '/historial': (_) => const HistorialScreen(),
        },
      ),
    );
  }
}
