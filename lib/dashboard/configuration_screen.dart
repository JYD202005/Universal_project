import 'package:flutter/material.dart';
import 'package:base_de_datos_universal/colours/colours.dart';
import 'package:base_de_datos_universal/dashboard/menubar.dart' as custom_menu;

class ConfigurationScreen extends StatefulWidget {
  const ConfigurationScreen({super.key});

  @override
  State<ConfigurationScreen> createState() => _ConfigurationScreenState();
}

////-----------NO se que poner aqui------------------////
class _ConfigurationScreenState extends State<ConfigurationScreen> {
  bool _notificaciones = true;
  bool _temaOscuro = true;
  String _idioma = 'Español';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ProyectColors.surfaceDark,
      body: Row(
        children: [
          custom_menu.MenuBar(
            selectedIndex: 5,
            onDestinationSelected: (_) {},
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Configuración',
                    style: TextStyle(
                      color: ProyectColors.primaryGreen,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),
                  SwitchListTile(
                    title: const Text('Notificaciones',
                        style: TextStyle(color: ProyectColors.textPrimary)),
                    value: _notificaciones,
                    activeColor: ProyectColors.primaryGreen,
                    onChanged: (value) {
                      setState(() {
                        _notificaciones = value;
                      });
                    },
                  ),
                  const Divider(color: ProyectColors.primaryGreen),
                  SwitchListTile(
                    title: const Text('Tema oscuro',
                        style: TextStyle(color: ProyectColors.textPrimary)),
                    value: _temaOscuro,
                    activeColor: ProyectColors.primaryGreen,
                    onChanged: (value) {
                      setState(() {
                        _temaOscuro = value;
                      });
                    },
                  ),
                  const Divider(color: ProyectColors.primaryGreen),
                  ListTile(
                    title: const Text('Idioma',
                        style: TextStyle(color: ProyectColors.textPrimary)),
                    trailing: DropdownButton<String>(
                      value: _idioma,
                      dropdownColor: ProyectColors.surfaceDark,
                      style: const TextStyle(color: ProyectColors.textPrimary),
                      items: const [
                        DropdownMenuItem(
                            value: 'Español', child: Text('Español')),
                        DropdownMenuItem(
                            value: 'Inglés', child: Text('Inglés')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _idioma = value!;
                        });
                      },
                    ),
                  ),
                  const Divider(color: ProyectColors.primaryGreen),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ProyectColors.primaryGreen,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Configuración guardada')),
                      );
                    },
                    icon: const Icon(Icons.save,
                        color: ProyectColors.backgroundDark),
                    label: const Text(
                      'Guardar cambios',
                      style: TextStyle(
                        color: ProyectColors.backgroundDark,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
