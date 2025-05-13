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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildCard('Empleados activos', '120'),
                      _buildCard('Cuadrillas', '14'),
                      _buildCard('Actividades', '250'),
                      _buildCard('Inventario \$', '\$300k'),
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
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Expanded(child: _buildProductTable()),
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
      child: InkWell(
        onTap: () {},
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: ProyectColors.primaryGreen,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductTable() {
    return Container(
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