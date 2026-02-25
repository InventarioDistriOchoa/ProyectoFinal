import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_colors.dart';
import '../controllers/auth_controller.dart';
import '../widgets/sweet_alert.dart';
import'../screens/auth/forgot_password_screen.dart';

// ✅ IMPORTA TU PANTALLA
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _correoController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  bool _showPass = false; // estado del ojito

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);

    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(
              'assets/img/fondo.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(color: Colors.black.withOpacity(0.2)),
            ),
          ),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/img/logo.png', width: 32),
                      const SizedBox(width: 8),
                      const Text(
                        'DistriOchoa',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Container(
                    padding: const EdgeInsets.all(32),
                    constraints: const BoxConstraints(maxWidth: 480),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          '¡Hola! Inicia aquí 😉',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text('👇', style: TextStyle(fontSize: 22)),
                        const SizedBox(height: 20),

                        TextField(
                          controller: _correoController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Correo',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(30)),
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          ),
                        ),
                        const SizedBox(height: 12),

                        TextField(
                          controller: _passwordController,
                          obscureText: !_showPass,
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            border: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(30)),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _showPass ? Icons.visibility_off : Icons.visibility,
                                color: _showPass ? Colors.red : AppColors.verde,
                              ),
                              onPressed: () => setState(() => _showPass = !_showPass),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        _loading
                            ? const CircularProgressIndicator()
                            : SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.verde,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                  ),
                                  onPressed: () async {
                                    final correo = _correoController.text.trim();
                                    final pass = _passwordController.text.trim();

                                    if (correo.isEmpty || pass.isEmpty) {
                                      await showSweetAlert(
                                        context,
                                        title: 'Ups…',
                                        message: 'Correo y contraseña son obligatorios.',
                                        type: AlertType.warning,
                                      );
                                      return;
                                    }

                                    setState(() => _loading = true);

                                    await authController.login(correo, pass);

                                    if (!mounted) return;

                                    if (authController.error != null) {
                                      await showSweetAlert(
                                        context,
                                        title: 'Error',
                                        message: authController.error!.replaceAll('Exception: ', ''),
                                        type: AlertType.error,
                                      );
                                    } else {
                                      await showSweetAlert(
                                        context,
                                        title: '¡Bienvenido! 🎉',
                                        message: 'Has iniciado sesión correctamente.',
                                        type: AlertType.success,
                                      );

                                      if (!mounted) return;
                                      Navigator.pushReplacementNamed(context, '/dashboard');
                                    }

                                    if (mounted) setState(() => _loading = false);
                                  },
                                  child: const Text(
                                    'Iniciar sesión',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                ),
                              ),
                        const SizedBox(height: 8),

                        // ✅ AQUÍ QUEDA CONECTADO
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                            );
                          },
                          child: const Text(
                            '¿Has olvidado tu contraseña?',
                            style: TextStyle(
                              color: AppColors.rojo,
                              fontSize: 14,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

