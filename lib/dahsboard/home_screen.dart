import 'package:flutter/material.dart';
import 'package:base_de_datos_universal/colours/colours.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int selectedIndex = 0;
  String selectedFilter = 'Todos';
  final List<String> filters = ['Todos', 'Stock bajo', 'Vencidos', 'Sin proveedor'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ProyectColors.surfaceDark,
      body: Row(
        children: [
          NavigationRail(
            backgroundColor: ProyectColors.backgroundDark,
            selectedIndex: selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            selectedIconTheme: const IconThemeData(color: ProyectColors.primaryGreen),
            selectedLabelTextStyle: const TextStyle(color: ProyectColors.primaryGreen),
            unselectedLabelTextStyle: const TextStyle(color: ProyectColors.textSecondary),
            leading: Column(
              children: [
                Image.asset('lib/assets/logo_universal.png', height: 120),
                const Text('La Universal', style: TextStyle(fontSize: 16, color: ProyectColors.textPrimary,fontWeight: FontWeight.bold,)),
                const Divider(color: Colors.white24),
              ],
            ),
            trailing: Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: const [
                  Divider(color: Colors.white24),
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: ProyectColors.primaryGreen,
                    child: Icon(Icons.person, color: ProyectColors.backgroundDark),
                  ),
                  SizedBox(height: 8),
                  Text('Usuario', style: TextStyle(color: ProyectColors.textSecondary)),
                  SizedBox(height: 16),
                ],
              ),
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard),
                label: Text('Inicio'),
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
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '¡Bienvenido, Jose!',
                    style: TextStyle(
                      color: ProyectColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Así es como va el negocio',
                    style: TextStyle(color: ProyectColors.textSecondary),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildCard('Empleados activos', '120'),
                      _buildCard('Ventas del Dia', '14'),
                      _buildCard('Productos Agotados', '250'),
                      _buildCard('Entradas Registradas' , '50'),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Wrap(
                    spacing: 12,
                    children: filters.map((filter) {
                      return ChoiceChip(
                        label: Text(filter),
                        selected: selectedFilter == filter,
                        onSelected: (bool selected) {
                          setState(() => selectedFilter = filter);
                        },
                        selectedColor: ProyectColors.primaryGreen,
                        labelStyle: TextStyle(
                          color: selectedFilter == filter
                              ? Colors.black
                              : ProyectColors.textPrimary,
                        ),
                        backgroundColor: ProyectColors.surfaceDark,
                        avatar: selectedFilter == filter
                            ? const Icon(Icons.visibility, size: 20, color: Colors.black)
                            : null,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                  _buildProductTable(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(String title, String value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3), 
              blurRadius: 12,                     
              spreadRadius: 1,                     
              offset: const Offset(0, 4), 
            ),
          ],
          color: ProyectColors.primaryGreen, 
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, 
          crossAxisAlignment: CrossAxisAlignment.center, 
          children: [
            Text(
              title,
              textAlign: TextAlign.center, 
              style: const TextStyle(
                color: ProyectColors.textPrimary,
                fontSize: 19
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              textAlign: TextAlign.center, 
              style: const TextStyle(
                color: ProyectColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductTable() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: ProyectColors.primaryGreen),
          borderRadius: BorderRadius.circular(12),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: DataTable(
            columnSpacing: 16,
            headingRowColor: MaterialStateProperty.all(ProyectColors.primaryGreen),
            columns: const [
              DataColumn(label: Text('Producto', style: TextStyle(color: ProyectColors.textPrimary))),
              DataColumn(label: Text('Categoría', style: TextStyle(color: ProyectColors.textPrimary))),
              DataColumn(label: Text('Stock actual', style: TextStyle(color: ProyectColors.textPrimary))),
              DataColumn(label: Text('Stock mínimo', style: TextStyle(color: ProyectColors.textPrimary))),
              DataColumn(label: Text('Estado', style: TextStyle(color: ProyectColors.textPrimary))),
            ],
            rows: [
              _buildRow('Cables UTP', 'Redes', '4', '10', 'Bajo'),
              _buildRow('Router TP-Link', 'Redes', '2', '5', 'Crítico'),
              _buildRow('Arduino UNO', 'Electrónica', '7', '15', 'Bajo'),
              _buildRow('Multímetro', 'Instrumentos', '1', '3', 'Crítico'),
            ],
          ),
        ),
      ),
    );
  }

  DataRow _buildRow(String prod, String cat, String actual, String minimo, String estado) {
    Color estadoColor = estado == 'Crítico'
        ? ProyectColors.danger
        : estado == 'Bajo'
            ? ProyectColors.warning
            : ProyectColors.primaryGreen;

    return DataRow(
      cells: [
        DataCell(Text(prod, style: const TextStyle(color: ProyectColors.textPrimary))),
        DataCell(Text(cat, style: const TextStyle(color: ProyectColors.textSecondary))),
        DataCell(Text(actual, style: const TextStyle(color: ProyectColors.textPrimary))),
        DataCell(Text(minimo, style: const TextStyle(color: ProyectColors.textPrimary))),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: estadoColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              estado,
              style: const TextStyle(
                color: ProyectColors.textPrimary,
                fontWeight: FontWeight.bold
              ),
            ),
          ),
        ),
      ],
    );
  }
}