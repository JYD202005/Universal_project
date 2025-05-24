import 'package:flutter/material.dart';
import 'package:base_de_datos_universal/colours/colours.dart';
import 'package:base_de_datos_universal/login/login_design.dart';
import 'package:base_de_datos_universal/dashboard/register_screen.dart';
import 'package:base_de_datos_universal/dashboard/home_screen.dart';
import 'package:base_de_datos_universal/dashboard/inventory_screen.dart';
import 'package:base_de_datos_universal/dashboard/employees_screen.dart';
import 'package:base_de_datos_universal/dashboard/configuration_screen.dart';

class MenuBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const MenuBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  void _navigateTo(BuildContext context, int index) {
    Widget page;
    switch (index) {
      case 0:
        page = const DashboardPage();
        break;
      case 1:
        page = const RegisterMenuScreen();
        break;
      case 2:
        page = const InventoryScreen();
        break;
      case 3:
        page = const EmployeesScreen();
        break;
      case 4:
        page = const ConfigurationScreen();
        break;
      default:
        page = const DashboardPage();
    }
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      backgroundColor: ProyectColors.backgroundDark,
      selectedIndex: selectedIndex,
      onDestinationSelected: (int index) {
        _navigateTo(context, index);
        onDestinationSelected(index);
      },
      labelType: NavigationRailLabelType.all,
      selectedIconTheme: const IconThemeData(color: ProyectColors.primaryGreen),
      selectedLabelTextStyle:
          const TextStyle(color: ProyectColors.primaryGreen),
      unselectedLabelTextStyle:
          const TextStyle(color: ProyectColors.textSecondary),
      leading: Column(
        children: [
          Image.asset('assets/logo_universal.png', height: 120),
          const Text('La Universal',
              style: TextStyle(
                  fontSize: 16,
                  color: ProyectColors.textPrimary,
                  fontWeight: FontWeight.bold)),
          const Divider(color: Colors.white24),
        ],
      ),
      trailing: Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Divider(color: Colors.white24),
            PopupMenuButton<String>(
              offset: const Offset(0, -10),
              icon: const CircleAvatar(
                radius: 18,
                backgroundColor: ProyectColors.primaryGreen,
                child: Icon(Icons.person, color: ProyectColors.backgroundDark),
              ),
              color: ProyectColors.surfaceDark,
              itemBuilder: (context) => [
                const PopupMenuItem<String>(
                  value: 'logout',
                  child: Text('Cerrar sesión',
                      style: TextStyle(color: ProyectColors.textPrimary)),
                ),
              ],
              onSelected: (value) {
                if (value == 'logout') {
                  Navigator.of(context).pushReplacement(
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => const LoginDesign(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                      opaque: true,
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 8),
            const Text('Usuario',
                style: TextStyle(color: ProyectColors.textSecondary)),
            const SizedBox(height: 16),
          ],
        ),
      ),
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.dashboard),
          label: Text('Inicio'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.list_alt),
          label: Text('Registro'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.inventory),
          label: Text('Inventario'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.group),
          label: Text('Empleados'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.settings),
          label: Text('Configuración'),
        ),
      ],
    );
  }
}
