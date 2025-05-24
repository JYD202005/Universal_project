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
  bool _scrollInTable = false;

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        loadTabla();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ProyectColors.surfaceDark,
      body: RawScrollbar(
        controller: _mainScrollController,
        thumbVisibility: !_scrollInTable,
        thumbColor: ProyectColors.textPrimary.withOpacity(0.5),
        thickness: 6,
        radius: const Radius.circular(8), // Esto suaviza el borde
        crossAxisMargin: 2,
        child: Row(
          children: [
            custom_menu.MenuBar(
              selectedIndex: 0,
              onDestinationSelected: (int index) {
                setState(() {});
              },
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: _mainScrollController,
                scrollDirection: Axis.vertical,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '¡Bienvenido, $usuario!',
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
                        children: [
                          _buildCard('Empleados activos', EmpleadosActivos),
                          _buildCard('Ventas del día', VentasDelDia),
                          _buildCard(
                              'Entradas registradas', EntradasRegistradas),
                          _buildCard('Productos agotados', ProductosAgotados),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 18,
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
                      const SizedBox(height: 16),
                      MouseRegion(
                        onEnter: (_) => setState(() => _scrollInTable = true),
                        onExit: (_) => setState(() => _scrollInTable = false),
                        child: _buildProductTable(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
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

  Widget _buildProductTable() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width: double.infinity,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: ProyectColors.primaryGreen),
                borderRadius: BorderRadius.circular(12),
              ),
              child: RawScrollbar(
                controller: _horizontalTableScrollController,
                thumbVisibility: _scrollInTable,
                trackVisibility: _scrollInTable,
                thumbColor: ProyectColors.primaryGreen.withOpacity(0.8),
                thickness: 6,
                radius: const Radius.circular(8),
                crossAxisMargin: 1,
                child: SizedBox(
                  height: 60 + 6 * 70, // altura visible: encabezado + 6 filas
                  width: constraints.maxWidth,
                  child: SingleChildScrollView(
                    controller: _horizontalTableScrollController,
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      controller: _verticalTableScrollController,
                      scrollDirection: Axis.vertical,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: constraints.maxWidth,
                        ),
                        child: IntrinsicWidth(
                          child: IntrinsicHeight(
                            child: _buildDataTable(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDataTable() {
    return DataTable(
      showCheckboxColumn: false,
      dataRowHeight: 60,
      headingRowHeight: 56,
      columnSpacing: 24,
      dividerThickness: 1,
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
      columns: [
        DataColumn(
            headingRowAlignment: MainAxisAlignment.center,
            label: Center(
                child: Text('Clave',
                    style: TextStyle(
                      color: ProyectColors.textPrimary,
                    )))),
        DataColumn(
            headingRowAlignment: MainAxisAlignment.center,
            label: Center(
                child: Text('Producto',
                    style: TextStyle(color: ProyectColors.textPrimary)))),
        DataColumn(
            headingRowAlignment: MainAxisAlignment.center,
            label: Center(
                child: Text('Familia',
                    style: TextStyle(color: ProyectColors.textPrimary)))),
        DataColumn(
            headingRowAlignment: MainAxisAlignment.center,
            label: Center(
                child: Text('Stock actual',
                    style: TextStyle(color: ProyectColors.textPrimary)))),
        DataColumn(
            headingRowAlignment: MainAxisAlignment.center,
            label: Center(
                child: Text('Stock mínimo',
                    style: TextStyle(color: ProyectColors.textPrimary)))),
        DataColumn(
            headingRowAlignment: MainAxisAlignment.center,
            label: Center(
                child: Text('Proveedor',
                    style: TextStyle(color: ProyectColors.textPrimary)))),
        DataColumn(
            headingRowAlignment: MainAxisAlignment.center,
            label: Center(
                child: Text('Estado',
                    style: TextStyle(color: ProyectColors.textPrimary)))),
      ],
      rows: LoadTablaTodo.map((item) {
        return DataRow(
          cells: [
            DataCell(Center(
                child: Text(item['clave'],
                    style: TextStyle(color: ProyectColors.textPrimary)))),
            DataCell(Center(
                child: Text(item['nombre'],
                    style: TextStyle(color: ProyectColors.textPrimary)))),
            DataCell(Center(
                child: Text(item['familia'],
                    style: TextStyle(color: ProyectColors.textSecondary)))),
            DataCell(Center(
                child: Text(item['stock_actual'].toString(),
                    style: TextStyle(color: ProyectColors.textPrimary)))),
            DataCell(Center(
                child: Text(item['stock_minimo'].toString(),
                    style: TextStyle(color: ProyectColors.textPrimary)))),
            DataCell(Center(
                child: Text(item['proveedor'] ?? 'Sin proveedor',
                    style: TextStyle(color: ProyectColors.textPrimary)))),
            DataCell(Container(
              alignment: Alignment.center,
              height: 35,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: item['estado'] == 'Crítico'
                    ? ProyectColors.danger
                    : item['estado'] == 'Bajo'
                        ? ProyectColors.warning
                        : ProyectColors.primaryGreen,
                borderRadius: BorderRadius.circular(8),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  item['estado'],
                  style: const TextStyle(
                    color: ProyectColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )),
          ],
        );
      }).toList(),
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
        'proveedor': 'Proveedor 1',
      },
      {
        'clave': 'R-2',
        'nombre': 'Router TP-Link',
        'familia': 'Redes',
        'stock_actual': 3,
        'stock_minimo': 5,
        'disponible': true,
        'proveedor': 'Proveedor 2',
      },
      {
        'clave': 'E-1',
        'nombre': 'Arduino UNO',
        'familia': 'Electrónica',
        'stock_actual': 0,
        'stock_minimo': 15,
        'disponible': true,
        'proveedor': 'Proveedor 3',
      },
      {
        'clave': 'I-1',
        'nombre': 'Multímetro',
        'familia': 'Instrumentos',
        'stock_actual': 1,
        'stock_minimo': 3,
        'disponible': true,
        'proveedor': 'sin proveedor',
      },
      {
        'clave': 'I-2',
        'nombre': 'Osciloscopio',
        'familia': 'Instrumentos',
        'stock_actual': 0,
        'stock_minimo': 5,
        'disponible': true,
        'proveedor': 'Proveedor 4',
      },
      {
        'clave': 'E-2',
        'nombre': 'Resistencias',
        'familia': 'Electrónica',
        'stock_actual': 20,
        'stock_minimo': 10,
        'disponible': true,
        'proveedor': null,
      },
      {
        'clave': 'E-3',
        'nombre': 'Transistores',
        'familia': 'Electrónica',
        'stock_actual': 5,
        'stock_minimo': 10,
        'disponible': true,
        'proveedor': null,
      },
      {
        'clave': 'E-4',
        'nombre': 'Condensadores',
        'familia': 'Electrónica',
        'stock_actual': 0,
        'stock_minimo': 10,
        'disponible': true,
        'proveedor': null,
      },
      {
        'clave': 'E-5',
        'nombre': 'Diodos',
        'familia': 'Electrónica',
        'stock_actual': 0,
        'stock_minimo': 10,
        'disponible': true,
        'proveedor': null,
      },
      {
        'clave': 'E-6',
        'nombre': 'Transistores MOSFET',
        'familia': 'Electrónica',
        'stock_actual': 0,
        'stock_minimo': 10,
        'disponible': true,
        'proveedor': null,
      },
    ];
    // Actualizar el estado según el stock
    for (var item in temp) {
      int stockActual = item['stock_actual'];
      int stockMinimo = item['stock_minimo'];

      if (stockActual * 2 <= stockMinimo) {
        item['estado'] = 'Crítico';
      } else if (stockActual < stockMinimo) {
        item['estado'] = 'Bajo'; // amarillo
      } else {
        item['estado'] = 'Óptimo'; // verde
      }
    }

    // Filtrar según el filtro seleccionado
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
