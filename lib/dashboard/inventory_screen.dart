import 'package:flutter/material.dart';
import 'package:base_de_datos_universal/colours/colours.dart';
import 'package:base_de_datos_universal/dashboard/menubar.dart' as custom_menu;
import 'package:base_de_datos_universal/dashboard/tabs/tables.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  //controllers y variables unicas
  bool _scrollInTable = false;
  bool _scrollInTable2 = false;
  bool _boolButton = false;
  final bool _boolButton2 = false;

  //Listas Dinamicas
  List<Map<String, dynamic>> _articulos = [];
  List<Map<String, dynamic>> _proveedores = [];

  ////////////////////////////////////////////////////////////////////////////////////////////////
  //////////////////////////////////////////Articulos/////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////
  List<Map<String, dynamic>> _familias = [];
  List<Map<String, dynamic>> _lineas = [];
  List<Map<String, dynamic>> _marcas = [];

  String? _filtroFamilia = 'Todas';
  String? _filtroLinea = 'Todas';
  String? _filtroMarca = 'Todas';
  String _busqueda = '';
  ////////////////////////////////////////////////////////////////////////////////////////////////
  //////////////////////////////////////////Proveedores///////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////
  List<Map<String, dynamic>> _familiasProv = [];
  List<Map<String, dynamic>> _lineasProv = [];
  List<Map<String, dynamic>> _marcasProv = [];

  String? _filtroFamiliaProv = 'Todas';
  String? _filtroMarcaProv = 'Todas';
  String? _filtroLineasProv = 'Todas';
  String _busquedaProveedor = '';

  @override
  void initState() {
    super.initState();
    _cargarTablaArticulos(_boolButton);
    _cargarTablaProvee(_boolButton2);
    _cargarDropProve();
    _cargraDropArt();
    _tabController = TabController(length: 2, vsync: this); // Solo 2 tabs
  }

  //Articulos
  void _borrarArticulo(int index) {
    setState(() {
      _articulos.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Artículo eliminado')),
    );
  }

  void _editarArticulo(int index) {
    // Aquí puedes abrir un diálogo o navegar a una pantalla de edición
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Todavia no la hago')),
    );
  }

  void _cargarTablaArticulos(bool tipo) {
    List<Map<String, dynamic>> temp = [
      {
        'clave': 'L-1',
        'nombre': 'Cable UTP',
        'marca': 'Marca 1',
        'linea': 'Línea 1',
        'familia': 'Familia 2',
        'proveedor': 'Proveedor 1',
        'precio': 50.0,
        'cantidad': 100,
        'codigo': '1234567890',
        'disponibilidad': true
      },
      {
        'clave': 'L-1',
        'nombre': 'Cable UTP',
        'marca': 'Marca 1',
        'linea': 'Línea 1',
        'familia': 'Familia 1',
        'proveedor': 'Proveedor 1',
        'precio': 50.0,
        'cantidad': 100,
        'codigo': '1234567890',
        'disponibilidad': true
      },
      {
        'clave': 'G-2',
        'nombre': 'Router TP-Link',
        'familia': 'Familia 2',
        'marca': 'Marca 2',
        'linea': 'Línea 2',
        'proveedor': 'Proveedor 2',
        'precio': 800.0,
        'cantidad': 20,
        'codigo': '0987654321',
        'disponibilidad': false
      },
    ];
    String bool = tipo.toString();
    // Filtrar según el filtro seleccionado
    switch (bool) {
      case 'false':
        temp = temp.where((item) => item['disponibilidad'] == true).toList();
        break;
      case 'true':
        temp = temp.where((item) => item['disponibilidad'] == false).toList();
        break;
    }
    _articulos = temp;
  }

  void _cargraDropArt() async {
    _familias = [
      {'id': 1, 'name': 'Familia 1', 'Prefijo': 'L-'},
      {'id': 2, 'name': 'Familia 2', 'Prefijo': 'G-'},
      {'id': 3, 'name': 'Familia 3', 'Prefijo': 'H-'}
    ];
    _lineas = [
      {'id': 1, 'name': 'Línea 1'},
    ];
    _marcas = [
      {'id': 1, 'name': 'Marca 1'},
    ];
  }

  List<Map<String, dynamic>> get _articulosFiltrados {
    return _articulos.where((art) {
      final coincideFamilia =
          _filtroFamilia == 'Todas' || art['familia'] == _filtroFamilia;
      final coincideLinea =
          _filtroLinea == 'Todas' || art['linea'] == _filtroLinea;
      final coincideMarca =
          _filtroMarca == 'Todas' || art['marca'] == _filtroMarca;
      final coincideBusqueda = _busqueda.isEmpty ||
          art['nombre']
              .toString()
              .toLowerCase()
              .contains(_busqueda.toLowerCase()) ||
          art['clave']
              .toString()
              .toLowerCase()
              .contains(_busqueda.toLowerCase());
      return coincideFamilia &&
          coincideLinea &&
          coincideMarca &&
          coincideBusqueda;
    }).toList();
  }

  //Proveedores
  void _cargarTablaProvee(bool prove) {
    List<Map<String, dynamic>> temp = [
      {
        'nombre': 'Proveedor 1',
        'rubro': 'Eléctrico',
        'marca': 'Marca 1',
        'familia': 'Familia 1',
        'linea': 'Línea 1',
        'descripcion': 'Proveedor de materiales eléctricos y electrónicos.',
        'codigo_sat': '123456',
        'precios_url': 'https://ejemplo.com/precios1.pdf',
        'disponibilidad': true
      },
      {
        'nombre': 'Proveedor 2',
        'rubro': 'Electrónica',
        'marca': 'Marca 2',
        'familia': 'Familia 2',
        'linea': 'Línea 2',
        'descripcion':
            'Proveedor de materiales electrónicos y de alta tecnología.',
        'codigo_sat': '098765',
        'precios_url': 'https://ejemplo.com/precios2.pdf',
        'disponibilidad': false
      }
    ];
    String bool = prove.toString();
    // Filtrar según el filtro seleccionado
    switch (bool) {
      case 'false':
        temp = temp.where((item) => item['disponibilidad'] == true).toList();
        break;
      case 'true':
        temp = temp.where((item) => item['disponibilidad'] == false).toList();
        break;
    }
    _proveedores = temp;
  }

  void _verDescripcion(String descripcion) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ProyectColors.surfaceDark,
        title: const Text('Descripción',
            style: TextStyle(color: ProyectColors.primaryGreen)),
        content: Text(descripcion,
            style: const TextStyle(color: ProyectColors.textPrimary)),
        actions: [
          TextButton(
            child: const Text('Cerrar',
                style: TextStyle(color: ProyectColors.primaryGreen)),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void _descargarPrecios(String url) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Descargando catálogo de precios: $url')),
    );
  }

  void _cargarDropProve() {
    _familiasProv = [
      {'id': 1, 'name': 'Familia 1', 'Prefijo': 'L-'},
      {'id': 2, 'name': 'Familia 2', 'Prefijo': 'G-'},
      {'id': 3, 'name': 'Familia 3', 'Prefijo': 'H-'}
    ];
    _lineasProv = [
      {'id': 1, 'name': 'Línea 1'},
    ];
    _marcasProv = [
      {'id': 1, 'name': 'Marca 1'},
    ];
  }

  List<Map<String, dynamic>> get _proveedoresFiltrados {
    return _proveedores.where((prov) {
      final coincideFamilia = _filtroFamiliaProv == 'Todas' ||
          prov['familia'] == _filtroFamiliaProv;
      final coincideMarca =
          _filtroMarcaProv == 'Todas' || prov['marca'] == _filtroMarcaProv;
      final coincideLinea =
          _filtroLineasProv == 'Todas' || prov['linea'] == _filtroLinea;
      final coincideBusqueda = _busquedaProveedor.isEmpty ||
          (prov['nombre']
                  ?.toString()
                  .toLowerCase()
                  .contains(_busquedaProveedor.toLowerCase()) ??
              false) ||
          (prov['rubro']
                  ?.toString()
                  .toLowerCase()
                  .contains(_busquedaProveedor.toLowerCase()) ??
              false);
      return coincideFamilia &&
          coincideMarca &&
          coincideBusqueda &&
          coincideLinea;
    }).toList();
  }

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
          Expanded(
            child: DefaultTabController(
              length: 2, // Solo 2 tabs
              child: Scaffold(
                backgroundColor: ProyectColors.surfaceDark,
                appBar: AppBar(
                  automaticallyImplyLeading: false,
                  backgroundColor: ProyectColors.backgroundDark,
                  elevation: 0,
                  title: const Text('Inventario',
                      style: TextStyle(color: ProyectColors.textPrimary)),
                  bottom: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    indicatorColor: ProyectColors.primaryGreen,
                    labelColor: ProyectColors.primaryGreen,
                    unselectedLabelColor: ProyectColors.textSecondary,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 24),
                    tabs: const [
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inventory_2, size: 20),
                            SizedBox(width: 8),
                            Text('Artículos'),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.local_shipping, size: 20),
                            SizedBox(width: 8),
                            Text('Proveedores'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                body: TabBarView(
                  controller: _tabController,
                  children: [
                    // TAB 1: Artículos
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            style: const TextStyle(
                                color: ProyectColors.textPrimary),
                            decoration: InputDecoration(
                              hintText: 'Buscar por clave o nombre...',
                              hintStyle: const TextStyle(
                                  color: ProyectColors.textSecondary),
                              prefixIcon: Icon(Icons.search,
                                  color: ProyectColors.primaryGreen),
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
                          const SizedBox(height: 24),
                          // Barra de búsqueda y filtros
                          Row(
                            spacing: 12,
                            children: [
                              // Filtro Familia
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _filtroFamilia, // Puede ser null
                                  items: [
                                    DropdownMenuItem<String>(
                                      value:
                                          'Todas', // Representa la opción "Todas"
                                      child: Text(
                                        'Todas',
                                        style: TextStyle(
                                            fontStyle: FontStyle
                                                .italic), // opcional: destacar visualmente
                                      ),
                                    ),
                                    ..._familias
                                        .map((item) => DropdownMenuItem<String>(
                                              value: item['id'].toString(),
                                              child: Text(item['name']),
                                            )),
                                  ],
                                  style: const TextStyle(
                                    color: ProyectColors.textPrimary,
                                  ),
                                  dropdownColor: ProyectColors.surfaceDark,
                                  decoration: InputDecoration(
                                    labelText: 'Familia',
                                    labelStyle: const TextStyle(
                                      color: ProyectColors.textSecondary,
                                    ),
                                    filled: true,
                                    fillColor: ProyectColors.surfaceDark,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      _filtroFamilia = value;
                                      print(_filtroFamilia);
                                    });
                                  },
                                ),
                              ),
                              // Filtro Línea
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _filtroLinea, // Puede ser null
                                  items: [
                                    DropdownMenuItem<String>(
                                      value:
                                          'Todas', // Representa la opción "Todas"
                                      child: Text(
                                        'Todas',
                                        style: TextStyle(
                                            fontStyle: FontStyle
                                                .italic), // opcional: destacar visualmente
                                      ),
                                    ),
                                    ..._lineas
                                        .map((item) => DropdownMenuItem<String>(
                                              value: item['id'].toString(),
                                              child: Text(item['name']),
                                            )),
                                  ],
                                  style: const TextStyle(
                                    color: ProyectColors.textPrimary,
                                  ),
                                  dropdownColor: ProyectColors.surfaceDark,
                                  decoration: InputDecoration(
                                    labelText: 'Linea',
                                    labelStyle: const TextStyle(
                                      color: ProyectColors.textSecondary,
                                    ),
                                    filled: true,
                                    fillColor: ProyectColors.surfaceDark,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      _filtroLinea = value;
                                      print(_filtroLinea);
                                    });
                                  },
                                ),
                              ),
                              // Filtro Marca
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _filtroMarca, // Puede ser null
                                  items: [
                                    DropdownMenuItem<String>(
                                      value:
                                          'Todas', // Representa la opción "Todas"
                                      child: Text(
                                        'Todas',
                                        style: TextStyle(
                                            fontStyle: FontStyle
                                                .italic), // opcional: destacar visualmente
                                      ),
                                    ),
                                    ..._marcas
                                        .map((item) => DropdownMenuItem<String>(
                                              value: item['id'].toString(),
                                              child: Text(item['name']),
                                            )),
                                  ],
                                  style: const TextStyle(
                                    color: ProyectColors.textPrimary,
                                  ),
                                  dropdownColor: ProyectColors.surfaceDark,
                                  decoration: InputDecoration(
                                    labelText: 'Marca',
                                    labelStyle: const TextStyle(
                                      color: ProyectColors.textSecondary,
                                    ),
                                    filled: true,
                                    fillColor: ProyectColors.surfaceDark,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      _filtroMarca = value;
                                      print(_filtroMarca);
                                    });
                                  },
                                ),
                              ),
                              Expanded(
                                child: TextButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      _boolButton = !_boolButton;
                                      _cargarTablaArticulos(_boolButton);
                                    });
                                  },
                                  icon: Icon(
                                    _boolButton
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: ProyectColors.textPrimary,
                                  ),
                                  label: Text(
                                    _boolButton
                                        ? 'Deshabilitados'
                                        : 'Habilitados',
                                    style: TextStyle(
                                      color: ProyectColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Tabla de artículos
                          Expanded(
                            child: MouseRegion(
                              onEnter: (_) =>
                                  setState(() => _scrollInTable = true),
                              onExit: (_) =>
                                  setState(() => _scrollInTable = false),
                              child: ArticulosTable(
                                scrollable: _scrollInTable,
                                articulos: _articulosFiltrados,
                                onEditar: _editarArticulo,
                                onBorrar: _borrarArticulo,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////Proveedores////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                    // TAB 2: Proveedores
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Buscador de proveedores
                          TextField(
                            style: const TextStyle(
                                color: ProyectColors.textPrimary),
                            decoration: InputDecoration(
                              hintText:
                                  'Buscar proveedor por nombre o rubro...',
                              hintStyle: const TextStyle(
                                  color: ProyectColors.textSecondary),
                              prefixIcon: Icon(Icons.search,
                                  color: ProyectColors.primaryGreen),
                              filled: true,
                              fillColor: ProyectColors.surfaceDark,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _busquedaProveedor = value;
                              });
                            },
                          ),
                          const SizedBox(height: 24),
                          // Filtros de familia y marca
                          Row(
                            spacing: 16,
                            children: [
                              //Familia
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _filtroFamiliaProv, // Puede ser null
                                  items: [
                                    DropdownMenuItem<String>(
                                      value:
                                          'Todas', // Representa la opción "Todas"
                                      child: Text(
                                        'Todas',
                                        style: TextStyle(
                                            fontStyle: FontStyle
                                                .italic), // opcional: destacar visualmente
                                      ),
                                    ),
                                    ..._familiasProv
                                        .map((item) => DropdownMenuItem<String>(
                                              value: item['id'].toString(),
                                              child: Text(item['name']),
                                            )),
                                  ],
                                  style: const TextStyle(
                                    color: ProyectColors.textPrimary,
                                  ),
                                  dropdownColor: ProyectColors.surfaceDark,
                                  decoration: InputDecoration(
                                    labelText: 'Familia',
                                    labelStyle: const TextStyle(
                                      color: ProyectColors.textSecondary,
                                    ),
                                    filled: true,
                                    fillColor: ProyectColors.surfaceDark,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      _filtroFamiliaProv = value;
                                      print(_filtroFamiliaProv);
                                    });
                                  },
                                ),
                              ),
                              //Linea
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _filtroLineasProv, // Puede ser null
                                  items: [
                                    DropdownMenuItem<String>(
                                      value:
                                          'Todas', // Representa la opción "Todas"
                                      child: Text(
                                        'Todas',
                                        style: TextStyle(
                                            fontStyle: FontStyle
                                                .italic), // opcional: destacar visualmente
                                      ),
                                    ),
                                    ..._lineasProv
                                        .map((item) => DropdownMenuItem<String>(
                                              value: item['id'].toString(),
                                              child: Text(item['name']),
                                            )),
                                  ],
                                  style: const TextStyle(
                                    color: ProyectColors.textPrimary,
                                  ),
                                  dropdownColor: ProyectColors.surfaceDark,
                                  decoration: InputDecoration(
                                    labelText: 'Linea',
                                    labelStyle: const TextStyle(
                                      color: ProyectColors.textSecondary,
                                    ),
                                    filled: true,
                                    fillColor: ProyectColors.surfaceDark,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      _filtroLineasProv = value;
                                      print(_filtroLineasProv);
                                    });
                                  },
                                ),
                              ),
                              //Marca
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _filtroMarcaProv, // Puede ser null
                                  items: [
                                    DropdownMenuItem<String>(
                                      value:
                                          'Todas', // Representa la opción "Todas"
                                      child: Text(
                                        'Todas',
                                        style: TextStyle(
                                            fontStyle: FontStyle
                                                .italic), // opcional: destacar visualmente
                                      ),
                                    ),
                                    ..._marcasProv
                                        .map((item) => DropdownMenuItem<String>(
                                              value: item['id'].toString(),
                                              child: Text(item['name']),
                                            )),
                                  ],
                                  style: const TextStyle(
                                    color: ProyectColors.textPrimary,
                                  ),
                                  dropdownColor: ProyectColors.surfaceDark,
                                  decoration: InputDecoration(
                                    labelText: 'Marca',
                                    labelStyle: const TextStyle(
                                      color: ProyectColors.textSecondary,
                                    ),
                                    filled: true,
                                    fillColor: ProyectColors.surfaceDark,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      _filtroMarcaProv = value;
                                      print(_filtroMarcaProv);
                                    });
                                  },
                                ),
                              ),
                              //Button
                              Expanded(
                                child: TextButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      _boolButton = !_boolButton;
                                      _cargarTablaProvee(_boolButton);
                                    });
                                  },
                                  icon: Icon(
                                    _boolButton
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: ProyectColors.textPrimary,
                                  ),
                                  label: Text(
                                    _boolButton
                                        ? 'Deshabilitados'
                                        : 'Habilitados',
                                    style: TextStyle(
                                      color: ProyectColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Tabla de proveedores
                          Expanded(
                            child: MouseRegion(
                              onEnter: (_) =>
                                  setState(() => _scrollInTable2 = true),
                              onExit: (_) =>
                                  setState(() => _scrollInTable2 = false),
                              child: ProveedoresTable(
                                proveedores: _proveedoresFiltrados,
                                onEditar: (index) {
                                  // Implementa tu lógica de edición aquí
                                },
                                onBorrar: (index) {
                                  setState(() {
                                    _proveedores.removeAt(index);
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Proveedor eliminado')),
                                  );
                                },
                                onVerDescripcion: _verDescripcion,
                                onDescargarPrecios: _descargarPrecios,
                                scrollable: _scrollInTable2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
