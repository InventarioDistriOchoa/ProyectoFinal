import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../widgets/sweet_alert.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _correoCtrl = TextEditingController();
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recuperar contraseña')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Ingresa tu correo y te enviaremos un enlace 📩',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _correoCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Correo',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () async {
                      final correo = _correoCtrl.text.trim();
                      if (correo.isEmpty) {
                        showSweetAlert(
                          context,
                          title: 'Ups',
                          message: 'Debes ingresar un correo',
                          type: AlertType.warning,
                        );
                        return;
                      }

                      setState(() => loading = true);

                      try {
                        await AuthService().forgotPassword(correo);

                        showSweetAlert(
                          context,
                          title: 'Correo enviado 📬',
                          message:
                              'Revisa tu correo para continuar con la recuperación.',
                          type: AlertType.success,
                        );
                      } catch (e) {
                        showSweetAlert(
                          context,
                          title: 'Error',
                          message: e.toString().replaceAll('Exception: ', ''),
                          type: AlertType.error,
                        );
                      } finally {
                        setState(() => loading = false);
                      }
                    },
                    child: const Text('Enviar correo'),
                  ),
          ],
        ),
      ),
    );
  }
}
