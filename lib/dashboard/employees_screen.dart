import 'package:flutter/material.dart';
import 'package:base_de_datos_universal/colours/colours.dart';
import 'package:base_de_datos_universal/dashboard/menubar.dart' as custom_menu;

class EmployeesScreen extends StatefulWidget {
  const EmployeesScreen({super.key});

  @override
  State<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends State<EmployeesScreen> {
  final List<Map<String, String>> _empleados = [
    {
      'nombre': 'Juan Pérez',
      'puesto': 'Vendedor',
      'telefono': '5551234567',
      'correo': 'juan@empresa.com',
    },
    {
      'nombre': 'Ana López',
      'puesto': 'Cajera',
      'telefono': '5559876543',
      'correo': 'ana@empresa.com',
    },
  ];

  String _busqueda = '';

  List<Map<String, String>> get _empleadosFiltrados {
    return _empleados.where((emp) {
      return emp['nombre']!.toLowerCase().contains(_busqueda.toLowerCase()) ||
          emp['puesto']!.toLowerCase().contains(_busqueda.toLowerCase());
    }).toList();
  }

  void _agregarEmpleado() {
    showDialog(
      context: context,
      builder: (context) {
        final nombreController = TextEditingController();
        final puestoController = TextEditingController();
        final telefonoController = TextEditingController();
        final correoController = TextEditingController();
        return AlertDialog(
          backgroundColor: ProyectColors.surfaceDark,
          title: const Text('Agregar empleado', style: TextStyle(color: ProyectColors.primaryGreen)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreController,
                decoration: const InputDecoration(labelText: 'Nombre', filled: true, fillColor: ProyectColors.surfaceDark),
                style: const TextStyle(color: ProyectColors.textPrimary),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: puestoController,
                decoration: const InputDecoration(labelText: 'Puesto', filled: true, fillColor: ProyectColors.surfaceDark),
                style: const TextStyle(color: ProyectColors.textPrimary),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: telefonoController,
                decoration: const InputDecoration(labelText: 'Teléfono', filled: true, fillColor: ProyectColors.surfaceDark),
                style: const TextStyle(color: ProyectColors.textPrimary),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: correoController,
                decoration: const InputDecoration(labelText: 'Correo', filled: true, fillColor: ProyectColors.surfaceDark),
                style: const TextStyle(color: ProyectColors.textPrimary),
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar', style: TextStyle(color: Colors.red)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: ProyectColors.primaryGreen),
              child: const Text('Agregar', style: TextStyle(color: ProyectColors.backgroundDark)),
              onPressed: () {
                setState(() {
                  _empleados.add({
                    'nombre': nombreController.text,
                    'puesto': puestoController.text,
                    'telefono': telefonoController.text,
                    'correo': correoController.text,
                  });
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _borrarEmpleado(int index) {
    setState(() {
      _empleados.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Empleado eliminado')),
    );
  }

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
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Gestión de Empleados',
                    style: TextStyle(
                      color: ProyectColors.primaryGreen,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          style: const TextStyle(color: ProyectColors.textPrimary),
                          decoration: InputDecoration(
                            hintText: 'Buscar por nombre o puesto...',
                            hintStyle: const TextStyle(color: ProyectColors.textSecondary),
                            prefixIcon: Icon(Icons.search, color: ProyectColors.primaryGreen),
                            filled: true,
                            fillColor: ProyectColors.surfaceDark,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _busqueda = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ProyectColors.primaryGreen,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _agregarEmpleado,
                        icon: const Icon(Icons.person_add, color: ProyectColors.backgroundDark),
                        label: const Text(
                          'Agregar empleado',
                          style: TextStyle(
                            color: ProyectColors.backgroundDark,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: ProyectColors.backgroundDark,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: ProyectColors.primaryGreen, width: 2),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingRowColor: MaterialStateProperty.all(ProyectColors.primaryGreen),
                            dataRowColor: MaterialStateProperty.all(ProyectColors.surfaceDark),
                            headingTextStyle: const TextStyle(
                              color: ProyectColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            dataTextStyle: const TextStyle(
                              color: ProyectColors.textPrimary,
                              fontSize: 15,
                            ),
                            columns: const [
                              DataColumn(label: Center(child: Text('Nombre'))),
                              DataColumn(label: Center(child: Text('Puesto'))),
                              DataColumn(label: Center(child: Text('Teléfono'))),
                              DataColumn(label: Center(child: Text('Correo'))),
                              DataColumn(label: Center(child: Text('Acciones'))),
                            ],
                            rows: List.generate(_empleadosFiltrados.length, (index) {
                              final emp = _empleadosFiltrados[index];
                              return DataRow(
                                cells: [
                                  DataCell(Center(child: Text(emp['nombre'] ?? ''))),
                                  DataCell(Center(child: Text(emp['puesto'] ?? ''))),
                                  DataCell(Center(child: Text(emp['telefono'] ?? ''))),
                                  DataCell(Center(child: Text(emp['correo'] ?? ''))),
                                  DataCell(
                                    Center(
                                      child: IconButton(
                                        icon: const Icon(Icons.delete, color: ProyectColors.danger),
                                        tooltip: 'Eliminar',
                                        onPressed: () => _borrarEmpleado(
                                            _empleados.indexOf(emp)),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ),
                        ),
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