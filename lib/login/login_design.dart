import 'package:flutter/material.dart';
import 'package:base_de_datos_universal/colours/colours.dart';
import 'package:base_de_datos_universal/dashboard/home_screen.dart';
<<<<<<< HEAD
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginDesign extends StatefulWidget {
  const LoginDesign({super.key});

  @override
  State<LoginDesign> createState() => _LoginDesignState();
}

class _LoginDesignState extends State<LoginDesign> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final supabase = Supabase.instance.client;

=======
import 'package:base_de_datos_universal/MYSQL/db_service.dart';

class LoginDesign extends StatelessWidget {
  const LoginDesign({super.key});

>>>>>>> origin/Diseño
  final TextStyle titleStyle = const TextStyle(
    color: ProyectColors.accentGreen,
    fontSize: 26,
    fontWeight: FontWeight.bold,
  );

  @override
<<<<<<< HEAD
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.session != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Login exitoso!')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al iniciar sesión')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
=======
  Widget build(BuildContext context) {
    final correoController = TextEditingController();
    final contrasenaController = TextEditingController();

>>>>>>> origin/Diseño
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
                Image.asset('logo_universal.png', height: 120),
                const SizedBox(height: 24),
                Text('Bienvenido a la Universal', style: titleStyle),
                const SizedBox(height: 32),
<<<<<<< HEAD
                _buildInputField(
                  'Correo electrónico',
                  Icons.email,
                  controller: emailController,
                ),
                const SizedBox(height: 16),
                _buildInputField(
                  'Contraseña',
                  Icons.lock,
                  isPassword: true,
                  controller: passwordController,
                ),
=======
                _buildInputField('Correo electrónico', Icons.email,
                    controller: correoController),
                const SizedBox(height: 16),
                _buildInputField('Contraseña', Icons.lock,
                    isPassword: true, controller: contrasenaController),
>>>>>>> origin/Diseño
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ProyectColors.primaryGreen,
<<<<<<< HEAD
                    padding:
                        const EdgeInsets.symmetric(horizontal: 80, vertical: 16),
                  ),
                  onPressed: login,
                  child: const Text(
                    'Iniciar sesión',
                    style: TextStyle(color: ProyectColors.textPrimary),
                  ),
                ),
                const SizedBox(height: 8),
=======
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
>>>>>>> origin/Diseño
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
<<<<<<< HEAD
                      color: ProyectColors.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    // Aquí puedes agregar navegación a registro
                  },
=======
                        color: ProyectColors.textSecondary,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {},
>>>>>>> origin/Diseño
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
