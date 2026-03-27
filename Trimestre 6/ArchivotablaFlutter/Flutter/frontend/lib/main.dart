import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home/home_screen.dart';
import 'controllers/persona_controller.dart';
import 'controllers/venta_controller.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PersonaController()),
        ChangeNotifierProvider(create: (_) => VentaController()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Mi App',
        theme: ThemeData(primarySwatch: Colors.green),
        home: const HomeScreen(), // abre directamente HomeScreen
      ),
    );
  }
}
