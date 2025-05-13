import 'package:base_de_datos_universal/colours/colours.dart';
import 'package:flutter/material.dart';
import 'package:base_de_datos_universal/dahsboard/home_screen.dart';

class LoginDesign extends StatelessWidget {
  const LoginDesign({super.key});

  @override
  Widget build(BuildContext context) {
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
                Image.asset('lib/assets/logo_universal.png', height: 120), 
                const SizedBox(height: 24),
                const Text(
                  'Bienvenido a la Universal',
                  style: TextStyle(
                    color: ProyectColors.accentGreen,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),
                _buildInputField('Correo electrónico', Icons.email),
                const SizedBox(height: 16),
                _buildInputField('Contraseña', Icons.lock, isPassword: true),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ProyectColors.primaryGreen,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 80, vertical: 16),
                  ),
                  onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const DashboardPage()),
                        );
                  }, // no funciona es solo diseño
                  child: const Text('Iniciar sesión',
                  style: TextStyle(color: ProyectColors.textPrimary),
                  ),
                ),
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
      {bool isPassword = false}) {
    return TextField(
      obscureText: isPassword,
      style: const TextStyle(color: ProyectColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: ProyectColors.textSecondary),
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        prefixIcon: Icon(icon, color: ProyectColors.textPrimary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: ProyectColors.primaryGreen),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: ProyectColors.accentGreen, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
