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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        loadTabla();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Determina cuántos cards por fila según el ancho de pantalla
    int cardsPerRow;
    if (screenWidth >= 1400) {
      cardsPerRow = 4;
    } else if (screenWidth >= 1100) {
      cardsPerRow = 2;
    } else {
      cardsPerRow = 1;
    }

    final cardData = [
      {'title': 'Empleados activos', 'value': EmpleadosActivos},
      {'title': 'Ventas del Dia', 'value': VentasDelDia},
      {'title': 'Productos Agotados', 'value': ProductosAgotados},
      {'title': 'Entradas Registradas', 'value': EntradasRegistradas},
    ];

    List<Widget> cardRows = [];
    for (int i = 0; i < cardData.length; i += cardsPerRow) {
      final rowCards = cardData
          .skip(i)
          .take(cardsPerRow)
          .map((data) => Flexible(
                flex: 1,
                child: _buildCard(data['title']!, data['value']!),
              ))
          .toList();
      cardRows.add(Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: rowCards,
      ));
      cardRows.add(const SizedBox(height: 16));
    }

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
                      ...cardRows,
                      const SizedBox(height: 16),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        // Define el número de columnas
        int columnCount = 7;
        // Deja un pequeño margen para el borde y padding
        double columnWidth = (constraints.maxWidth - 2) / columnCount;
        // Ajusta el ancho para la columna state
        double stateColumnWidth = 100; 
        

        return SizedBox(
          width: double.infinity,
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
                  child: SingleChildScrollView(
                    controller: _horizontalTableScrollController,
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: constraints.maxWidth,
                        maxWidth: constraints.maxWidth,
                      ),
                      child: DataTable(
                        showCheckboxColumn: false,
                        dataRowHeight: 70,
                        headingRowHeight: 60,
                        columnSpacing: 0,
                        dividerThickness: 1,
                        headingRowColor:
                            WidgetStateProperty.all(ProyectColors.primaryGreen),
                        columns: [
                          DataColumn(
                              label: SizedBox(
                                width: columnWidth,
                                child: Center(
                                  child: Text('Clave',
                                      style: TextStyle(
                                          color: ProyectColors.textPrimary)),
                                ),
                              )),
                          DataColumn(
                              label: SizedBox(
                                width: columnWidth,
                                child: Center(
                                  child: Text('Producto',
                                      style: TextStyle(
                                          color: ProyectColors.textPrimary)),
                                ),
                              )),
                          DataColumn(
                              label: SizedBox(
                                width: columnWidth,
                                child: Center(
                                  child: Text('Familia',
                                      style: TextStyle(
                                          color: ProyectColors.textPrimary)),
                                ),
                              )),
                          DataColumn(
                              label: SizedBox(
                                width: columnWidth,
                                child: Center(
                                  child: Text('Stock actual',
                                      style: TextStyle(
                                          color: ProyectColors.textPrimary)),
                                ),
                              )),
                          DataColumn(
                              label: SizedBox(
                                width: columnWidth,
                                child: Center(
                                  child: Text('Stock mínimo',
                                      style: TextStyle(
                                          color: ProyectColors.textPrimary)),
                                ),
                              )),
                          DataColumn(
                              label: SizedBox(
                                width: columnWidth,
                                child: Center(
                                  child: Text('Proveedor',
                                      style: TextStyle(
                                          color: ProyectColors.textPrimary)),
                                ),
                              )),
                          DataColumn(
                              label: SizedBox(
                                width: stateColumnWidth,
                                child: Center(
                                  child: Text('Estado',
                                      style: TextStyle(
                                          color: ProyectColors.textPrimary)),
                                ),
                              )),
                        ],
                        rows: [
                          for (var item in LoadTablaTodo)
                            DataRow(
                              cells: [
                                DataCell(SizedBox(
                                  width: columnWidth,
                                  child: Center(
                                    child: Text(item['clave'],
                                        style: const TextStyle(
                                            color: ProyectColors.textPrimary)),
                                  ),
                                )),
                                DataCell(SizedBox(
                                  width: columnWidth,
                                  child: Center(
                                    child: Text(item['nombre'],
                                        style: const TextStyle(
                                            color: ProyectColors.textPrimary)),
                                  ),
                                )),
                                DataCell(SizedBox(
                                  width: columnWidth,
                                  child: Center(
                                    child: Text(item['familia'],
                                        style: const TextStyle(
                                            color: ProyectColors.textSecondary)),
                                  ),
                                )),
                                DataCell(SizedBox(
                                  width: columnWidth,
                                  child: Center(
                                    child: Text(item['stock_actual'].toString(),
                                        style: const TextStyle(
                                            color: ProyectColors.textPrimary)),
                                  ),
                                )),
                                DataCell(SizedBox(
                                  width: columnWidth,
                                  child: Center(
                                    child: Text(item['stock_minimo'].toString(),
                                        style: const TextStyle(
                                            color: ProyectColors.textPrimary)),
                                  ),
                                )),
                                DataCell(SizedBox(
                                  width: columnWidth,
                                  child: Center(
                                    child: Text(item['proveedor'] ?? 'Sin proveedor',
                                        style: const TextStyle(
                                            color: ProyectColors.textPrimary)),
                                  ),
                                )),
                                DataCell(SizedBox(
                                  width: stateColumnWidth,
                                  child: Container(
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
                                        style: TextStyle(
                                          color: ProyectColors.textPrimary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                )),
                              ],
                            ),
                        ],
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
