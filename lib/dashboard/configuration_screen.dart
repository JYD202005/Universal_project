import 'package:flutter/material.dart';
import 'package:base_de_datos_universal/colours/colours.dart';
import 'package:base_de_datos_universal/dashboard/menubar.dart' as custom_menu;

class ConfigurationScreen extends StatefulWidget {
  const ConfigurationScreen({super.key});

  @override
  State<ConfigurationScreen> createState() => _ConfigurationScreenState();
}

class _ConfigurationScreenState extends State<ConfigurationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ProyectColors.surfaceDark,
      body: Row(
        children: [
          custom_menu.MenuBar(
            selectedIndex: 4,
            onDestinationSelected: (_) {},
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Pantalla de Configuración',
                style: TextStyle(color: ProyectColors.textPrimary, fontSize: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}