import 'package:flutter/material.dart';
import 'package:base_de_datos_universal/colours/colours.dart';
import 'package:base_de_datos_universal/dashboard/home_screen.dart';
import 'package:base_de_datos_universal/MYSQL/db_service.dart';

class LoginDesign extends StatelessWidget {
  const LoginDesign({super.key});

  final TextStyle titleStyle = const TextStyle(
    color: ProyectColors.accentGreen,
    fontSize: 26,
    fontWeight: FontWeight.bold,
  );

  @override
  Widget build(BuildContext context) {
    final correoController = TextEditingController();
    final contrasenaController = TextEditingController();

    return Scaffold(
      backgroundColor: ProyectColors.backgroundDark,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/logo_universal.png', height: 120),
                const SizedBox(height: 24),
                Text('Bienvenido a la Universal', style: titleStyle),
                const SizedBox(height: 32),
                _buildInputField('Correo electrónico', Icons.email,
                    controller: correoController),
                const SizedBox(height: 16),
                _buildInputField('Contraseña', Icons.lock,
                    isPassword: true, controller: contrasenaController),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ProyectColors.primaryGreen,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 80, vertical: 16),
                  ),
                  onPressed: () async {
                    final correo = correoController.text.trim();
                    final contrasena = contrasenaController.text.trim();
                    final valido = await validarUsuario(correo, contrasena);

                    if (valido) {
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => const DashboardPage(),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Credenciales incorrectas')),
                      );
                    }
                  },
                  child: const Text('Iniciar sesión',
                      style: TextStyle(color: ProyectColors.textPrimary)),
                ),
                const SizedBox(height: 8),
                // Botón para saltar al dashboard sin login
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) => const DashboardPage(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  },
                  child: const Text(
                    'Saltar login',
                    style: TextStyle(
                        color: ProyectColors.textSecondary,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    '¿No tienes cuenta? Regístrate',
                    style: TextStyle(color: ProyectColors.accentGreen),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String hint, IconData icon,
      {bool isPassword = false, required TextEditingController controller}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: ProyectColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: ProyectColors.textSecondary),
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        prefixIcon: Icon(icon, color: ProyectColors.textPrimary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: ProyectColors.primaryGreen),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide:
              const BorderSide(color: ProyectColors.accentGreen, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
