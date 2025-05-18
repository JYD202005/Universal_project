import 'package:flutter/material.dart';
import 'package:base_de_datos_universal/colours/colours.dart';
import 'package:base_de_datos_universal/dashboard/menubar.dart' as custom_menu;

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  //controllers
  final ScrollController _mainScrollController = ScrollController();
  final ScrollController _verticalTableScrollController = ScrollController();
  final ScrollController _horizontalTableScrollController = ScrollController();

  //Lsitas Para cargar datos
  List<Map<String, dynamic>> LoadTablaTodo = [];
  // Fijos
  String selectedFilter = 'Todos';
  final List<String> filters = [
    'Todos',
    'Stock bajo',
    'Vencidos',
    'Sin proveedor'
  ];
  @override
  void initState() {
    super.initState();
    loadTabla();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ProyectColors.surfaceDark,
      body: Row(
        children: [
          custom_menu.MenuBar(
            selectedIndex: 0,
            onDestinationSelected: (int index) {
              setState(() {});
            },
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Scrollbar(
                controller: _mainScrollController,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: _mainScrollController,
                  scrollDirection: Axis.vertical,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '¡Bienvenido, Jose!',
                        style: TextStyle(
                            color: ProyectColors.textPrimary,
                            fontSize: 24,
                            fontWeight: FontWeight.bold),
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
                          _buildCard('Entradas Registradas', '50'),
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
                            showCheckmark: false,
                            avatar: selectedFilter == filter
                                ? const Icon(Icons.visibility,
                                    size: 20, color: Colors.black)
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
            ),
          ),
        ],
      ),
    );
  }

  //cards de datos
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
                  color: ProyectColors.textPrimary, fontSize: 19),
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

  //Tabla de productos
  Widget _buildProductTable() {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: ProyectColors.primaryGreen),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Scrollbar(
            controller: _verticalTableScrollController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: _verticalTableScrollController,
              scrollDirection: Axis.vertical,
              child: Scrollbar(
                controller: _horizontalTableScrollController,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: _horizontalTableScrollController,
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: 1190, maxWidth: 1200),
                    child: DataTable(
                      showCheckboxColumn: false,
                      dataRowHeight: 70,
                      headingRowHeight: 60,
                      columnSpacing: 24,
                      dividerThickness: 1,
                      headingRowColor:
                          MaterialStateProperty.all(ProyectColors.primaryGreen),
                      columns: [
                        DataColumn(
                            headingRowAlignment: MainAxisAlignment.center,
                            label: Text('Clave',
                                style: TextStyle(
                                    color: ProyectColors.textPrimary))),
                        DataColumn(
                            headingRowAlignment: MainAxisAlignment.center,
                            label: Text('Producto',
                                style: TextStyle(
                                    color: ProyectColors.textPrimary))),
                        DataColumn(
                            headingRowAlignment: MainAxisAlignment.center,
                            label: Text('Familia',
                                style: TextStyle(
                                    color: ProyectColors.textPrimary))),
                        DataColumn(
                            headingRowAlignment: MainAxisAlignment.center,
                            label: Text('Stock actual',
                                style: TextStyle(
                                    color: ProyectColors.textPrimary))),
                        DataColumn(
                            headingRowAlignment: MainAxisAlignment.center,
                            label: Text('Stock mínimo',
                                style: TextStyle(
                                    color: ProyectColors.textPrimary))),
                        DataColumn(
                            headingRowAlignment: MainAxisAlignment.center,
                            label: Text('Estado',
                                style: TextStyle(
                                    color: ProyectColors.textPrimary))),
                      ],
                      rows: [
                        for (var item in LoadTablaTodo)
                          _buildRow(
                            item['Clave'],
                            item['producto'],
                            item['Familia'],
                            item['stock_actual'].toString(),
                            item['stock_minimo'].toString(),
                            item['estado'],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  DataRow _buildRow(String clave, String prod, String cat, String actual,
      String minimo, String estado) {
    Color estadoColor = estado == 'Crítico'
        ? ProyectColors.danger
        : estado == 'Bajo'
            ? ProyectColors.warning
            : ProyectColors.primaryGreen;

    return DataRow(
      cells: [
        DataCell(Center(
          child: Text(clave,
              style: const TextStyle(color: ProyectColors.textPrimary)),
        )),
        DataCell(Center(
          child: Text(prod,
              style: const TextStyle(color: ProyectColors.textPrimary)),
        )),
        DataCell(Center(
          child: Text(cat,
              style: const TextStyle(color: ProyectColors.textSecondary)),
        )),
        DataCell(Center(
          child: Text(actual,
              style: const TextStyle(color: ProyectColors.textPrimary)),
        )),
        DataCell(Center(
          child: Text(minimo,
              style: const TextStyle(color: ProyectColors.textPrimary)),
        )),
        DataCell(
          Container(
            alignment: Alignment.center,
            height: 35,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: estadoColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                estado,
                style: TextStyle(
                    color: ProyectColors.textPrimary,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void loadTabla() {
    List<Map<String, dynamic>> temp = [
      {
        'Clave': 'R-1',
        'producto': 'Cables UTP',
        'Familia': 'Redes',
        'stock_actual': 51,
        'stock_minimo': 10,
        'disponible': true,
      },
      {
        'Clave': 'R-2',
        'producto': 'Router TP-Link',
        'Familia': 'Redes',
        'stock_actual': 3,
        'stock_minimo': 5,
      },
      {
        'Clave': 'E-1',
        'producto': 'Arduino UNO',
        'Familia': 'Electrónica',
        'stock_actual': 7,
        'stock_minimo': 15,
        'disponible': true,
      },
      {
        'Clave': 'I-1',
        'producto': 'Multímetro',
        'Familia': 'Instrumentos',
        'stock_actual': 1,
        'stock_minimo': 3,
        'disponible': true,
      },
    ];

    LoadTablaTodo = temp.map((item) {
      int actual = item['stock_actual'];
      int minimo = item['stock_minimo'];

      String estado;
      if (actual * 2 <= minimo) {
        estado = 'Crítico'; // rojo
      } else if (actual < minimo) {
        estado = 'Bajo'; // amarillo
      } else {
        estado = 'Óptimo'; // verde
      }

      item['estado'] = estado;
      return item;
    }).toList();
    print(LoadTablaTodo);
  }
}
