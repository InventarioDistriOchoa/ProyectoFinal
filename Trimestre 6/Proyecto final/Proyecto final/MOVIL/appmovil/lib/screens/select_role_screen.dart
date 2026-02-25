import 'package:flutter/material.dart';
import '../config/app_colors.dart';

class SelectRoleScreen extends StatefulWidget {
  const SelectRoleScreen({super.key});

  @override
  State<SelectRoleScreen> createState() => _SelectRoleScreenState();
}

class _SelectRoleScreenState extends State<SelectRoleScreen> {
  bool _isBannerHovered = false; // para zoom en pantallas grandes

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool isWide = width >= 768; // breakpoint tipo md

    return Scaffold(
      body: isWide
          ? _buildWideLayout(context) // 🖥️ como tu SelectRole.jsx
          : _buildMobileLayout(context), // 📱 diseño del muchacho + tarjeta
    );
  }

  // ============================
  // 📱 LAYOUT MÓVIL (MUCHACHO + TARJETA)
  // ============================
  Widget _buildMobileLayout(BuildContext context) {
    return Stack(
      children: [
        // Fondo del muchacho
        Positioned.fill(
          child: Image.asset(
            'assets/img/welcome_guy4.jpeg',
            fit: BoxFit.cover,
          ),
        ),

        // Logo arriba izquierda
        Positioned(
          top: 20,
          left: 20,
          child: Row(
            children: [
              Image.asset('assets/img/logo.png', width: 34),
              const SizedBox(width: 10),
              const Text(
                "DistriOchoa",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black54,
                      blurRadius: 4,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),

        // Tarjeta blanca centrada un poco más abajo
        Center(
          child: Container(
            margin: const EdgeInsets.only(top: 130, left: 18, right: 18),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color.fromARGB(227, 255, 255, 255),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.18),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.inventory_2_rounded,
                  color: AppColors.verde,
                  size: 55,
                ),
                const SizedBox(height: 14),
                const Text(
                  "BIENVENIDO",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 14),
                const Text(
                  "Al sistema de gestión de inventario.\n"
                  "Haz clic en continuar para ingresar.",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 26),

                // ✅ Botón CONTINUAR (rutas nombradas)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.verde,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {
                     Navigator.pushReplacementNamed(context, '/login');

                    },
                    child: const Text(
                      "Continuar",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // =======================================
  // 🖥️ LAYOUT PANTALLAS GRANDES (TYPE WEB)
  // =======================================
  Widget _buildWideLayout(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // COLUMNA IZQUIERDA (logo + textos + botón)
              Expanded(
                flex: 5,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo + nombre
                        Tooltip(
                          message: "¡Hola, soy el logo!",
                          child: Image.asset(
                            'assets/img/logo.png',
                            width: 100,
                          ),
                        ),
                        const SizedBox(height: 20),

                        const Text(
                          "BIENVENIDO",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: AppColors.verde,
                          ),
                        ),
                        const SizedBox(height: 10),

                        const Text(
                          "Al sistema de gestión de inventario.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            color: AppColors.grisOscuro,
                          ),
                        ),
                        const SizedBox(height: 6),

                        const Text(
                          "Haz clic en continuar para ingresar.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 17,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // ✅ (rutas nombradas)
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/login');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.verde,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 3,
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Continuar",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_right_alt),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 24),

              // COLUMNA DERECHA (banner con flow)
              Expanded(
                flex: 5,
                child: Center(
                  child: Tooltip(
                    message: "Banner con flow 😌",
                    child: MouseRegion(
                      onEnter: (_) {
                        setState(() => _isBannerHovered = true);
                      },
                      onExit: (_) {
                        setState(() => _isBannerHovered = false);
                      },
                      child: AnimatedScale(
                        scale: _isBannerHovered ? 1.05 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOut,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxWidth: 600,
                            ),
                            child: AspectRatio(
                              aspectRatio: 16 / 9,
                              child: Image.asset(
                                'assets/img/banner-distriochoa.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
