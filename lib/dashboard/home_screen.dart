import 'package:flutter/material.dart';
import 'package:base_de_datos_universal/colours/colours.dart';
import 'package:base_de_datos_universal/dashboard/menubar.dart' as custom_menu;
import 'package:supabase_flutter/supabase_flutter.dart';

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
  List<String> correos = [];
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
  int EmpleadosActivos = 0;
  int VentasDelDia = 0;
  int ProductosAgotados = 0;
  String EntradasRegistradas = 10.toString();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        if (!mounted) return;
        loadTabla();
        empleados();
        ventasDelDia();
        productosAgotados();
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
                          _buildCard(
                              'Empleados activos', EmpleadosActivos.toString()),
                          _buildCard('Ventas del día', VentasDelDia.toString()),
                          _buildCard(
                              'Entradas registradas', EntradasRegistradas),
                          _buildCard('Productos agotados',
                              ProductosAgotados.toString()),
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
                                    todosAct();
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

  Future<void> empleados() async {
    final supabase = Supabase.instance.client;

    try {
      final response = await supabase.from('Usuarios').select('correo');

      if (response is List) {
        List<String> correos = [];

        for (var item in response) {
          if (item['correo'] != null) {
            correos.add(item['correo']);
          }
        }

        setState(() {
          EmpleadosActivos = correos.length;
        });
      } else {
        print('Error al obtener empleados: $response');
      }
    } catch (e) {
      print('Excepción: $e');
    }
  }

  Future<void> ventasDelDia() async {
    final supabase = Supabase.instance.client;

    // Obtener la fecha actual en formato YYYY-MM-DD
    final String hoy = DateTime.now().toIso8601String().substring(0, 10);

    try {
      final response = await supabase
          .from('Ventas')
          .select('id') // Solo necesitamos contar los registros
          .eq('dia', hoy); // Filtrar por la fecha de hoy

      if (response is List) {
        setState(() {
          VentasDelDia = response.length;
        });
      } else {
        print('Error al obtener ventas del día: $response');
      }
    } catch (e) {
      print('Excepción en ventasDelDia: $e');
    }
  }

  Future<void> productosAgotados() async {
    final supabase = Supabase.instance.client;

    try {
      final response = await supabase
          .from('Articulos')
          .select('id')
          .eq('cantidad_stock', 0)
          .eq('deshabilitado', true); // Solo productos activos

      if (response is List) {
        setState(() {
          ProductosAgotados = response.length;
        });
      } else {
        print('Error al obtener productos agotados: $response');
      }
    } catch (e) {
      print('Excepción en productosAgotados: $e');
    }
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
      headingRowColor: WidgetStateProperty.all(ProyectColors.primaryGreen),
      dataRowColor: WidgetStateProperty.all(ProyectColors.surfaceDark),
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

  Future<void> loadTabla() async {
    final supabase = Supabase.instance.client;

    final response = await supabase.from('Articulos').select(
        'clave, nombre, cantidad_stock, cantidad_min, deshabilitado, Familia(nombre), Proveedores(nombre), Marca(nombre), Linea(nombre)');

    if (response is List) {
      List<Map<String, dynamic>> temp = [];

      for (var item in response) {
        final int stockActual = item['cantidad_stock'] ?? 0;
        final int stockMinimo = item['cantidad_min'] ?? 1;

        String estado;
        if (stockActual * 2 <= stockMinimo) {
          estado = 'Crítico';
        } else if (stockActual < stockMinimo) {
          estado = 'Bajo';
        } else {
          estado = 'Óptimo';
        }

        temp.add({
          'clave': item['clave'],
          'nombre': item['nombre'],
          'familia': item['Familia']?['nombre'] ?? 'Sin familia',
          'stock_actual': stockActual,
          'stock_minimo': stockMinimo,
          'disponible': item['deshabilitado'] ?? false,
          'proveedor': item['Proveedores']?['nombre'] ?? 'sin proveedor',
          'estado': estado,
        });
      }
      // Filtro:
      switch (selectedFilter) {
        case 'Todos':
          temp = temp
              .where((item) =>
                  item['disponible'] == true && item['estado'] != 'Óptimo')
              .toList();
          break;
        case 'Stock bajo':
          temp = temp
              .where((item) =>
                  item['disponible'] == true && (item['estado'] == 'Bajo'))
              .toList();
          break;
        case 'Agotados':
          temp = temp
              .where((item) =>
                  item['disponible'] == true && item['stock_actual'] == 0)
              .toList();
          break;
      }
      if (!mounted) return;
      setState(() {
        LoadTablaTodo = temp;
      });
    } else {
      print('Error al obtener datos: $response');
    }
  }

  void todosAct() {
    loadTabla();
    if (!mounted) return;
    setState(() {
      LoadTablaTodo = LoadTablaTodo.where((item) =>
          item['disponible'] == true && item['estado'] != 'Óptimo').toList();
    });
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
