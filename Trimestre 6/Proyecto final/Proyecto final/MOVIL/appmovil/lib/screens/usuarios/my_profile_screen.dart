import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../../config/app_colors.dart';
import '../../controllers/profile_controller.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  int _navIndex = 0; // 0 Inicio, 1 Productos, 2 Ventas
  final _picker = ImagePicker();

  void _onBottomTap(int index) {
    if (index == _navIndex) return;
    setState(() => _navIndex = index);

    if (index == 0) Navigator.pushReplacementNamed(context, '/dashboard');
    if (index == 1) Navigator.pushReplacementNamed(context, '/productos');
    if (index == 2) Navigator.pushReplacementNamed(context, '/ventas');
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<ProfileController>().cargar(); // ✅ aquí va cargar()
    });
  }

  Future<void> _pickAndUploadFoto() async {
    try {
      final x = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (x == null) return;

      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      await context.read<ProfileController>().subirFoto(x);

      if (mounted) Navigator.pop(context);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto subida correctamente ✅')),
        );
      }
    } catch (e) {
      if (mounted) Navigator.of(context, rootNavigator: true).popUntil((r) => r.isFirst);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    }
  }

  Future<void> _abrirEditarModal(ProfileController ctrl) async {
    final p = ctrl.perfil!;
    final nombreCtrl = TextEditingController(text: p.nombre);
    final correoCtrl = TextEditingController(text: p.correo);
    final docCtrl = TextEditingController(text: p.numeroDocumento);
    final passCtrl = TextEditingController(text: '');
    String tipoId = p.tipoDocumentoId;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 14,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(height: 14),
              const Text('Editar Perfil', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
              const SizedBox(height: 14),

              _Input(label: 'Nombre', controller: nombreCtrl, icon: Icons.person_rounded),
              const SizedBox(height: 10),
              _Input(label: 'Correo', controller: correoCtrl, icon: Icons.email_rounded, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 10),
              _Input(label: 'Documento', controller: docCtrl, icon: Icons.badge_rounded),
              const SizedBox(height: 10),

              // Tipo documento
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.assignment_ind_rounded, color: AppColors.verde),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: tipoId.isEmpty ? null : tipoId,
                          isExpanded: true,
                          hint: const Text('Tipo de documento'),
                          items: ctrl.tiposDocumento
                              .map((t) => DropdownMenuItem(
                                    value: t.id.toString(),
                                    child: Text(t.descripcion),
                                  ))
                              .toList(),
                          onChanged: (v) {
                            if (v == null) return;
                            tipoId = v;
                            setState(() {});
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              _Input(
                label: 'Contraseña (opcional)',
                controller: passCtrl,
                icon: Icons.lock_rounded,
                obscure: true,
                hint: 'Solo si la quieres cambiar',
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.verde,
                        side: const BorderSide(color: AppColors.verde),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar', style: TextStyle(fontWeight: FontWeight.w900)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.verde,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () async {
                        try {
                          if (nombreCtrl.text.trim().isEmpty ||
                              correoCtrl.text.trim().isEmpty ||
                              docCtrl.text.trim().isEmpty ||
                              tipoId.trim().isEmpty) {
                            throw Exception('Completa todos los campos obligatorios.');
                          }

                          Navigator.pop(context);

                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => const Center(child: CircularProgressIndicator()),
                          );

                          await ctrl.actualizarPerfil(
                            nombre: nombreCtrl.text,
                            correo: correoCtrl.text,
                            numeroDocumento: docCtrl.text,
                            tipoDocumentoId: tipoId,
                            contrasena: passCtrl.text,
                          );

                          if (mounted) Navigator.pop(context);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Perfil actualizado ✅')),
                            );
                          }
                        } catch (e) {
                          if (mounted) Navigator.of(context, rootNavigator: true).popUntil((r) => r.isFirst);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
                            );
                          }
                        }
                      },
                      child: const Text('Guardar', style: TextStyle(fontWeight: FontWeight.w900)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _cerrarSesion(ProfileController ctrl) async {
    try {
      await ctrl.cerrarSesion();
    } finally {
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/select-role', (r) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<ProfileController>();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0.6,
        backgroundColor: Colors.white,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.negroSuave),
        title: const Text(
          '👤 Mi Perfil',
          style: TextStyle(color: AppColors.negroSuave, fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: ctrl.loading
            ? const Center(child: CircularProgressIndicator())
            : ctrl.error.isNotEmpty
                ? _ErrorState(message: ctrl.error, onRetry: () => context.read<ProfileController>().cargar())
                : (ctrl.perfil == null)
                    ? const Center(child: Text('No se encontró el perfil.'))
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                        children: [
                          _ProfileHeader(
                            nombre: ctrl.perfil!.nombre,
                            rol: ctrl.perfil!.rolDescripcion,
                            fotoUrl: (ctrl.perfil!.fotoPath == null || ctrl.perfil!.fotoPath!.isEmpty)
                                ? null
                                : 'http://localhost:3001${ctrl.perfil!.fotoPath}',
                            onChangePhoto: _pickAndUploadFoto,
                          ),
                          const SizedBox(height: 12),

                          _InfoGrid(
                            nombre: ctrl.perfil!.nombre,
                            correo: ctrl.perfil!.correo,
                            documento: ctrl.perfil!.numeroDocumento,
                            tipoDoc: ctrl.tipoDocDescripcion,
                          ),
                          const SizedBox(height: 14),

                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.verde,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: () => _abrirEditarModal(ctrl),
                            child: const Text('Editar Perfil', style: TextStyle(fontWeight: FontWeight.w900)),
                          ),
                          const SizedBox(height: 10),

                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: BorderSide(color: Colors.red.shade300),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: () => _cerrarSesion(ctrl),
                            child: const Text('Salir', style: TextStyle(fontWeight: FontWeight.w900)),
                          ),
                        ],
                      ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _navIndex,
        onTap: _onBottomTap,
        selectedItemColor: AppColors.verde,
        unselectedItemColor: Colors.grey.shade600,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w900),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2_rounded), label: 'registro-productos'),
          BottomNavigationBarItem(icon: Icon(Icons.point_of_sale_rounded), label: 'Ventas'),
        ],
      ),
    );
  }
}

