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
    'Agotados',
    'Deshabilitados',
  ];
  //Datos Variables Cuando se inicia la app
  String usuario = 'José José';
  String EmpleadosActivos = 180.toString();
  String VentasDelDia = 1500.toString();
  String ProductosAgotados = 1.toString();
  String EntradasRegistradas = 10.toString();

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
                      Text(
                        '¡Bienvenido, ${usuario}!',
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
                          _buildCard(
                              'Empleados activos', '${EmpleadosActivos}'),
                          _buildCard('Ventas del Dia', '${VentasDelDia}'),
                          _buildCard(
                              'Productos Agotados', '${ProductosAgotados}'),
                          _buildCard(
                              'Entradas Registradas', '${EntradasRegistradas}'),
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
                              setState(
                                () => selectedFilter = filter,
                              );
                              setState(() {
                                switch (filter) {
                                  case 'Todos':
                                    loadTabla();
                                    break;
                                  case 'Stock bajo':
                                    stockBajo();
                                    break;
                                  case 'Agotados':
                                    vencidos();
                                    break;
                                  case 'Deshabilitados':
                                    deshabilitado();
                                    break;
                                }
                              });
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
                            label: Text('Proveedor',
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
                            item['clave'],
                            item['nombre'],
                            item['familia'],
                            item['stock_actual'].toString(),
                            item['stock_minimo'].toString(),
                            item['proveedor'],
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
      String minimo, String proveedor, String estado) {
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
        DataCell(Center(
          child: Text(proveedor ?? 'Sin proveedor',
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
        'clave': 'R-1',
        'nombre': 'Cables UTP',
        'familia': 'Redes',
        'stock_actual': 51,
        'stock_minimo': 10,
        'disponible': false,
        'estado': 'Bajo',
        'proveedor': 'Proveedor 1',
      },
      {
        'clave': 'R-2',
        'nombre': 'Router TP-Link',
        'familia': 'Redes',
        'stock_actual': 3,
        'stock_minimo': 5,
        'disponible': true,
        'estado': 'Óptimo',
        'proveedor': 'Proveedor 2',
      },
      {
        'clave': 'E-1',
        'nombre': 'Arduino UNO',
        'familia': 'Electrónica',
        'stock_actual': 0,
        'stock_minimo': 15,
        'disponible': true,
        'estado': 'Crítico',
        'proveedor': 'Proveedor 3',
      },
      {
        'clave': 'I-1',
        'nombre': 'Multímetro',
        'familia': 'Instrumentos',
        'stock_actual': 1,
        'stock_minimo': 3,
        'disponible': true,
        'estado': 'Bajo',
        'proveedor': 'sin proveedor',
      },
    ];
    switch (selectedFilter) {
      case 'Todos':
        temp = temp.where((item) => item['disponible'] == true).toList();
        break;
      case 'Stock bajo':
        temp = temp.where((item) => item['disponible'] == true).toList();
        break;
      case 'Agotados':
        temp = temp.where((item) => item['disponible'] == true).toList();
        break;
    }
    LoadTablaTodo = temp;
  }

  void stockBajo() {
    loadTabla();
    LoadTablaTodo =
        LoadTablaTodo.where((item) => item['estado'] == 'Bajo').toList();
  }

  void vencidos() {
    loadTabla();
    LoadTablaTodo =
        LoadTablaTodo.where((item) => item['stock_actual'] == 0).toList();
  }

  void deshabilitado() {
    loadTabla();
    LoadTablaTodo =
        LoadTablaTodo.where((item) => item['disponible'] == false).toList();
  }
}
