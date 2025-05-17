import 'package:flutter/material.dart';
import 'package:base_de_datos_universal/colours/colours.dart';
import 'package:base_de_datos_universal/dashboard/menubar.dart' as custom_menu;

class EmployeesScreen extends StatefulWidget {
  const EmployeesScreen({super.key});

  @override
  State<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends State<EmployeesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ProyectColors.surfaceDark,
      body: Row(
        children: [
          custom_menu.MenuBar(
            selectedIndex: 3,
            onDestinationSelected: (_) {},
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Pantalla de Empleados',
                style: TextStyle(color: ProyectColors.textPrimary, fontSize: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}