/* ===================== UI ===================== */

class _ProfileHeader extends StatelessWidget {
  final String nombre;
  final String rol;
  final String? fotoUrl;
  final VoidCallback onChangePhoto;

  const _ProfileHeader({
    required this.nombre,
    required this.rol,
    required this.fotoUrl,
    required this.onChangePhoto,
  });

  @override
  Widget build(BuildContext context) {
    final placeholder = 'http://localhost:3001/uploads/default-avatar.png';
    final img = fotoUrl ?? placeholder;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 62,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: NetworkImage(img),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: InkWell(
                  onTap: onChangePhoto,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.verde,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 18),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(nombre, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
          const SizedBox(height: 4),
          Text(rol, style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _InfoGrid extends StatelessWidget {
  final String nombre;
  final String correo;
  final String documento;
  final String tipoDoc;

  const _InfoGrid({
    required this.nombre,
    required this.correo,
    required this.documento,
    required this.tipoDoc,
  });

  @override
  Widget build(BuildContext context) {
    Widget card(IconData icon, String label, String value) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 30, color: AppColors.verde),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            Text(value, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w700)),
          ],
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        card(Icons.person_rounded, 'Nombre', nombre),
        card(Icons.email_rounded, 'Correo', correo),
        card(Icons.badge_rounded, 'Documento', documento),
        card(Icons.assignment_ind_rounded, 'Tipo Doc.', tipoDoc),
      ],
    );
  }
}

class _Input extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final bool obscure;
  final String? hint;
  final TextInputType? keyboardType;

  const _Input({
    required this.label,
    required this.controller,
    required this.icon,
    this.obscure = false,
    this.hint,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.verde),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 48, color: Colors.red),
            const SizedBox(height: 10),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.verde,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: onRetry,
              child: const Text('Reintentar', style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ],
        ),
      ),
    );
  }
}
