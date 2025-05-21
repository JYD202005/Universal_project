import 'package:flutter/material.dart';
import 'package:base_de_datos_universal/colours/colours.dart';
import 'package:base_de_datos_universal/dashboard/menubar.dart' as custom_menu;

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ProyectColors.surfaceDark,
      body: Row(
        children: [
          custom_menu.MenuBar(
            selectedIndex: 2,
            onDestinationSelected: (_) {},
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Pantalla de Inventario',
                style: TextStyle(color: ProyectColors.textPrimary, fontSize: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}