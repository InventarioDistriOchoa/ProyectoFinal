import 'package:flutter/material.dart';

// Importa aquí tus pantallas (screens)
import '../screens/home/home_screen.dart';
import '../screens/auth/login_screen.dart';

// Aquí importa las pantallas específicas de cada módulo (productos, usuarios, entradas, etc)
// Ejemplo:
// import '../screens/productos/producto_list_screen.dart';
// import '../screens/productos/producto_form_screen.dart';
// import '../screens/usuarios/usuario_list_screen.dart';
// import '../screens/usuarios/usuario_form_screen.dart';
// etc.

class AppRoutes {
  static const String initialRoute = '/login';

  static final Map<String, WidgetBuilder> routes = {
    '/login': (context) {
      // Aquí va tu pantalla de login, que debes crear
      return const Scaffold(body: Center(child: Text('Login Screen')));
    },

    '/home': (context) {
      // Recibe argumentos para el home (rol, nombre, foto)
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      return HomeScreen(
        role: args?['role'] ?? 'auxiliar',
        userName: args?['userName'] ?? 'Usuario',
        userPhotoUrl: args?['userPhotoUrl'] ?? 'https://i.pravatar.cc/150?img=12',
      );
    },

    // Aquí debes añadir las rutas para cada pantalla CRUD, por ejemplo:
    /*
    '/productos/list': (context) => ProductoListScreen(),
    '/productos/form': (context) => ProductoFormScreen(),
    '/usuarios/list': (context) => UsuarioListScreen(),
    '/personas/form': (context) => PersonaForm(),
    '/entradas/list': (context) => EntradaListScreen(),
    '/entradas/form': (context) => EntradaFormScreen(),
    // etc...
    */
  };

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final routes = AppRoutes.routes;
    final WidgetBuilder? builder = routes[settings.name];
    if (builder != null) {
      return MaterialPageRoute(builder: builder, settings: settings);
    }
    // Ruta no encontrada
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Ruta no encontrada')),
        body: Center(child: Text('No se encontró la ruta: ${settings.name}')),
      ),
    );
  }
}
