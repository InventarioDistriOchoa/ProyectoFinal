
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controladores para los campos
  final TextEditingController nombreCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController claveCtrl = TextEditingController();

  // URL del backend (ajústala si tu ruta es diferente)
  final String url = "http://10.0.2.2/valka/backend_php/registro.php";

  // Función para enviar datos al backend
  Future<void> registrar() async {
    final datos = {
      "nombre": nombreCtrl.text,
      "email": emailCtrl.text,
      "clave": claveCtrl.text,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(datos),
      );

      final body = jsonDecode(response.body);

      if (body["status"] == "ok") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Usuario registrado correctamente")),
        );

        // Limpia los campos
        nombreCtrl.clear();
        emailCtrl.clear();
        claveCtrl.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(body["mensaje"])),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error de conexión: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registrar Usuario")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: nombreCtrl,
              decoration: const InputDecoration(labelText: "Nombre"),
            ),
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: claveCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Clave"),
            ),

            const SizedBox(height: 25),

            ElevatedButton(
              onPressed: registrar,
              child: const Text("Registrar"),
            ),
          ],
        ),
      ),
    );
  }
}