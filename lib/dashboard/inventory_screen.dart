import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:base_de_datos_universal/colours/colours.dart';
import 'package:base_de_datos_universal/dashboard/menubar.dart' as custom_menu;
import 'package:base_de_datos_universal/dashboard/tabs/tables.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  bool _boolButton2 = false;

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

  final supabase = Supabase.instance.client;

  @override
  void initState() {
    if (!mounted) return;
    super.initState();
    _cargarTablaProvee(_boolButton2);
    _cargarTablaArticulos(_boolButton);
    _cargarDropProve();
    _cargraDropArt();
    _tabController = TabController(length: 2, vsync: this);
    _initAsync();
    _loadDrops();
  }

  Future<void> _initAsync() async {
    if (!mounted) return;
    await _cargraDropArt();
  }

  //Articulos
  Future<void> toggleArticuloDeshabilitado(String articuloId) async {
    try {
      final response = await supabase
          .from('Articulos')
          .select('deshabilitado')
          .eq('id', articuloId);
      print(response);

      if (response is List && response.isNotEmpty) {
        final Map<String, dynamic> articulo = response[0];
        final bool? estadoActual = articulo['deshabilitado'] as bool?;

        print('Estado actual: $estadoActual');

        if (estadoActual == null) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'El campo "deshabilitado" está vacío para el artículo con ID $articuloId.'),
            ),
          );
          return;
        }

        final bool nuevoEstado = !estadoActual;

        try {
          final updateResponse = await supabase
              .from('Articulos')
              .update({'deshabilitado': nuevoEstado})
              .eq('id', articuloId)
              .select();

          print('Update response: $updateResponse');

          if (!mounted) return;

          setState(() {
            _articulos.clear();
            _boolButton =
                nuevoEstado; // Actualiza el bool según el nuevo estado
            _cargarTablaArticulos(_boolButton);
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Artículo actualizado correctamente.'),
              duration: Duration(seconds: 2),
            ),
          );
        } catch (e) {
          print('Error al actualizar estado: $e');
        }
      } else {
        print('No se encontró el artículo con id $articuloId');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se encontró artículo con ID $articuloId.'),
          ),
        );
      }
    } catch (e) {
      print('Error al obtener el estado actual: $e');
    }
  }

  Future<void> _cargarTablaArticulos(bool tipo) async {
    if (!mounted) return;
    try {
      final response = await supabase.from('Articulos').select('''
    id, clave, nombre, codigo_barras, precio, cantidad_stock, deshabilitado,cantidad_min,
    marca_id(nombre),
    linea_id(nombre),
    familia_id(nombre),
    provee_id(nombre)
  ''');
      if (response == null) return;

      List<Map<String, dynamic>> temp =
          response.map<Map<String, dynamic>>((item) {
        return {
          'id': item['id'],
          'clave': item['clave'],
          'nombre': item['nombre'],
          'marca': item['marca_id']?['nombre'] ?? 'Sin marca',
          'linea': item['linea_id']?['nombre'] ?? 'Sin línea',
          'familia': item['familia_id']?['nombre'] ?? 'Sin familia',
          'proveedor': item['provee_id']?['nombre'] ?? 'Sin proveedor',
          'precio': item['precio'],
          'cantidad': item['cantidad_stock'],
          'codigo': item['codigo_barras'],
          'cantidadMin': item['cantidad_min'],
          'disponibilidad': item['deshabilitado'],
        };
      }).toList();

      // Filtro según disponibilidad
      temp = tipo
          ? temp.where((item) => item['disponibilidad'] == false).toList()
          : temp.where((item) => item['disponibilidad'] == true).toList();
      if (!mounted) return;
      setState(() {
        _articulos = temp;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> _cargraDropArt() async {
    if (!mounted) return;
    try {
      final familiasResponse = await supabase.from('Familia').select();
      final lineasResponse = await supabase.from('Linea').select();
      final marcasResponse = await supabase.from('Marca').select();
      if (!mounted) return;

      setState(() {
        _familias = familiasResponse
            .map((f) => {
                  'id': f['id'],
                  'name': f['nombre'],
                  'Prefijo': f['prefijo'],
                })
            .toList();

        _lineas = lineasResponse
            .map((l) => {
                  'id': l['id'],
                  'name': l['nombre'],
                })
            .toList();

        _marcas = marcasResponse
            .map((m) => {
                  'id': m['id'],
                  'name': m['nombre'],
                })
            .toList();
      });
    } catch (e) {
      print(e);
    }
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
              .contains(_busqueda.toLowerCase()) ||
          art['codigo']
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
  Future<void> _cargarTablaProvee(bool mostrarDeshabilitados) async {
    if (!mounted) return;
    try {
      final response = await supabase.from('Proveedores').select('''
    id,
    nombre,
    rubro,
    descripcion,
    codigo_sat,
    precios,
    deshabilitado,
    marca_id(nombre),
    linea_id(nombre),
    familia_id(nombre)
  ''');
      if (response == null) return;

      List<Map<String, dynamic>> temp = (response as List).map((item) {
        return {
          'id': item['id'],
          'nombre': item['nombre'] ?? 'Sin nombre',
          'rubro': item['rubro'] ?? '',
          'marca': item['marca_id']?['nombre'] ?? 'Sin marca',
          'familia': item['familia_id']?['name'] ?? 'Sin familia',
          'linea': item['linea_id']?['name'] ?? 'Sin línea',
          'descripcion': item['descripcion'] ?? '',
          'codigo_sat': item['codigo_sat']?.toString() ?? '',
          'precios_url': item['precios'] ?? '', // URL al PDF
          'disponibilidad': item['deshabilitado'], // true = disponible
        };
      }).toList();

      // Filtro según disponibilidad
      temp = mostrarDeshabilitados
          ? temp.where((item) => item['disponibilidad'] == false).toList()
          : temp.where((item) => item['disponibilidad'] == true).toList();
      if (!mounted) return;
      setState(() {
        _proveedores = temp;
      });
    } catch (e) {
      print(e);
    }
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

  Future<void> _cargarDropProve() async {
    if (!mounted) return;
    try {
      final familiasResponse =
          await supabase.from('Familia').select('id, nombre, prefijo');
      final lineasResponse = await supabase.from('Linea').select('id, nombre');
      final marcasResponse = await supabase.from('Marca').select('id, nombre');
      if (!mounted) return;
      setState(() {
        _familiasProv = familiasResponse
            .map<Map<String, dynamic>>((f) => {
                  'id': f['id'],
                  'name': f['nombre'],
                  'Prefijo': f['prefijo'],
                })
            .toList();

        _lineasProv = lineasResponse
            .map<Map<String, dynamic>>((l) => {
                  'id': l['id'],
                  'name': l['nombre'],
                })
            .toList();

        _marcasProv = marcasResponse
            .map<Map<String, dynamic>>((m) => {
                  'id': m['id'],
                  'name': m['nombre'],
                })
            .toList();
      });
    } catch (e) {
      print(e);
    }
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

  Future<void> toggleProveedorDeshabilitado(String proveedorId) async {
    try {
      final response = await supabase
          .from('Proveedores')
          .select('deshabilitado')
          .eq('id', proveedorId);
      print(response);

      if (response is List && response.isNotEmpty) {
        final Map<String, dynamic> proveedor = response[0];
        final bool? estadoActual = proveedor['deshabilitado'] as bool?;

        print('Estado actual: $estadoActual');

        if (estadoActual == null) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'El campo "deshabilitado" está vacío para el proveedor con ID $proveedorId.'),
              backgroundColor: Colors.orangeAccent,
            ),
          );
          return;
        }

        final bool nuevoEstado = !estadoActual;

        try {
          final updateResponse = await supabase
              .from('Proveedores')
              .update({'deshabilitado': nuevoEstado})
              .eq('id', proveedorId)
              .select();

          print('Update response: $updateResponse');

          if (!mounted) return;

          setState(() {
            _proveedores.clear();
            _boolButton2 = !estadoActual;
            _cargarTablaProvee(_boolButton2);
          });
          // Mostrar SnackBar confirmando la actualización
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Proveedor actualizado correctamente.'),
              duration: Duration(seconds: 2),
            ),
          );
        } catch (e) {
          print('Error al actualizar estado: $e');
        }
      } else {
        print('No se encontró el proveedor con id $proveedorId');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se encontró proveedor con ID $proveedorId.'),
          ),
        );
      }
    } catch (e) {
      print('Error al obtener el estado actual: $e');
    }
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
                              hintText:
                                  'Buscar por clave, nombre o codigo de barras...',
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
                                    const DropdownMenuItem<String>(
                                      value: 'Sin familia',
                                      child: Text('Sin familia'),
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
                                    const DropdownMenuItem<String>(
                                      value: 'Sin línea',
                                      child: Text('Sin línea'),
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
                                    const DropdownMenuItem<String>(
                                      value: 'Sin marca',
                                      child: Text('Sin marca'),
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
                                  style: TextButton.styleFrom(
                                      backgroundColor:
                                          ProyectColors.primaryGreen),
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
                                    color: ProyectColors.backgroundDark,
                                  ),
                                  label: Text(
                                    _boolButton
                                        ? 'Deshabilitados'
                                        : 'Habilitados',
                                    style: TextStyle(
                                      color: ProyectColors.backgroundDark,
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
                                onEditar: (index) async {
                                  final articulo = _articulosFiltrados[index];
                                  final articuloId = articulo['id']?.toString();

                                  if (articuloId != null &&
                                      articuloId.isNotEmpty) {
                                    await prepararEdicionArticulo(articuloId);
                                    editarArt(
                                      name: _name,
                                      barras: _barras,
                                      cantidad: _cantidad,
                                      cantidadmin: _cantidadmin,
                                      precio: _precio,
                                      selectedFamilia: _selectedFamilia,
                                      selectedLinea: _selectedLinea,
                                      selectedMarca: _selectedMarca,
                                      selectedProveedor: _selectedProveedor,
                                      context: context,
                                      id: articuloId,
                                      onGuardar: () async {
                                        await actualizarArticulo(articuloId);
                                      },
                                    );
                                  } else {
                                    print(
                                        'ID inválido para proveedor en index $index');
                                  }
                                },
                                onBorrar: (index) async {
                                  final articulo = _articulosFiltrados[index];
                                  final articuloId = articulo['id'].toString();
                                  if (articuloId != null) {
                                    setState(() {
                                      toggleArticuloDeshabilitado(articuloId);
                                    });
                                  } else {
                                    print(
                                        'ID inválido para proveedor en index $index');
                                  }
                                },
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
                                    const DropdownMenuItem<String>(
                                      value: 'Sin familia',
                                      child: Text('Sin familia'),
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
                                    const DropdownMenuItem<String>(
                                      value: 'Sin línea',
                                      child: Text('Sin línea'),
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
                                    const DropdownMenuItem<String>(
                                      value: 'Sin marca',
                                      child: Text('Sin marca'),
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
                                  style: TextButton.styleFrom(
                                      backgroundColor:
                                          ProyectColors.primaryGreen),
                                  onPressed: () {
                                    setState(() {
                                      _boolButton2 = !_boolButton2;
                                      _cargarTablaProvee(_boolButton2);
                                    });
                                  },
                                  icon: Icon(
                                    _boolButton
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: ProyectColors.backgroundDark,
                                  ),
                                  label: Text(
                                    _boolButton2
                                        ? 'Deshabilitados'
                                        : 'Habilitados',
                                    style: TextStyle(
                                      color: ProyectColors.backgroundDark,
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
                                  final proveedor =
                                      _proveedoresFiltrados[index];
                                  final proveedorId =
                                      proveedor['id'].toString();
                                  if (proveedorId != null) {
                                    setState(() {
                                      mostrarDialogActualizarProveedor(
                                          proveedor: _proveedores[index],
                                          context: context);
                                    });
                                  } else {
                                    print(
                                        'ID inválido para proveedor en index $index');
                                  }
                                },
                                onBorrar: (index) async {
                                  final proveedor =
                                      _proveedoresFiltrados[index];
                                  final proveedorId =
                                      proveedor['id'].toString();
                                  if (proveedorId != null) {
                                    if (!mounted) return;

                                    setState(() {
                                      toggleProveedorDeshabilitado(proveedorId);
                                    });
                                  } else {
                                    print(
                                        'ID inválido para proveedor en index $index');
                                  }
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

  final TextEditingController _name = TextEditingController();
  final TextEditingController _precio = TextEditingController();
  final TextEditingController _cantidad = TextEditingController();
  final TextEditingController _cantidadmin = TextEditingController();
  final TextEditingController _barras = TextEditingController();
  String? _selectedMarca;
  String? _selectedFamilia;
  String? _selectedLinea;
  String? _selectedProveedor;
  List<Map<String, dynamic>> _loadMarca = [];
  List<Map<String, dynamic>> _loadFamilia = [];
  List<Map<String, dynamic>> _loadLinea = [];
  List<Map<String, dynamic>> _loadProveedor = [];

  void editarArt(
      {required BuildContext context,
      required String id,
      required TextEditingController name,
      required TextEditingController precio,
      required TextEditingController cantidad,
      required TextEditingController cantidadmin,
      required TextEditingController barras,
      required String? selectedMarca,
      required String? selectedFamilia,
      required String? selectedLinea,
      required String? selectedProveedor,
      required Future<void> Function() onGuardar}) {
    showDialog(
      context: context,
      builder: (context) {
        String? _selectedMarcaLocal = selectedMarca;
        String? _selectedFamiliaLocal = selectedFamilia;
        String? _selectedLineaLocal = selectedLinea;
        String? _selectedProveedorLocal = selectedProveedor;

        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: ProyectColors.backgroundDark,
              insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: Container(
                width: 500,
                height: 500,
                padding: EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 24,
                      ),
                      TextField(
                        controller: name,
                        style:
                            const TextStyle(color: ProyectColors.textPrimary),
                        decoration: InputDecoration(
                          labelText: 'Nombre',
                          prefixIcon: Icon(Icons.label,
                              color: ProyectColors.primaryGreen),
                          labelStyle: const TextStyle(
                              color: ProyectColors.textSecondary),
                          filled: true,
                          fillColor: ProyectColors.surfaceDark,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: (_selectedMarcaLocal != null &&
                                      _loadMarca.any((e) =>
                                          e['id'].toString() ==
                                          _selectedMarcaLocal))
                                  ? _selectedMarcaLocal
                                  : null,
                              items: _loadMarca
                                  .map((item) => DropdownMenuItem<String>(
                                        value: item['id'].toString(),
                                        child: Text(item['nombre']),
                                      ))
                                  .toList(),
                              style: const TextStyle(
                                  color: ProyectColors.textPrimary),
                              dropdownColor: ProyectColors.surfaceDark,
                              decoration: InputDecoration(
                                labelText: 'Marca',
                                prefixIcon: Icon(Icons.business,
                                    color: ProyectColors.primaryGreen),
                                labelStyle: const TextStyle(
                                    color: ProyectColors.textSecondary),
                                filled: true,
                                fillColor: ProyectColors.surfaceDark,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              onChanged: (value) {
                                setState(() => _selectedMarcaLocal = value);
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: (_selectedLineaLocal != null &&
                                      _lineas.any((e) =>
                                          e['id'].toString() ==
                                          _selectedLineaLocal))
                                  ? _selectedLineaLocal
                                  : null,
                              items: _loadLinea
                                  .map((item) => DropdownMenuItem<String>(
                                        value: item['id'].toString(),
                                        child: Text(item['nombre']),
                                      ))
                                  .toList(),
                              style: const TextStyle(
                                  color: ProyectColors.textPrimary),
                              dropdownColor: ProyectColors.surfaceDark,
                              decoration: InputDecoration(
                                labelText: 'Línea',
                                prefixIcon: Icon(Icons.category,
                                    color: ProyectColors.primaryGreen),
                                labelStyle: const TextStyle(
                                    color: ProyectColors.textSecondary),
                                filled: true,
                                fillColor: ProyectColors.surfaceDark,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              onChanged: (value) {
                                setState(() => _selectedLineaLocal = value);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: (_selectedFamiliaLocal != null &&
                                      _familias.any((f) =>
                                          f['id'].toString() ==
                                          _selectedFamiliaLocal))
                                  ? _selectedFamiliaLocal
                                  : null,
                              items: _loadFamilia
                                  .map((item) => DropdownMenuItem<String>(
                                        value: item['id'].toString(),
                                        child: Text(item['nombre']),
                                      ))
                                  .toList(),
                              style: const TextStyle(
                                  color: ProyectColors.textPrimary),
                              dropdownColor: ProyectColors.surfaceDark,
                              decoration: InputDecoration(
                                labelText: 'Familia',
                                prefixIcon: Icon(Icons.group_work,
                                    color: ProyectColors.primaryGreen),
                                labelStyle: const TextStyle(
                                    color: ProyectColors.textSecondary),
                                filled: true,
                                fillColor: ProyectColors.surfaceDark,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              onChanged: (value) {
                                setState(() => _selectedFamiliaLocal = value);
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: (_selectedProveedorLocal != null &&
                                      _proveedores.any((p) =>
                                          p['id'].toString() ==
                                          _selectedProveedorLocal))
                                  ? _selectedProveedorLocal
                                  : null,
                              items: _loadProveedor
                                  .map((item) => DropdownMenuItem<String>(
                                        value: item['id'].toString(),
                                        child: Text(item['nombre']),
                                      ))
                                  .toList(),
                              style: const TextStyle(
                                  color: ProyectColors.textPrimary),
                              dropdownColor: ProyectColors.surfaceDark,
                              decoration: InputDecoration(
                                labelText: 'Proveedor',
                                prefixIcon: Icon(Icons.local_shipping,
                                    color: ProyectColors.primaryGreen),
                                labelStyle: const TextStyle(
                                    color: ProyectColors.textSecondary),
                                filled: true,
                                fillColor: ProyectColors.surfaceDark,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              onChanged: (value) {
                                setState(() => _selectedProveedorLocal = value);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: precio,
                              style: const TextStyle(
                                  color: ProyectColors.textPrimary),
                              decoration: InputDecoration(
                                labelText: 'Precio Unitario',
                                prefixIcon: Icon(Icons.attach_money,
                                    color: ProyectColors.primaryGreen),
                                labelStyle: const TextStyle(
                                    color: ProyectColors.textSecondary),
                                filled: true,
                                fillColor: ProyectColors.surfaceDark,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: cantidad,
                              style: const TextStyle(
                                  color: ProyectColors.textPrimary),
                              decoration: InputDecoration(
                                labelText: 'Cantidad Inicial',
                                prefixIcon: Icon(Icons.confirmation_number,
                                    color: ProyectColors.primaryGreen),
                                labelStyle: const TextStyle(
                                    color: ProyectColors.textSecondary),
                                filled: true,
                                fillColor: ProyectColors.surfaceDark,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: barras,
                        style:
                            const TextStyle(color: ProyectColors.textPrimary),
                        decoration: InputDecoration(
                          labelText: 'Código de barras',
                          prefixIcon: Icon(Icons.qr_code,
                              color: ProyectColors.primaryGreen),
                          labelStyle: const TextStyle(
                              color: ProyectColors.textSecondary),
                          filled: true,
                          fillColor: ProyectColors.surfaceDark,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: cantidadmin,
                        keyboardType: TextInputType.number,
                        style:
                            const TextStyle(color: ProyectColors.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Ej En Unidades. 10',
                          hintStyle: const TextStyle(
                              color: ProyectColors.textSecondary),
                          filled: true,
                          fillColor: ProyectColors.backgroundDark,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  ProyectColors.primaryGreen),
                            ),
                            child: const Text(
                              'Cancelar',
                              style: TextStyle(
                                  color: ProyectColors.backgroundDark),
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const SizedBox(width: 10),
                          TextButton(
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    ProyectColors.primaryGreen),
                              ),
                              child: const Text(
                                'Aceptar',
                                style: TextStyle(
                                    color: ProyectColors.backgroundDark),
                              ),
                              onPressed: () async {
                                if (name.text.trim().isEmpty ||
                                    precio.text.trim().isEmpty ||
                                    cantidad.text.trim().isEmpty ||
                                    cantidadmin.text.trim().isEmpty ||
                                    barras.text.trim().isEmpty ||
                                    _selectedMarcaLocal == null ||
                                    _selectedLineaLocal == null ||
                                    _selectedFamiliaLocal == null ||
                                    _selectedProveedorLocal == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'Por favor, completa todos los campos')),
                                  );
                                  return;
                                }

                                // Actualizar variables globales antes de guardar
                                _selectedMarca = _selectedMarcaLocal;
                                _selectedLinea = _selectedLineaLocal;
                                _selectedFamilia = _selectedFamiliaLocal;
                                _selectedProveedor = _selectedProveedorLocal;

                                await onGuardar();

                                Navigator.pop(context);
                              }),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _loadDrops() async {
    final responseLineas = await supabase.from('Linea').select('id, nombre');
    final responseFamilias =
        await supabase.from('Familia').select('id, nombre, prefijo');
    final responseMarcas = await supabase.from('Marca').select('id, nombre');
    final responseProveedores =
        await supabase.from('Proveedores').select('id, nombre');
    // Asegúrate de que las respuestas sean listas antes de asignarlas
    if (responseLineas is List &&
        responseFamilias is List &&
        responseMarcas is List &&
        responseProveedores is List) {
      if (!mounted) return;
      setState(() {
        _loadLinea = List<Map<String, dynamic>>.from(responseLineas);
        _loadFamilia = List<Map<String, dynamic>>.from(responseFamilias);
        _loadMarca = List<Map<String, dynamic>>.from(responseMarcas);
        _loadProveedor = List<Map<String, dynamic>>.from(responseProveedores);
      });
    } else {
      // Manejo de errores si alguna respuesta falla
      print('Error al cargar datos desde Supabase');
    }
  }

  Future<void> prepararEdicionArticulo(String id) async {
    try {
      final response = await supabase.from('Articulos').select('''
          nombre, codigo_barras, precio, cantidad_stock, cantidad_min,
          marca_id, linea_id, familia_id, provee_id
        ''').eq('id', id).single();

      if (response != null) {
        setState(() {
          _name.text = response['nombre'] ?? '';
          _barras.text = response['codigo_barras']?.toString() ?? '';
          _precio.text = response['precio']?.toString() ?? '';
          _cantidad.text = response['cantidad_stock']?.toString() ?? '';
          _cantidadmin.text = response['cantidad_min']?.toString() ?? '';

          _selectedMarca = response['marca_id'] != null
              ? response['marca_id'].toString()
              : null;
          _selectedLinea = response['linea_id'] != null
              ? response['linea_id'].toString()
              : null;
          _selectedFamilia = response['familia_id'] != null
              ? response['familia_id'].toString()
              : null;
          _selectedProveedor = response['provee_id'] != null
              ? response['provee_id'].toString()
              : null;
        });
      } else {
        print('No se encontró el artículo con id: $id');
      }
    } catch (e) {
      print('Error al cargar artículo: $e');
    }
  }

  Future<void> actualizarArticulo(String id) async {
    print('name: "${_name.text.trim()}"');
    print('barras: "${_barras.text.trim()}"');
    print('precio: "${_precio.text.trim()}"');
    print('cantidad: "${_cantidad.text.trim()}"');
    print('cantidadmin: "${_cantidadmin.text.trim()}"');
    print('marca: $_selectedMarca');
    print('linea: $_selectedLinea');
    print('familia: $_selectedFamilia');
    print('proveedor: $_selectedProveedor');

    try {
      if (_name.text.trim().isEmpty ||
          _barras.text.trim().isEmpty ||
          _precio.text.trim().isEmpty ||
          _cantidad.text.trim().isEmpty ||
          _cantidadmin.text.trim().isEmpty ||
          _selectedMarca == null ||
          _selectedMarca!.isEmpty ||
          _selectedLinea == null ||
          _selectedLinea!.isEmpty ||
          _selectedFamilia == null ||
          _selectedFamilia!.isEmpty ||
          _selectedProveedor == null ||
          _selectedProveedor!.isEmpty) {
        print('Error: Todos los campos deben estar llenados correctamente.');
        return;
      }
      final nuevoPrefijoFamilia =
          await _generarNuevoPrefijoFamilia(_selectedFamilia);

      final updates = {
        'nombre': _name.text.trim(),
        'codigo_barras': _barras.text.trim(),
        'precio': double.tryParse(_precio.text) ?? 0.0,
        'cantidad_stock': int.tryParse(_cantidad.text) ?? 0,
        'cantidad_min': int.tryParse(_cantidadmin.text) ?? 0,
        'marca_id': _selectedMarca ?? null,
        'linea_id': _selectedLinea ?? null,
        'familia_id': _selectedFamilia ?? null,
        'provee_id': _selectedProveedor ?? null,
        'clave': nuevoPrefijoFamilia,
      };
      print("newprefijo: $nuevoPrefijoFamilia");

      try {
        final response =
            await supabase.from('Articulos').update(updates).eq('id', id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Actualización completa')),
        );
        setState(() {
          _articulos.clear();
          _cargarTablaArticulos(_boolButton);
        });
      } catch (e) {
        print(e);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error en la actualización.')),
      );
      print('Error en la actualización: $e');
    }
  }

  Future<int> obtenerSiguienteNumeroFamilia(
      String familiaId, String basePrefijo) async {
    // Quitar guion al final si existe, para evitar dobles guiones
    final prefijoLimpio = basePrefijo.endsWith('-')
        ? basePrefijo.substring(0, basePrefijo.length - 1)
        : basePrefijo;

    final resultados = await supabase
        .from('Articulos')
        .select('clave')
        .eq('familia_id', familiaId);

    List<int> numerosUsados = [];

    if (resultados != null && resultados.isNotEmpty) {
      for (var item in resultados) {
        final clave = item['clave'];
        if (clave != null && clave.startsWith('$prefijoLimpio-')) {
          // Extraer todo lo que viene después del primer guion
          final indexGuion = clave.indexOf('-');
          if (indexGuion != -1 && indexGuion < clave.length - 1) {
            final parteNumero = clave.substring(indexGuion + 1);
            // Intentar parsear solo la parte numérica (puede haber más guiones)
            final numero = int.tryParse(parteNumero.split('-')[0]);
            if (numero != null) {
              numerosUsados.add(numero);
            }
          }
        }
      }
    }

    if (numerosUsados.isEmpty) return 1;

    return numerosUsados.reduce((a, b) => a > b ? a : b) + 1;
  }

  Future<String?> obtenerPrefijoBaseFamilia(String familiaId) async {
    final response = await supabase
        .from('Familia')
        .select('prefijo')
        .eq('id', familiaId)
        .single();

    if (response == null) return null;

    final basePrefijo = response['prefijo']?.toString();

    if (basePrefijo == null || basePrefijo.isEmpty) return null;

    return basePrefijo;
  }

  Future<String?> _generarNuevoPrefijoFamilia(String? familiaId) async {
    if (familiaId == null) return null;

    final basePrefijo = await obtenerPrefijoBaseFamilia(familiaId);
    if (basePrefijo == null) return null;

    final siguienteNumero =
        await obtenerSiguienteNumeroFamilia(familiaId, basePrefijo);

    return '$basePrefijo$siguienteNumero';
  }

////////////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////
  ///////////////////////////////////////////////////
  ///////////////////////////////////////////////////

  Future<List<Map<String, dynamic>>> obtenerProveedores() async {
    final supabase = Supabase.instance.client;
    final data = await supabase.from('Proveedores').select();
    return List<Map<String, dynamic>>.from(data);
  }

  void recargarProveedores() async {
    final nuevaLista = await obtenerProveedores();
    setState(() {
      _proveedores = nuevaLista;
    });
  }

  Future<void> mostrarDialogActualizarProveedor({
    required BuildContext context,
    required Map<String, dynamic> proveedor,
    //required VoidCallback onActualizado,
  }) async {
    final TextEditingController nombreCtrl =
        TextEditingController(text: proveedor['nombre']);
    final TextEditingController rubroCtrl =
        TextEditingController(text: proveedor['rubro']);
    final TextEditingController descripcionCtrl =
        TextEditingController(text: proveedor['descripcion'] ?? '');
    final TextEditingController codigoSatCtrl =
        TextEditingController(text: proveedor['codigo_sat']?.toString() ?? '');
    final TextEditingController archivoCtrl = TextEditingController();

    final supabase = Supabase.instance.client;

    File? archivoNuevo;
    String? nombreArchivo;

    // Dropdowns dinámicos
    List<Map<String, dynamic>> marcas = [];
    List<Map<String, dynamic>> familias = [];
    List<Map<String, dynamic>> lineas = [];

    String? marcaSeleccionada = proveedor['marca_id']?.toString();
    String? familiaSeleccionada = proveedor['familia_id']?.toString();
    String? lineaSeleccionada = proveedor['linea_id']?.toString();

    // Cargar opciones desde Supabase
    Future<void> cargarOpciones() async {
      marcas = List<Map<String, dynamic>>.from(
          await supabase.from('Marca').select('id, nombre'));
      familias = List<Map<String, dynamic>>.from(
          await supabase.from('Familia').select('id, nombre'));
      lineas = List<Map<String, dynamic>>.from(
          await supabase.from('Linea').select('id, nombre'));
    }

    await cargarOpciones();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Actualizar Proveedor'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                    controller: nombreCtrl,
                    decoration: const InputDecoration(labelText: 'Nombre')),
                TextField(
                    controller: rubroCtrl,
                    decoration: const InputDecoration(labelText: 'Rubro')),
                DropdownButtonFormField<String>(
                  value: marcaSeleccionada,
                  items: marcas.map((item) {
                    return DropdownMenuItem(
                        value: item['id'].toString(),
                        child: Text(item['nombre']));
                  }).toList(),
                  onChanged: (val) => marcaSeleccionada = val,
                  decoration: const InputDecoration(labelText: 'Marca'),
                ),
                DropdownButtonFormField<String>(
                  value: familiaSeleccionada,
                  items: familias.map((item) {
                    return DropdownMenuItem(
                        value: item['id'].toString(),
                        child: Text(item['nombre']));
                  }).toList(),
                  onChanged: (val) => familiaSeleccionada = val,
                  decoration: const InputDecoration(labelText: 'Familia'),
                ),
                DropdownButtonFormField<String>(
                  value: lineaSeleccionada,
                  items: lineas.map((item) {
                    return DropdownMenuItem(
                        value: item['id'].toString(),
                        child: Text(item['nombre']));
                  }).toList(),
                  onChanged: (val) => lineaSeleccionada = val,
                  decoration: const InputDecoration(labelText: 'Línea'),
                ),
                TextField(
                    controller: descripcionCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Descripción')),
                TextField(
                  controller: codigoSatCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Código SAT'),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () async {
                    FilePickerResult? result =
                        await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['pdf', 'jpg', 'png', 'docx'],
                    );
                    if (result != null && result.files.single.path != null) {
                      archivoNuevo = File(result.files.single.path!);
                      nombreArchivo = result.files.single.name;
                      archivoCtrl.text = nombreArchivo!;
                    }
                  },
                  child: AbsorbPointer(
                    child: TextField(
                      controller: archivoCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Seleccionar nuevo archivo'),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Subir archivo si hay uno nuevo
                String? nuevaUrl;
                if (archivoNuevo != null && nombreArchivo != null) {
                  final storage = supabase.storage.from('precios-provee');
                  await storage.upload(
                    nombreArchivo!, // <-- aquí
                    archivoNuevo!,
                    fileOptions: const FileOptions(upsert: true),
                  );
                  nuevaUrl = storage.getPublicUrl(nombreArchivo!); // <-- aquí
                }
                // Actualizar en Supabase
                await supabase.from('Proveedores').update({
                  'nombre': nombreCtrl.text,
                  'rubro': rubroCtrl.text,
                  'descripcion': descripcionCtrl.text,
                  'codigo_sat': int.tryParse(codigoSatCtrl.text),
                  'marca_id': int.tryParse(marcaSeleccionada ?? ''),
                  'familia_id': int.tryParse(familiaSeleccionada ?? ''),
                  'linea_id': int.tryParse(lineaSeleccionada ?? ''),
                  if (nuevaUrl != null) 'precios': nuevaUrl,
                }).eq('id', proveedor['id']);

                // onActualizado();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Proveedor actualizado exitosamente')),
                );
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }
}
