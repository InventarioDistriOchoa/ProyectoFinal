import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool loading = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      loading = true;
    });

    try {
      final authController = Provider.of<AuthController>(context, listen: false);

      // Aquí normalmente harías la llamada al backend
      // Por ejemplo:
      // final response = await AuthService.login(email, password);
      // final token = response.token;
      // final role = response.role;

      // Simulación de login:
      await Future.delayed(const Duration(seconds: 1));
      final token = 'dummy_token';
      final role = 'admin';

      // Guardar token y rol
      await authController.login(token, role);

      // La RootScreen detecta que está autenticado y navega automáticamente
      // No necesitas Navigator.push aquí

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al iniciar sesión: $e")),
      );
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primary = Colors.green.shade700;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Iniciar Sesión",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),

                // Email
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: "Correo",
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? "Ingresa tu correo" : null,
                ),
                const SizedBox(height: 16),

                // Password
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Contraseña",
                    prefixIcon: const Icon(Icons.lock),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? "Ingresa tu contraseña" : null,
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                    ),
                    onPressed: loading ? null : _login,
                    child: loading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text(
                            "Iniciar Sesión",
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
