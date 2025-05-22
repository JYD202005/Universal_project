import 'package:flutter/material.dart';
import 'package:base_de_datos_universal/colours/colours.dart';
import 'package:base_de_datos_universal/dashboard/menubar.dart' as custom_menu;
import 'package:base_de_datos_universal/dashboard/tabs/tables.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Simulación de datos
  final List<Map<String, dynamic>> _articulos = [
    {
      'clave': 'L-1',
      'nombre': 'Cable UTP',
      'familia': 'Familia 1',
      'marca': 'Marca 1',
      'linea': 'Línea 1',
      'proveedor': 'Proveedor 1',
      'precio': 50.0,
      'cantidad': 100,
      'codigo': '1234567890'
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
      'codigo': '0987654321'
    },
    // ...más artículos
  ];

  final List<Map<String, dynamic>> _proveedores = [
    {
      'nombre': 'Proveedor 1',
      'rubro': 'Eléctrico',
      'marca': 'Marca 1',
      'familia': 'Familia 1',
      'linea': 'Línea 1',
      'descripcion': 'Proveedor de materiales eléctricos y electrónicos.',
      'codigo_sat': '123456',
      'precios_url': 'https://ejemplo.com/precios1.pdf',
    },
    // ...más proveedores
  ];

  // Filtros simulados
  final List<String> _familias = ['Todas', 'Familia 1', 'Familia 2', 'Familia 3'];
  final List<String> _lineas = ['Todas', 'Línea 1', 'Línea 2', 'Línea 3'];
  final List<String> _marcas = ['Todas', 'Marca 1', 'Marca 2', 'Marca 3'];

  final List<String> _familiasProv = ['Todas', 'Familia 1', 'Familia 2'];
  final List<String> _marcasProv = ['Todas', 'Marca 1', 'Marca 2'];

  String _filtroFamilia = 'Todas';
  String _filtroLinea = 'Todas';
  String _filtroMarca = 'Todas';
  String _busqueda = '';

  String _filtroFamiliaProv = 'Todas';
  String _filtroMarcaProv = 'Todas';
  String _busquedaProveedor = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // Solo 2 tabs
  }

  List<Map<String, dynamic>> get _articulosFiltrados {
    return _articulos.where((art) {
      final coincideFamilia = _filtroFamilia == 'Todas' || art['familia'] == _filtroFamilia;
      final coincideLinea = _filtroLinea == 'Todas' || art['linea'] == _filtroLinea;
      final coincideMarca = _filtroMarca == 'Todas' || art['marca'] == _filtroMarca;
      final coincideBusqueda = _busqueda.isEmpty ||
          art['nombre'].toString().toLowerCase().contains(_busqueda.toLowerCase()) ||
          art['clave'].toString().toLowerCase().contains(_busqueda.toLowerCase());
      return coincideFamilia && coincideLinea && coincideMarca && coincideBusqueda;
    }).toList();
  }

  List<Map<String, dynamic>> get _proveedoresFiltrados {
    return _proveedores.where((prov) {
      final coincideFamilia = _filtroFamiliaProv == 'Todas' || prov['familia'] == _filtroFamiliaProv;
      final coincideMarca = _filtroMarcaProv == 'Todas' || prov['marca'] == _filtroMarcaProv;
      final coincideBusqueda = _busquedaProveedor.isEmpty ||
          (prov['nombre']?.toString().toLowerCase().contains(_busquedaProveedor.toLowerCase()) ?? false) ||
          (prov['rubro']?.toString().toLowerCase().contains(_busquedaProveedor.toLowerCase()) ?? false);
      return coincideFamilia && coincideMarca && coincideBusqueda;
    }).toList();
  }

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

  void _verDescripcion(String descripcion) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ProyectColors.surfaceDark,
        title: const Text('Descripción', style: TextStyle(color: ProyectColors.primaryGreen)),
        content: Text(descripcion, style: const TextStyle(color: ProyectColors.textPrimary)),
        actions: [
          TextButton(
            child: const Text('Cerrar', style: TextStyle(color: ProyectColors.primaryGreen)),
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
                  title: const Text('Inventario', style: TextStyle(color: ProyectColors.textPrimary)),
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
                          // Barra de búsqueda y filtros
                          Row(
                            children: [
                              // Búsqueda
                              Expanded(
                                flex: 2,
                                child: TextField(
                                  style: const TextStyle(color: ProyectColors.textPrimary),
                                  decoration: InputDecoration(
                                    hintText: 'Buscar por clave o nombre...',
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
                              // Filtro Familia
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _filtroFamilia,
                                  style: const TextStyle(color: ProyectColors.textPrimary),
                                  dropdownColor: ProyectColors.surfaceDark,
                                  decoration: InputDecoration(
                                    labelText: 'Familia',
                                    labelStyle: const TextStyle(color: ProyectColors.textSecondary),
                                    filled: true,
                                    fillColor: ProyectColors.surfaceDark,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  items: _familias
                                      .map((f) => DropdownMenuItem<String>(
                                            value: f,
                                            child: Text(f),
                                          ))
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _filtroFamilia = value!;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Filtro Línea
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _filtroLinea,
                                  style: const TextStyle(color: ProyectColors.textPrimary),
                                  dropdownColor: ProyectColors.surfaceDark,
                                  decoration: InputDecoration(
                                    labelText: 'Línea',
                                    labelStyle: const TextStyle(color: ProyectColors.textSecondary),
                                    filled: true,
                                    fillColor: ProyectColors.surfaceDark,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  items: _lineas
                                      .map((l) => DropdownMenuItem<String>(
                                            value: l,
                                            child: Text(l),
                                          ))
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _filtroLinea = value!;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Filtro Marca
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _filtroMarca,
                                  style: const TextStyle(color: ProyectColors.textPrimary),
                                  dropdownColor: ProyectColors.surfaceDark,
                                  decoration: InputDecoration(
                                    labelText: 'Marca',
                                    labelStyle: const TextStyle(color: ProyectColors.textSecondary),
                                    filled: true,
                                    fillColor: ProyectColors.surfaceDark,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  items: _marcas
                                      .map((m) => DropdownMenuItem<String>(
                                            value: m,
                                            child: Text(m),
                                          ))
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _filtroMarca = value!;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Tabla de artículos
                          Expanded(
                            child: ArticulosTable(
                              articulos: _articulosFiltrados,
                              onEditar: _editarArticulo,
                              onBorrar: _borrarArticulo,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // TAB 2: Proveedores
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Buscador de proveedores
                          TextField(
                            style: const TextStyle(color: ProyectColors.textPrimary),
                            decoration: InputDecoration(
                              hintText: 'Buscar proveedor por nombre o rubro...',
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
                                _busquedaProveedor = value;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          // Filtros de familia y marca
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _filtroFamiliaProv,
                                  style: const TextStyle(color: ProyectColors.textPrimary),
                                  dropdownColor: ProyectColors.surfaceDark,
                                  decoration: InputDecoration(
                                    labelText: 'Familia',
                                    labelStyle: const TextStyle(color: ProyectColors.textSecondary),
                                    filled: true,
                                    fillColor: ProyectColors.surfaceDark,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  items: _familiasProv
                                      .map((f) => DropdownMenuItem<String>(
                                            value: f,
                                            child: Text(f),
                                          ))
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _filtroFamiliaProv = value!;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _filtroMarcaProv,
                                  style: const TextStyle(color: ProyectColors.textPrimary),
                                  dropdownColor: ProyectColors.surfaceDark,
                                  decoration: InputDecoration(
                                    labelText: 'Marca',
                                    labelStyle: const TextStyle(color: ProyectColors.textSecondary),
                                    filled: true,
                                    fillColor: ProyectColors.surfaceDark,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  items: _marcasProv
                                      .map((m) => DropdownMenuItem<String>(
                                            value: m,
                                            child: Text(m),
                                          ))
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _filtroMarcaProv = value!;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Tabla de proveedores
                          Expanded(
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
                                  const SnackBar(content: Text('Proveedor eliminado')),
                                );
                              },
                              onVerDescripcion: _verDescripcion,
                              onDescargarPrecios: _descargarPrecios,
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