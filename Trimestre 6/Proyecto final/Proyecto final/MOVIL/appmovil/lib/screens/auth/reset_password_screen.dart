import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../widgets/sweet_alert.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String token;
  const ResetPasswordScreen({super.key, required this.token});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _passCtrl = TextEditingController();
  bool showPass = false;
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Restablecer contraseña')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _passCtrl,
              obscureText: !showPass,
              decoration: InputDecoration(
                labelText: 'Nueva contraseña',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(showPass ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => showPass = !showPass),
                ),
              ),
            ),
            const SizedBox(height: 20),

            loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () async {
                      final pass = _passCtrl.text.trim();
                      if (pass.isEmpty) return;

                      setState(() => loading = true);

                      try {
                        await AuthService().resetPassword(
  token: widget.token,
  nuevaContrasena: pass,
);


                        showSweetAlert(
                          context,
                          title: '¡Listo! 🎉',
                          message: 'Contraseña actualizada correctamente',
                          type: AlertType.success,
                        );

                        Navigator.pushReplacementNamed(context, '/login');
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
                    child: const Text('Actualizar contraseña'),
                  ),
          ],
        ),
      ),
    );
  }
}
