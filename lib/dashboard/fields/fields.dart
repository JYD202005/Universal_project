import 'package:flutter/material.dart';
import 'package:base_de_datos_universal/colours/colours.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:intl/intl.dart';
import 'dart:io';

///////----------------Artículos--------------------//////
class RegistrarArticuloFields extends StatefulWidget {
  const RegistrarArticuloFields({super.key});

  @override
  State<RegistrarArticuloFields> createState() =>
      _RegistrarArticuloFieldsState();
}

class _RegistrarArticuloFieldsState extends State<RegistrarArticuloFields> {
  //controllers
  final TextEditingController _nombre = TextEditingController();
  final TextEditingController _precio = TextEditingController();
  final TextEditingController _cantidad = TextEditingController();
  final TextEditingController _codigo = TextEditingController();
  final TextEditingController _minimaController = TextEditingController();
  final FocusNode _codigoFocus = FocusNode();

  final supabase = Supabase.instance.client;

  // cargar dropdown de marcas, familias, líneas y proveedores
  List<Map<String, dynamic>> _loadMarca = [];
  String? _selectedMarca;
  List<Map<String, dynamic>> _loadFamilia = [];
  String? _selectedFamilia;
  List<Map<String, dynamic>> _loadLinea = [];
  String? _selectedLinea;
  List<Map<String, dynamic>> _loadProveedor = [];
  String? _selectedProveedor;
  List<Map<String, dynamic>> _todos = [];

  bool boton = false;

  //Lista Para guardar los artículos
  final List<Map<String, dynamic>> _guardardo = [];

  String _ultimoCodigoIngresado = '';
  bool _escribiendoCodigo = false;

  //Metodo para cargar los dropdowns
  //cambiar lo de adentro por las variables de la base de datos
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

  Future<void> loadTodo() async {
    final responseProveedores = await supabase
        .from('Articulos')
        .select('id,clave, nombre,cantidad_stock,codigo_barras,deshabilitado');
    if (responseProveedores is List) {
      if (!mounted) return;
      setState(() {
        _todos = List<Map<String, dynamic>>.from(responseProveedores);
      });
    }
  }

  Future<void> agregarUno() async {
    // Validar que todos los campos estén vacíos
    if (_nombre.text.trim().isNotEmpty ||
        _precio.text.trim().isNotEmpty ||
        _cantidad.text.trim().isNotEmpty ||
        _selectedProveedor != null ||
        _selectedLinea != null ||
        _selectedFamilia != null ||
        _selectedMarca != null) {
      return;
    }
    final codigoBuscado = _codigo.text.trim();

    // Buscar el artículo por código de barras
    final articulo = _todos.firstWhere(
      (item) => item['codigo_barras'] == codigoBuscado,
      orElse: () => {},
    );

    // Si no se encontró
    if (articulo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Artículo no encontrado')),
      );
      return;
    }

    // Verificar si el artículo está deshabilitado
    if (articulo['deshabilitado'] == false) {
      final nombre = articulo['nombre'] ?? 'desconocido';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Este producto está deshabilitado: $nombre. Para agregarlo, favor de activarlo.')),
      );
      return;
    }

    final int nuevoStock = (articulo['cantidad_stock'] ?? 0) + 1;

    // Actualizar el stock en la base de datos
    try {
      await supabase
          .from('Articulos')
          .update({'cantidad_stock': nuevoStock}).eq('id', articulo['id']);
    } catch (e) {
      print(e);
    }

    if (mounted) {
      // Actualizar lista local
      setState(() {
        final index = _todos.indexWhere((e) => e['id'] == articulo['id']);
        if (index != -1) {
          _todos[index]['cantidad_stock'] = nuevoStock;
        }
        _codigo.clear();
      });
      FocusScope.of(context).requestFocus(_codigoFocus);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stock actualizado')),
      );
    }
  }

  void _onCodigoChangedParaAgregarUno(String? value) {
    final valor = value?.trim() ?? '';
    _ultimoCodigoIngresado = valor;
    _escribiendoCodigo = true;

    Future.delayed(const Duration(seconds: 1), () {
      if (_ultimoCodigoIngresado == valor && _escribiendoCodigo) {
        _escribiendoCodigo = false;

        if (valor.length >= 6) {
          agregarUno();
        }
      }
    });
  }

  //Guardar el artículo
  void _guardarArticulo() async {
    try {
      if (!restricciones()) return;
      final List<String> codigosExistentes = _todos
          .map((item) => item['codigo_barras']?.toString() ?? '')
          .where((codigo) => codigo.isNotEmpty)
          .toList();

      print(codigosExistentes);

      final codigoNuevo = _codigo.text.trim();

      if (codigosExistentes.contains(codigoNuevo)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Código de barras ya existe, favor de eliminar todo y reescribir solo el código de barras donde es necesario'),
          ),
        );
        return;
      }

      if (_minimaController.text.isEmpty) {
        _mostrarCantidadMinimaPopup(
            context,
            Offset(MediaQuery.of(context).size.width / 1.5,
                MediaQuery.of(context).size.height / 1.5),
            _minimaController);
        // Manejo de errores
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor complete el campo de cantidad mínima'),
          ),
        );
        return;
      }
      final int? minima = int.tryParse(_minimaController.text);
      if (minima == null || minima < 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cantidad mínima debe ser un número y positivo'),
          ),
        );
        return;
      }

      int cantidadAntes = _guardardo.length;
      final String? nuevaClave =
          await _generarNuevoPrefijoFamilia(_selectedFamilia);
      int actual = int.parse(_cantidad.text);
      int minimo = int.parse(_minimaController.text);

      _guardardo.add({
        'Clave': nuevaClave,
        'nombre': _nombre.text,
        'marca': _selectedMarca,
        'familia': _selectedFamilia,
        'linea': _selectedLinea,
        'proveedor': _selectedProveedor,
        'precio': double.parse(_precio.text),
        'cantidad': int.parse(_cantidad.text),
        'cantidad_minima': int.parse(_minimaController.text),
        'codigo': _codigo.text,
        'deshabilitado': true,
      });
      // Verificar si se guardó
      if (_guardardo.length > cantidadAntes) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Artículo guardado con éxito'),
          ),
        );
        print(_guardardo);
        _BaseAdd(nuevaClave);
        Limpiar();
        loadTodo();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al guardar el artículo'),
          ),
        );
      }
    } catch (e) {
      // Manejo de errores
      print('Error al guardar el artículo: $e');
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

  void _BaseAdd(String? nuevaClave) async {
    if (!mounted) return;
    await supabase.from('Articulos').insert({
      'clave': nuevaClave,
      'nombre': _nombre.text,
      'marca_id': int.parse(_selectedMarca!),
      'familia_id': int.parse(_selectedFamilia!),
      'linea_id': int.parse(_selectedLinea!),
      'provee_id': int.parse(_selectedProveedor!),
      'precio': double.parse(_precio.text),
      'cantidad_stock': int.parse(_cantidad.text),
      'cantidad_min': int.parse(_minimaController.text),
      'codigo_barras': _codigo.text,
      'deshabilitado': true,
    });
  }

  void Limpiar() {
    _nombre.clear();
    _precio.clear();
    _cantidad.clear();
    _codigo.clear();
    _minimaController.clear();
    if (!mounted) return;
    setState(() {
      _selectedMarca = null;
      _selectedFamilia = null;
      _selectedLinea = null;
      _selectedProveedor = null;
      _guardardo.clear();
    });
  }

  bool restricciones() {
    if (_nombre.text.isEmpty ||
        _precio.text.isEmpty ||
        _cantidad.text.isEmpty ||
        _codigo.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor complete todos los campos'),
        ),
      );
      return false; // <-- IMPORTANTE
    }

    if (_selectedMarca == null ||
        _selectedFamilia == null ||
        _selectedLinea == null ||
        _selectedProveedor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor seleccione todos los campos'),
        ),
      );
      return false;
    }

    final double? precio = double.tryParse(_precio.text);
    final int? cantidad = int.tryParse(_cantidad.text);

    if (precio == null || precio <= 0 || cantidad == null || cantidad <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Precio, cantidad y mínima deben ser números positivos'),
        ),
      );
      return false;
    }

    return true; // <-- Si todo está bien
  }

  @override
  void initState() {
    super.initState();
    if (!mounted) return;
    _loadDrops();
    loadTodo();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Registrar Artículo',
          style: TextStyle(
            color: ProyectColors.primaryGreen,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        //Nombre del artículo
        TextField(
          controller: _nombre,
          style: const TextStyle(color: ProyectColors.textPrimary),
          decoration: InputDecoration(
            labelText: 'Nombre',
            prefixIcon: Icon(Icons.label, color: ProyectColors.primaryGreen),
            labelStyle: const TextStyle(color: ProyectColors.textSecondary),
            filled: true,
            fillColor: ProyectColors.surfaceDark,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              //Marca
              child: DropdownButtonFormField<String>(
                value: _selectedMarca,
                items: _loadMarca
                    .map((item) => DropdownMenuItem<String>(
                          value: item['id'].toString(),
                          child: Text(item['nombre']),
                        ))
                    .toList(),
                style: const TextStyle(color: ProyectColors.textPrimary),
                dropdownColor: ProyectColors.surfaceDark,
                decoration: InputDecoration(
                  labelText: 'Marca',
                  prefixIcon:
                      Icon(Icons.business, color: ProyectColors.primaryGreen),
                  suffixIcon: _selectedMarca != null
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            setState(() {
                              _selectedMarca = null;
                            });
                          },
                        )
                      : null,
                  labelStyle:
                      const TextStyle(color: ProyectColors.textSecondary),
                  filled: true,
                  fillColor: ProyectColors.surfaceDark,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onChanged: (value) {
                  setState(() {
                    _selectedMarca = value;
                  });
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              //Linea
              child: DropdownButtonFormField<String>(
                value: _selectedLinea,
                items: _loadLinea
                    .map((item) => DropdownMenuItem<String>(
                          value: item['id'].toString(),
                          child: Text(item['nombre']),
                        ))
                    .toList(),
                style: const TextStyle(color: ProyectColors.textPrimary),
                dropdownColor: ProyectColors.surfaceDark,
                decoration: InputDecoration(
                  labelText: 'Línea',
                  prefixIcon:
                      Icon(Icons.category, color: ProyectColors.primaryGreen),
                  suffixIcon: _selectedLinea != null
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            setState(() {
                              _selectedLinea = null;
                            });
                          },
                        )
                      : null,
                  labelStyle:
                      const TextStyle(color: ProyectColors.textSecondary),
                  filled: true,
                  fillColor: ProyectColors.surfaceDark,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onChanged: (value) {
                  setState(() {
                    _selectedLinea = value;
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              //Familia
              child: DropdownButtonFormField<String>(
                value: _selectedFamilia,
                items: _loadFamilia
                    .map((item) => DropdownMenuItem<String>(
                          value: item['id'].toString(),
                          child: Text(item['nombre']),
                        ))
                    .toList(),
                style: const TextStyle(color: ProyectColors.textPrimary),
                dropdownColor: ProyectColors.surfaceDark,
                decoration: InputDecoration(
                  labelText: 'Familia',
                  prefixIcon:
                      Icon(Icons.group_work, color: ProyectColors.primaryGreen),
                  suffixIcon: _selectedFamilia != null
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            setState(() {
                              _selectedFamilia = null;
                            });
                          },
                        )
                      : null,
                  labelStyle:
                      const TextStyle(color: ProyectColors.textSecondary),
                  filled: true,
                  fillColor: ProyectColors.surfaceDark,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onChanged: (Value) {
                  setState(() {
                    _selectedFamilia = Value;
                  });
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              //Proveedor
              child: DropdownButtonFormField<String>(
                value: _selectedProveedor,
                items: _loadProveedor
                    .map((item) => DropdownMenuItem<String>(
                          value: item['id'].toString(),
                          child: Text(item['nombre']),
                        ))
                    .toList(),
                style: const TextStyle(color: ProyectColors.textPrimary),
                dropdownColor: ProyectColors.surfaceDark,
                decoration: InputDecoration(
                  labelText: 'Proveedor',
                  prefixIcon: Icon(Icons.local_shipping,
                      color: ProyectColors.primaryGreen),
                  suffixIcon: _selectedProveedor != null
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            setState(() {
                              _selectedProveedor = null;
                            });
                          },
                        )
                      : null,
                  labelStyle:
                      const TextStyle(color: ProyectColors.textSecondary),
                  filled: true,
                  fillColor: ProyectColors.surfaceDark,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onChanged: (value) {
                  setState(() {
                    _selectedProveedor = value;
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              //Precio
              child: TextField(
                controller: _precio,
                style: const TextStyle(color: ProyectColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Precio Unitario',
                  prefixIcon: Icon(Icons.attach_money,
                      color: ProyectColors.primaryGreen),
                  labelStyle:
                      const TextStyle(color: ProyectColors.textSecondary),
                  filled: true,
                  fillColor: ProyectColors.surfaceDark,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 16),
            //Cantidad
            Expanded(
              child: TextField(
                controller: _cantidad,
                style: const TextStyle(color: ProyectColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Cantidad Inicial',
                  prefixIcon: Icon(Icons.confirmation_number,
                      color: ProyectColors.primaryGreen),
                  labelStyle:
                      const TextStyle(color: ProyectColors.textSecondary),
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
          //Código de barras
          style: const TextStyle(color: ProyectColors.textPrimary),
          controller: _codigo,
          focusNode: _codigoFocus,
          decoration: InputDecoration(
            labelText: 'Código de barras',
            hintText: 'Código existente: solo se suma al stock',
            prefixIcon: Icon(Icons.qr_code, color: ProyectColors.primaryGreen),
            labelStyle: const TextStyle(color: ProyectColors.textSecondary),
            filled: true,
            fillColor: ProyectColors.surfaceDark,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onChanged: _onCodigoChangedParaAgregarUno,
        ),
        const SizedBox(height: 24),
        //Botón de guardar

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: ProyectColors.primaryGreen,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              _guardarArticulo();
            },
            icon: const Icon(Icons.save, color: ProyectColors.backgroundDark),
            label: const Text(
              'Guardar Artículo',
              style: TextStyle(
                color: ProyectColors.backgroundDark,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

//PAra Mostrar el popup de la cantidad mínima
void _mostrarCantidadMinimaPopup(
  BuildContext context,
  Offset offset,
  TextEditingController minController,
) {
  final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

  showMenu(
    context: context,
    position: RelativeRect.fromLTRB(
      offset.dx,
      offset.dy,
      overlay.size.width - offset.dx,
      overlay.size.height - offset.dy,
    ),
    color: ProyectColors.surfaceDark,
    items: [
      PopupMenuItem<String>(
        enabled: false,
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Cantidad mínima requerida Antes De Aviso',
                style: TextStyle(
                  color: ProyectColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: minController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: ProyectColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Ej En Unidades. 10',
                  hintStyle:
                      const TextStyle(color: ProyectColors.textSecondary),
                  filled: true,
                  fillColor: ProyectColors.backgroundDark,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                autofocus: true,
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    // Aquí puedes guardar el valor
                    Navigator.pop(context); // Cierra el menú
                  }
                },
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

///////----------------Ventas--------------------//////
class RegistrarVentaFields extends StatefulWidget {
  const RegistrarVentaFields({super.key});

  @override
  State<RegistrarVentaFields> createState() => _RegistrarVentaFieldsState();
}

class _RegistrarVentaFieldsState extends State<RegistrarVentaFields> {
  final ScrollController _horizontalTableScrollController = ScrollController();
  final ScrollController _carritoScrollController =
      ScrollController(); // para el ListView
  final ScrollController _tituloScrollController =
      ScrollController(); // para el título scrollable

  String? _selectedArticulo;
  int _cantidad = 1;
  final TextEditingController _cantidadController =
      TextEditingController(text: '1');
  final List<Map<String, dynamic>> _carrito = [];
  final supabase = Supabase.instance.client;

  // Artículos simulados
  List<Map<String, dynamic>> _articulos = [];

  // Métodos de pago simulados
  final List<String> _metodosPago = ['Efectivo', 'Tarjeta Visa'];
  String? _metodoPagoSeleccionado;

  // Controladores para los campos de tarjeta
  final TextEditingController _numeroTarjeta = TextEditingController();
  final TextEditingController _fechaVencimiento = TextEditingController();
  final TextEditingController _cvv = TextEditingController();
  final TextEditingController _nombreTitular = TextEditingController();
  final TextEditingController _direccion = TextEditingController();
  final TextEditingController _correo = TextEditingController();
  final TextEditingController _telefono = TextEditingController();
  final TextEditingController _pagoCliente = TextEditingController();
  final TextEditingController _cambioController = TextEditingController();
  final TextEditingController _barras = TextEditingController();
  final FocusNode _codigoFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    if (!mounted) return;
    _initAsync();
  }

  @override
  void dispose() {
    _pagoCliente.dispose();
    _cambioController.dispose();
    super.dispose();
  }

  Future<void> _initAsync() async {
    await loadDrop();
  }

  Future<void> loadDrop() async {
    try {
      final responseArt = await supabase
          .from('Articulos')
          .select(
              'id, nombre, precio, cantidad_stock, marca:marca_id (nombre),proveedores:provee_id(nombre),codigo_barras')
          .eq('deshabilitado', true);
      ;

      if (responseArt is List) {
        // Extraemos el nombre de la marca y lo incluimos en cada artículo
        final articulosConMarca = responseArt.map<Map<String, dynamic>>((art) {
          return {
            'id': art['id'],
            'nombre': art['nombre'],
            'precio': art['precio'],
            'cantidad_stock': art['cantidad_stock'],
            'marca_id':
                art['marca'] != null ? art['marca']['nombre'] : 'Sin marca',
            'prove_id': art['proveedores'] != null
                ? art['proveedores']['nombre']
                : 'Sin proveedor',
            'barras': art['codigo_barras']
          };
        }).toList();

        if (!mounted) return;
        setState(() {
          _articulos = articulosConMarca;
        });
      } else {
        print('Error al cargar datos desde Supabase');
      }
    } catch (e) {
      print(e);
    }
  }

  double get _precioUnitario {
    final articulo = _articulos.firstWhere(
      (a) => a['id'].toString() == _selectedArticulo,
      orElse: () => {},
    );
    return double.parse(articulo['precio'].toString()) ?? 0.0;
  }

  int get _cantidadStock {
    try {
      final articulo = _articulos.firstWhere(
        (a) => a['id'].toString() == _selectedArticulo,
        orElse: () => {},
      );
      final cantidadStr = articulo['cantidad_stock']?.toString() ?? '';
      return int.tryParse(cantidadStr) ?? 0;
    } catch (e) {
      print(e);
      return -1;
    }
  }

  String get _nombreArticulo {
    final articulo = _articulos.firstWhere(
      (a) => a['id'].toString() == _selectedArticulo,
      orElse: () => {},
    );
    return articulo['nombre'].toString();
  }

  String get _marca {
    final articulo = _articulos.firstWhere(
      (a) => a['id'].toString() == _selectedArticulo,
      orElse: () => {},
    );
    return articulo['marca_id'].toString() ?? 'asereje';
  }

  double get _precioTotal {
    double total = 0.0;
    for (var item in _carrito) {
      total += (item['precio'] as double) * (item['cantidad'] as int);
    }
    return total;
  }

  String get _provee {
    final articulo = _articulos.firstWhere(
      (a) => a['id'].toString() == _selectedArticulo,
      orElse: () => {},
    );
    return articulo['prove_id'].toString() ?? 'error proveedor';
  }

  String get _barrasPlus {
    final articulo = _articulos.firstWhere(
      (a) => a['id'].toString() == _selectedArticulo,
      orElse: () => {},
    );
    return articulo['barras'].toString() ?? '';
  }

  void _agregarAlCarrito() {
    final parsedCantidad = int.tryParse(_cantidadController.text);
    if (_selectedArticulo == null ||
        parsedCantidad == null ||
        parsedCantidad <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Selecciona un artículo y cantidad válida')),
      );
      return;
    }

    final index =
        _carrito.indexWhere((item) => item['id'] == _selectedArticulo);
    final cantidadActual = index >= 0 ? _carrito[index]['cantidad'] as int : 0;
    final nuevaCantidadTotal = cantidadActual + parsedCantidad;
    if (nuevaCantidadTotal > _cantidadStock) {
      final cantidadRestante = _cantidadStock - cantidadActual;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Cantidad en stock insuficiente.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _cantidad = parsedCantidad;
      if (index >= 0) {
        _carrito[index]['cantidad'] += _cantidad;
      } else {
        _carrito.add({
          'id': _selectedArticulo,
          'nombre': _nombreArticulo,
          'precio': _precioUnitario,
          'cantidad': _cantidad,
          'marca_id': _marca,
          'prove_id': _provee,
        });
        print(_carrito);
      }
      _cantidadController.text = '1';
      _cantidad = 1;
    });
  }

  void _eliminarDelCarrito(String id) {
    setState(() {
      _carrito.removeWhere((item) => item['id'] == id);
    });
  }

  Future<bool> _mostrarMetodoPagoDialog() async {
    bool aceptado = false;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: ProyectColors.surfaceDark,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Método de pago',
            style: TextStyle(
                color: ProyectColors.primaryGreen, fontWeight: FontWeight.bold),
          ),
          content: StatefulBuilder(
            builder: (context, setModalState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: _metodoPagoSeleccionado,
                      style: const TextStyle(color: ProyectColors.textPrimary),
                      dropdownColor: ProyectColors.surfaceDark,
                      decoration: InputDecoration(
                        labelText: 'Selecciona un método de pago',
                        labelStyle:
                            const TextStyle(color: ProyectColors.textPrimary),
                        filled: true,
                        fillColor: ProyectColors.surfaceDark,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      items: _metodosPago
                          .map((metodo) => DropdownMenuItem<String>(
                                value: metodo,
                                child: Text(metodo,
                                    style: const TextStyle(
                                        color: ProyectColors.textPrimary)),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setModalState(() {
                          _metodoPagoSeleccionado = value;
                        });
                        if (!mounted) return;
                        setState(() {
                          _metodoPagoSeleccionado = value;
                        });
                      },
                    ),
                    if (_metodoPagoSeleccionado == 'Tarjeta Visa') ...[
                      const SizedBox(height: 16),
                      TextField(
                        controller: _numeroTarjeta,
                        style:
                            const TextStyle(color: ProyectColors.textPrimary),
                        decoration: InputDecoration(
                          labelText: 'Número de la tarjeta',
                          prefixIcon: Icon(Icons.credit_card,
                              color: ProyectColors.primaryGreen),
                          labelStyle:
                              const TextStyle(color: ProyectColors.textPrimary),
                          filled: true,
                          fillColor: ProyectColors.surfaceDark,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          counterText: '',
                        ),
                        keyboardType: TextInputType.number,
                        maxLength: 16,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _fechaVencimiento,
                              style: const TextStyle(
                                  color: ProyectColors.textPrimary),
                              decoration: InputDecoration(
                                labelText: 'Vencimiento (MM/YYYY)',
                                prefixIcon: Icon(Icons.date_range,
                                    color: ProyectColors.primaryGreen),
                                labelStyle: const TextStyle(
                                    color: ProyectColors.textPrimary),
                                filled: true,
                                fillColor: ProyectColors.surfaceDark,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                hintText: 'MM/YYYY',
                                hintStyle: const TextStyle(
                                    color: ProyectColors.textSecondary),
                              ),
                              keyboardType: TextInputType.datetime,
                              maxLength: 7,
                              onChanged: (value) {
                                // Formato automático MM/YYYY
                                if (value.length == 2 &&
                                    !_fechaVencimiento.text.contains('/')) {
                                  _fechaVencimiento.text = '$value/';
                                  _fechaVencimiento.selection =
                                      TextSelection.fromPosition(
                                    TextPosition(
                                        offset: _fechaVencimiento.text.length),
                                  );
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: _cvv,
                              style: const TextStyle(
                                  color: ProyectColors.textPrimary),
                              decoration: InputDecoration(
                                labelText: 'CVV',
                                prefixIcon: Icon(Icons.lock,
                                    color: ProyectColors.primaryGreen),
                                labelStyle: const TextStyle(
                                    color: ProyectColors.textPrimary),
                                filled: true,
                                fillColor: ProyectColors.surfaceDark,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              keyboardType: TextInputType.number,
                              maxLength: 3,
                              obscureText: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _nombreTitular,
                        style:
                            const TextStyle(color: ProyectColors.textPrimary),
                        decoration: InputDecoration(
                          labelText: 'Nombre del titular',
                          prefixIcon: Icon(Icons.person,
                              color: ProyectColors.primaryGreen),
                          labelStyle:
                              const TextStyle(color: ProyectColors.textPrimary),
                          filled: true,
                          fillColor: ProyectColors.surfaceDark,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _direccion,
                        style:
                            const TextStyle(color: ProyectColors.textPrimary),
                        decoration: InputDecoration(
                          labelText: 'Dirección de facturación',
                          prefixIcon: Icon(Icons.home,
                              color: ProyectColors.primaryGreen),
                          labelStyle:
                              const TextStyle(color: ProyectColors.textPrimary),
                          filled: true,
                          fillColor: ProyectColors.surfaceDark,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _correo,
                        style:
                            const TextStyle(color: ProyectColors.textPrimary),
                        decoration: InputDecoration(
                          labelText: 'Correo electrónico',
                          prefixIcon: Icon(Icons.email,
                              color: ProyectColors.primaryGreen),
                          labelStyle:
                              const TextStyle(color: ProyectColors.textPrimary),
                          filled: true,
                          fillColor: ProyectColors.surfaceDark,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _telefono,
                        style:
                            const TextStyle(color: ProyectColors.textPrimary),
                        decoration: InputDecoration(
                          labelText: 'Teléfono',
                          prefixIcon: Icon(Icons.phone,
                              color: ProyectColors.primaryGreen),
                          labelStyle:
                              const TextStyle(color: ProyectColors.textPrimary),
                          filled: true,
                          fillColor: ProyectColors.surfaceDark,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter
                              .digitsOnly, // Solo números
                          LengthLimitingTextInputFormatter(
                              10), // Máximo 10 dígitos
                        ],
                      ),
                    ],
                    if (_metodoPagoSeleccionado == 'Efectivo') ...[
                      const SizedBox(height: 16),
                      TextField(
                        enabled: false,
                        style:
                            const TextStyle(color: ProyectColors.textPrimary),
                        decoration: InputDecoration(
                          labelText: 'Precio total',
                          prefixIcon: Icon(Icons.calculate,
                              color: ProyectColors.primaryGreen),
                          labelStyle:
                              const TextStyle(color: ProyectColors.textPrimary),
                          filled: true,
                          fillColor: ProyectColors.surfaceDark,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        controller: TextEditingController(
                            text: _precioTotal.toStringAsFixed(2)),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        style:
                            const TextStyle(color: ProyectColors.textPrimary),
                        decoration: InputDecoration(
                          labelText: 'Pago recibido',
                          prefixIcon: Icon(Icons.money_rounded,
                              color: ProyectColors.primaryGreen),
                          labelStyle:
                              const TextStyle(color: ProyectColors.textPrimary),
                          filled: true,
                          fillColor: ProyectColors.surfaceDark,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        controller: _pagoCliente,
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          final pago = double.tryParse(value.trim()) ?? 0.0;
                          if (!mounted) return;
                          setState(() {
                            _cambioController.text =
                                (pago - _precioTotal).toString();
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      TextField(
                          enabled: false,
                          style: TextStyle(color: ProyectColors.textPrimary),
                          decoration: InputDecoration(
                            labelText: 'Cambio',
                            prefixIcon: Icon(Icons.currency_exchange,
                                color: ProyectColors.primaryGreen),
                            labelStyle:
                                TextStyle(color: ProyectColors.textPrimary),
                            filled: true,
                            fillColor: ProyectColors.surfaceDark,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          controller: _cambioController),
                    ]
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              child:
                  const Text('Cancelar', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ProyectColors.primaryGreen,
              ),
              child: const Text('Aceptar',
                  style: TextStyle(color: ProyectColors.backgroundDark)),
              onPressed: () {
                if (_metodoPagoSeleccionado == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Selecciona un método de pago')),
                  );
                  return;
                }
                if (_metodoPagoSeleccionado == 'Tarjeta Visa') {
                  // Validaciones de tarjeta
                  final tarjeta = _numeroTarjeta.text.trim();
                  final venc = _fechaVencimiento.text.trim();
                  final cvv = _cvv.text.trim();
                  final nombre = _nombreTitular.text.trim();
                  final correo = _correo.text.trim();

                  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                  final vencimientoRegex = RegExp(r'^(0[1-9]|1[0-2])\/\d{4}$');

                  if (tarjeta.length != 16 || int.tryParse(tarjeta) == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Número de tarjeta inválido')),
                    );
                    return;
                  }
                  if (!vencimientoRegex.hasMatch(venc)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'Fecha de vencimiento inválida. Usa MM/YYYY')),
                    );
                    return;
                  }
                  if (cvv.length != 3 || int.tryParse(cvv) == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('CVV inválido')),
                    );
                    return;
                  }
                  if (nombre.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Nombre del titular requerido')),
                    );
                    return;
                  }
                  if (!emailRegex.hasMatch(correo)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Correo electrónico inválido')),
                    );
                    return;
                  }
                }
                if (_metodoPagoSeleccionado == 'Efectivo') {
                  final totalPagar = _precioTotal.toStringAsFixed(2);
                  final pagoRecibido = _pagoCliente.text.trim();
                  if (pagoRecibido.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Ingrese el monto recibido')),
                    );
                    return;
                  }
                  double? pagoClienteValor = double.tryParse(pagoRecibido);
                  if (pagoClienteValor == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Monto ingresado no válido')),
                    );
                    return;
                  }
                  if (pagoClienteValor <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('El monto debe ser mayor a cero')),
                    );
                    return;
                  }
                  if (double.parse(totalPagar) > double.parse(pagoRecibido)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('La cantidad entregada es insuficiente')),
                    );
                    return;
                  }
                }
                aceptado = true;
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
    return aceptado;
  }

  void _comprar() async {
    if (_carrito.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El carrito está vacío')),
      );
      return;
    }
    bool pagoOk = true;
    if (_metodoPagoSeleccionado == null) {
      pagoOk = await _mostrarMetodoPagoDialog();
      if (!pagoOk) return;
    } else if (_metodoPagoSeleccionado == 'Tarjeta Visa') {
      pagoOk = await _mostrarMetodoPagoDialog();
      if (!pagoOk) return;
    } else if (_metodoPagoSeleccionado == 'Efectivo') {
      pagoOk = await _mostrarMetodoPagoDialog();
      if (!pagoOk) return;
    }
    try {
      await _guardarVentasPorCarrito();
    } catch (e) {
      print(e);
    } // Si pasa todas las validaciones:
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('¡Compra realizada con éxito!')),
    );
    setState(() {
      _carrito.clear();
      _metodoPagoSeleccionado = null;
      _numeroTarjeta.clear();
      _fechaVencimiento.clear();
      _cvv.clear();
      _nombreTitular.clear();
      _direccion.clear();
      _correo.clear();
      _telefono.clear();
      _pagoCliente.clear();
      _cambioController.clear();
      _selectedArticulo = null;
    });
  }

  int obtenerStockPorId(String id) {
    try {
      final articulo = _articulos.firstWhere((a) => a['id'].toString() == id);
      return articulo['cantidad_stock'] as int;
    } catch (e) {
      return 0;
    }
  }

  void _actualizarCantidad(String id, int cambio) {
    final index = _carrito.indexWhere((item) => item['id'] == id);
    if (index == -1) return;

    final item = _carrito[index];
    final cantidadActual = item['cantidad'] as int;
    final nuevaCantidad = cantidadActual + cambio;

    // Obtener el stock máximo disponible para este artículo
    final stockDisponible = (obtenerStockPorId(id));

    if (nuevaCantidad > stockDisponible) {
      final restante = stockDisponible - cantidadActual;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Solo puedes agregar $restante unidad${restante == 1 ? '' : 'es'} más del artículo "${item['nombre']}". '
            'Stock total disponible: $stockDisponible.',
          ),
        ),
      );
      return;
    }

    if (nuevaCantidad < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La cantidad mínima es 1'),
        ),
      );
      return;
    }

    if (!mounted) return;

    setState(() {
      _carrito[index]['cantidad'] = nuevaCantidad;
    });
  }

  Future<void> _guardarVentasPorCarrito() async {
    if (!mounted) return;
    try {
      for (var item in _carrito) {
        final int? articuloId = int.tryParse(item['id'] ?? '0');
        if (articuloId == null) continue;

        final String proveedor = item['prove_id'] ?? '';
        final int cantidad = item['cantidad'] ?? 0;
        final double precio = (item['precio'] as num).toDouble();
        final double total = cantidad * precio;

        // 1. Guardar la venta
        await supabase.from('Ventas').insert({
          'articulo_id': articuloId,
          'proveedor_name': proveedor,
          'cantidad_com': cantidad,
          'precio_unic': precio,
          'total_unico': total,
          'dia': DateFormat('yyyy-MM-dd').format(DateTime.now()),
          'hora': DateFormat('HH:mm:ss').format(DateTime.now()),
        });

        // 2. Obtener stock actual del artículo
        //asereje cambio si?
        final response = await supabase
            .from('Articulos')
            .select('cantidad_stock')
            .eq('id', articuloId)
            .single();

        if (response != null && response['cantidad_stock'] != null) {
          final int stockActual = response['cantidad_stock'] as int;
          final int nuevoStock = stockActual - cantidad;

          // Validar que no quede negativo
          final int stockFinal = nuevoStock >= 0 ? nuevoStock : 0;

          // 3. Actualizar stock
          await supabase.from('Articulos').update({
            'cantidad_stock': stockFinal,
          }).eq('id', articuloId);
        }
      }
    } catch (e) {
      print('Error al guardar venta y actualizar stock: $e');
    }
  }

  void buscarPorCodigoDeBarras(String codigo) {
    final articulo = _articulos.firstWhere(
      (a) => a['barras'].toString() == codigo,
      orElse: () => {},
    );

    if (articulo.isNotEmpty) {
      if (!mounted) return;
      setState(() {
        _selectedArticulo = articulo['id'].toString();
        _cantidadController.text = '1'; // si quieres establecer por defecto
        // Puedes agregar más datos como _precio, _nombre, etc.
      });

      // Opcional: mostrar retroalimentación
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Artículo encontrado: ${articulo['nombre']}, Marca: ${articulo['marca_id']}')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Artículo no encontrado')),
      );
    }
  }

  String _ultimoValorIngresado = '';
  bool _escribiendo = false;

  void _onCodigoBarrasChanged(String? value) {
    final valor = value ?? ''; // Por si llega null
    _ultimoValorIngresado = valor;
    _escribiendo = true;

    Future.delayed(const Duration(seconds: 1), () {
      if (_ultimoValorIngresado == valor && _escribiendo) {
        _escribiendo = false;

        if (valor.trim().length >= 6) {
          buscarPorCodigoDeBarras(valor.trim());
          _agregarAlCarrito();
          _barras.clear();
        }
        FocusScope.of(context).requestFocus(_codigoFocus);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Registrar Venta',
            style: TextStyle(
              color: ProyectColors.primaryGreen,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _barras,
            focusNode: _codigoFocus,
            style: const TextStyle(color: ProyectColors.textPrimary),
            decoration: InputDecoration(
              labelText: 'Codigo De Barras',
              hintText: 'Buscar por codigo de barras....',
              prefixIcon:
                  Icon(Icons.barcode_reader, color: ProyectColors.primaryGreen),
              labelStyle: const TextStyle(color: ProyectColors.textPrimary),
              filled: true,
              fillColor: ProyectColors.surfaceDark,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onChanged: _onCodigoBarrasChanged,
          ),
          const SizedBox(height: 24),
          DropdownButtonFormField<String>(
            value: _selectedArticulo,
            style: const TextStyle(color: ProyectColors.textPrimary),
            dropdownColor: ProyectColors.surfaceDark,
            decoration: InputDecoration(
              labelText: 'Artículo',
              prefixIcon:
                  Icon(Icons.inventory_2, color: ProyectColors.primaryGreen),
              labelStyle: const TextStyle(color: ProyectColors.textPrimary),
              filled: true,
              fillColor: ProyectColors.surfaceDark,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            items: _articulos
                .map((art) => DropdownMenuItem<String>(
                      value: art['id'].toString(),
                      child: Row(
                        children: [
                          Text(art['nombre'],
                              style: const TextStyle(
                                  color: ProyectColors.textPrimary)),
                          const SizedBox(
                            width: 8,
                            child: Text(','),
                          ),
                          Text(art['marca_id'].toString(),
                              style: const TextStyle(
                                  color: ProyectColors.textPrimary)),
                        ],
                      ),
                    ))
                .toList(),
            onChanged: (value) {
              if (!mounted) return;
              setState(() {
                _selectedArticulo = value;
              });
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _cantidadController,
                  style: const TextStyle(color: ProyectColors.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Cantidad, Stock:${_cantidadStock}',
                    prefixIcon: Icon(Icons.confirmation_number,
                        color: ProyectColors.primaryGreen),
                    labelStyle:
                        const TextStyle(color: ProyectColors.textPrimary),
                    filled: true,
                    fillColor: ProyectColors.surfaceDark,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      _cantidad = int.tryParse(value) ?? 1;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  enabled: false,
                  style: const TextStyle(color: ProyectColors.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Precio unitario',
                    prefixIcon: Icon(Icons.attach_money,
                        color: ProyectColors.primaryGreen),
                    labelStyle:
                        const TextStyle(color: ProyectColors.textPrimary),
                    filled: true,
                    fillColor: ProyectColors.surfaceDark,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  controller: TextEditingController(
                    text: _selectedArticulo == null
                        ? ''
                        : _precioUnitario.toStringAsFixed(2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: ProyectColors.primaryGreen,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _agregarAlCarrito,
              icon: const Icon(Icons.add_shopping_cart,
                  color: ProyectColors.backgroundDark),
              label: const Text(
                'Agregar al carrito',
                style: TextStyle(
                  color: ProyectColors.backgroundDark,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (_carrito.isNotEmpty) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Carrito',
                  style: TextStyle(
                    color: ProyectColors.primaryGreen,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 109,
              child: RawScrollbar(
                controller: _horizontalTableScrollController,
                thumbColor: ProyectColors.primaryGreen,
                thumbVisibility: true,
                radius: Radius.circular(6),
                thickness: 5,
                child: Container(
                  child: ListView.separated(
                    controller: _horizontalTableScrollController,
                    scrollDirection: Axis.horizontal,
                    itemCount: _carrito.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final item = _carrito[index];
                      return Card(
                        color: ProyectColors.surfaceDark,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item['nombre'].toString(),
                                      style: const TextStyle(
                                          color: ProyectColors.textPrimary,
                                          fontWeight: FontWeight.bold)),
                                  Text(item['marca_id'].toString(),
                                      style: const TextStyle(
                                          color: ProyectColors.textPrimary,
                                          fontWeight: FontWeight.bold)),
                                  Row(
                                    spacing: 8,
                                    children: [
                                      IconButton(
                                        onPressed: () =>
                                            _actualizarCantidad(item['id'], -1),
                                        icon: const Icon(Icons.remove),
                                      ),
                                      Text('Cantidad: ${item['cantidad']}',
                                          style: const TextStyle(
                                              color:
                                                  ProyectColors.textPrimary)),
                                      IconButton(
                                        onPressed: () =>
                                            _actualizarCantidad(item['id'], 1),
                                        icon: const Icon(Icons.add),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    color: ProyectColors.danger),
                                tooltip: 'Eliminar',
                                onPressed: () =>
                                    _eliminarDelCarrito(item['id']),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              enabled: false,
              style: const TextStyle(color: ProyectColors.textPrimary),
              decoration: InputDecoration(
                labelText: 'Precio total',
                prefixIcon:
                    Icon(Icons.calculate, color: ProyectColors.primaryGreen),
                labelStyle: const TextStyle(color: ProyectColors.textPrimary),
                filled: true,
                fillColor: ProyectColors.surfaceDark,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              controller:
                  TextEditingController(text: _precioTotal.toStringAsFixed(2)),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ProyectColors.primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _comprar,
                icon: const Icon(Icons.shopping_cart_checkout,
                    color: ProyectColors.backgroundDark),
                label: const Text(
                  'Comprar',
                  style: TextStyle(
                    color: ProyectColors.backgroundDark,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

///////----------------Proveedores--------------------//////

class RegistrarProveedorFields extends StatefulWidget {
  const RegistrarProveedorFields({super.key});

  @override
  State<RegistrarProveedorFields> createState() =>
      _RegistrarProveedorFieldsState();
}

class _RegistrarProveedorFieldsState extends State<RegistrarProveedorFields> {
  //controller
  final TextEditingController _nombre = TextEditingController();
  final TextEditingController _rubro = TextEditingController();
  final TextEditingController _descripcion = TextEditingController();
  final TextEditingController _codigoSAT = TextEditingController();
  final TextEditingController _precioEstimado = TextEditingController();
  bool _filePickerAbierto = false;
  //Cargar dropdown de marcas, familias y líneas
  List<Map<String, dynamic>> _loadMarca = [];
  String? _selectedMarca;
  List<Map<String, dynamic>> _loadFamilia = [];
  String? _selectedFamilia;
  List<Map<String, dynamic>> _loadLinea = [];
  String? _selectedLinea;

  final supabase = Supabase.instance.client;

  File? _archivoSeleccionado;
  String? _nombreArchivo;

  //Cargar dropdown de proveedores
  void _loadDrops() async {
    final responseLineas = await supabase.from('Linea').select('id, nombre');
    final responseFamilias =
        await supabase.from('Familia').select('id, nombre, prefijo');
    final responseMarcas = await supabase.from('Marca').select('id, nombre');

    // Asegúrate de que las respuestas sean listas antes de asignarlas
    if (responseLineas is List &&
        responseFamilias is List &&
        responseMarcas is List) {
      if (!mounted) return;
      setState(() {
        _loadLinea = List<Map<String, dynamic>>.from(responseLineas);
        _loadFamilia = List<Map<String, dynamic>>.from(responseFamilias);
        _loadMarca = List<Map<String, dynamic>>.from(responseMarcas);
      });
    } else {
      // Manejo de errores si alguna respuesta falla
      print('Error al cargar datos desde Supabase');
    }
  }

  //Guardar el proveedor
  final List<Map<String, dynamic>> _guardarProvee = [];

  @override
  void initState() {
    super.initState();
    _loadDrops();
  }

  void _guardar() async {
    try {
      if (!restricciones()) return;
      int cantidadAntes = _guardarProvee.length;
      //Guardar el proveedor
      _guardarProvee.add({
        'Nombre': _nombre.text,
        'Rubro': _rubro.text,
        'Marca': _selectedMarca,
        'Familia': _selectedFamilia,
        'Linea': _selectedLinea,
        'Descripcion': _descripcion.text,
        'CodigoSAT': _codigoSAT.text,
        'PrecioEstimado': _precioEstimado.text,
      });
      if (_guardarProvee.length > cantidadAntes) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Proveedor guardado con éxito'),
          ),
        );
        print(_guardarProvee);
        try {
          // 2. Solo ahora sube el documento
          String? urlDocumento;
          if (_archivoSeleccionado != null && _nombreArchivo != null) {
            urlDocumento =
                await subirDocumento(_archivoSeleccionado!, _nombreArchivo!);
          }
          _guardarBase(urlDocumento);
        } catch (e) {
          print(e);
        }
        Limpiar();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al guardar el proveedor'),
          ),
        );
      }
    } catch (e) {
      print(e);
    }
  }

  void _guardarBase(String? url) async {
    if (!mounted) return;
    await supabase.from('Proveedores').insert({
      'rubro': _rubro.text,
      'nombre': _nombre.text,
      'marca_id': int.parse(_selectedMarca!),
      'familia_id': int.parse(_selectedFamilia!),
      'linea_id': int.parse(_selectedLinea!),
      'descripcion': _descripcion.text,
      'codigo_sat': int.parse(_codigoSAT.text),
      'precios': url ?? '',
      'deshabilitado': true,
    });
  }

  // Suponiendo que ya tienes el archivo como File
  Future<String?> subirDocumento(File archivo, String nombreArchivo) async {
    final storage = Supabase.instance.client.storage;
    final bucket = storage.from('precios-provee');

    final response = await bucket.upload(
      'precios-provee/$nombreArchivo',
      archivo,
      fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
    );

    if (response != null) {
      return bucket.getPublicUrl('precios-provee/$nombreArchivo');
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Registrar Proveedor',
          style: TextStyle(
            color: ProyectColors.primaryGreen,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        //Nombre del proveedor
        TextField(
          controller: _nombre,
          style: const TextStyle(color: ProyectColors.textPrimary),
          decoration: InputDecoration(
            labelText: 'Nombre del proveedor',
            prefixIcon: Icon(Icons.label, color: ProyectColors.primaryGreen),
            labelStyle: const TextStyle(color: ProyectColors.textSecondary),
            filled: true,
            fillColor: ProyectColors.surfaceDark,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            //Rubro
            Expanded(
              child: TextField(
                controller: _rubro,
                style: const TextStyle(color: ProyectColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Rubro',
                  prefixIcon:
                      Icon(Icons.category, color: ProyectColors.primaryGreen),
                  labelStyle:
                      const TextStyle(color: ProyectColors.textSecondary),
                  filled: true,
                  fillColor: ProyectColors.surfaceDark,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 16),
            //Marca
            Expanded(
              child: DropdownButtonFormField<String>(
                style: const TextStyle(color: ProyectColors.textPrimary),
                dropdownColor: ProyectColors.surfaceDark,
                decoration: InputDecoration(
                  labelText: 'Marca',
                  prefixIcon:
                      Icon(Icons.business, color: ProyectColors.primaryGreen),
                  labelStyle:
                      const TextStyle(color: ProyectColors.textSecondary),
                  filled: true,
                  fillColor: ProyectColors.surfaceDark,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                value: _selectedMarca,
                items: _loadMarca
                    .map((item) => DropdownMenuItem<String>(
                          value: item['id'].toString(),
                          child: Text(item['nombre']),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedMarca = value;
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            //Familia
            Expanded(
              child: DropdownButtonFormField<String>(
                style: const TextStyle(color: ProyectColors.textPrimary),
                dropdownColor: ProyectColors.surfaceDark,
                decoration: InputDecoration(
                  labelText: 'Familia',
                  prefixIcon:
                      Icon(Icons.group_work, color: ProyectColors.primaryGreen),
                  labelStyle:
                      const TextStyle(color: ProyectColors.textSecondary),
                  filled: true,
                  fillColor: ProyectColors.surfaceDark,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                value: _selectedFamilia,
                items: _loadFamilia
                    .map((item) => DropdownMenuItem<String>(
                          value: item['id'].toString(),
                          child: Text(item['nombre']),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedFamilia = value;
                  });
                },
              ),
            ),
            const SizedBox(width: 16),
            //Linea
            Expanded(
              child: DropdownButtonFormField<String>(
                style: const TextStyle(color: ProyectColors.textPrimary),
                dropdownColor: ProyectColors.surfaceDark,
                decoration: InputDecoration(
                  labelText: 'Línea',
                  prefixIcon:
                      Icon(Icons.line_style, color: ProyectColors.primaryGreen),
                  labelStyle:
                      const TextStyle(color: ProyectColors.textSecondary),
                  filled: true,
                  fillColor: ProyectColors.surfaceDark,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                value: _selectedLinea,
                items: _loadLinea
                    .map((item) => DropdownMenuItem<String>(
                          value: item['id'].toString(),
                          child: Text(item['nombre']),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedLinea = value;
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        //Descripción
        TextField(
          controller: _descripcion,
          style: const TextStyle(color: ProyectColors.textPrimary),
          decoration: InputDecoration(
            labelText: 'Descripción',
            prefixIcon:
                Icon(Icons.description, color: ProyectColors.primaryGreen),
            labelStyle: const TextStyle(color: ProyectColors.textSecondary),
            filled: true,
            fillColor: ProyectColors.surfaceDark,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            //Código SAT
            Expanded(
              child: TextField(
                controller: _codigoSAT,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(8),
                  FilteringTextInputFormatter.digitsOnly,
                ],
                style: const TextStyle(color: ProyectColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Código SAT',
                  prefixIcon:
                      Icon(Icons.qr_code, color: ProyectColors.primaryGreen),
                  labelStyle:
                      const TextStyle(color: ProyectColors.textSecondary),
                  filled: true,
                  fillColor: ProyectColors.surfaceDark,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 16),
            //Precio estimado
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  FilePickerResult? result =
                      await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['pdf', 'jpg', 'png', 'docx'],
                  );

                  if (result != null && result.files.single.path != null) {
                    _archivoSeleccionado = File(result.files.single.path!);
                    _nombreArchivo = result.files.single.name;

                    // Mostrar el nombre del archivo en el campo
                    _precioEstimado.text = _nombreArchivo!;
                  }
                },
                child: AbsorbPointer(
                  child: TextField(
                    controller: _precioEstimado,
                    style: const TextStyle(color: ProyectColors.textPrimary),
                    decoration: InputDecoration(
                      labelText: 'Seleccionar Catalogo De Precios',
                      prefixIcon: Icon(Icons.attach_file,
                          color: ProyectColors.primaryGreen),
                      labelStyle:
                          const TextStyle(color: ProyectColors.textSecondary),
                      filled: true,
                      fillColor: ProyectColors.surfaceDark,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    readOnly: true,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        //Botón de guardar
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: ProyectColors.primaryGreen,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              _guardar();
            },
            icon: const Icon(Icons.save, color: ProyectColors.backgroundDark),
            label: const Text(
              'Guardar Proveedor',
              style: TextStyle(
                color: ProyectColors.backgroundDark,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void Limpiar() {
    _nombre.clear();
    _rubro.clear();
    _descripcion.clear();
    _codigoSAT.clear();
    _precioEstimado.clear();
    if (!mounted) return;
    setState(() {
      _selectedMarca = null;
      _selectedFamilia = null;
      _selectedLinea = null;
    });
  }

  bool restricciones() {
    if (_nombre.text.isEmpty ||
        _rubro.text.isEmpty ||
        _descripcion.text.isEmpty ||
        _codigoSAT.text.isEmpty ||
        _precioEstimado.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor complete todos los campos'),
        ),
      );
      return false;
    }

    if (_selectedMarca == null ||
        _selectedFamilia == null ||
        _selectedLinea == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor seleccione todos los campos'),
        ),
      );
      return false;
    }

    final String codigo = _codigoSAT.text.trim();

    if (!RegExp(r'^\d{8}$').hasMatch(codigo)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('El código SAT debe ser un número de 8 dígitos sin signos.'),
        ),
      );
      return false;
    }

    return true;
  }
}

///////----------------Clientes Frecuentes--------------------//////
class RegistrarClienteFrecuenteFields extends StatefulWidget {
  const RegistrarClienteFrecuenteFields({super.key});

  @override
  State<RegistrarClienteFrecuenteFields> createState() =>
      _RegistrarClienteFrecuenteFieldsState();
}

class _RegistrarClienteFrecuenteFieldsState
    extends State<RegistrarClienteFrecuenteFields> {
  final TextEditingController _nombre = TextEditingController();
  final TextEditingController _apellidoPat = TextEditingController();
  final TextEditingController _apellidoMat = TextEditingController();
  final TextEditingController _numTel = TextEditingController();
  final TextEditingController _rfc = TextEditingController();
  final TextEditingController _domicilio = TextEditingController();
  final TextEditingController _regimenFiscal = TextEditingController();

  final List<Map<String, dynamic>> _clientes = [];
  File? _archivoSeleccionado;
  String? _nombreArchivo;
  final supabase = Supabase.instance.client;

  void _guardar() async {
    if (!restricciones()) return;
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      int cantidadAntes = _clientes.length;
      _clientes.add({
        'nombre': _nombre.text,
        'apellido_pat': _apellidoPat.text,
        'apellido_mat': _apellidoMat.text,
        'num_tel': _numTel.text,
        'rfc': _rfc.text,
        'domicilio': _domicilio.text,
        'regimen_fiscal': _regimenFiscal.text,
      });
      if (_clientes.length > cantidadAntes) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cliente guardado con éxito')),
        );
        try {
          // 2. Solo ahora sube el documento
          String? urlDocumento;
          if (_archivoSeleccionado != null && _nombreArchivo != null) {
            urlDocumento =
                await subirDocumento(_archivoSeleccionado!, _nombreArchivo!);
          }

          // 3. Guarda en base de datos Supabase
          _guardarBase(urlDocumento);
        } catch (e) {
          print(e);
        }

        Limpiar();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al guardar el cliente')),
        );
      }
    } else
      print('Error inicio de seccion');
  }

  void Limpiar() {
    _nombre.clear();
    _apellidoPat.clear();
    _apellidoMat.clear();
    _numTel.clear();
    _rfc.clear();
    _domicilio.clear();
    _regimenFiscal.clear();
  }

  bool restricciones() {
    if (_nombre.text.isEmpty ||
        _apellidoPat.text.isEmpty ||
        _apellidoMat.text.isEmpty ||
        _numTel.text.isEmpty ||
        _rfc.text.isEmpty ||
        _domicilio.text.isEmpty ||
        _regimenFiscal.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor complete todos los campos')),
      );
      return false;
    }
    if (int.tryParse(_numTel.text) == null || _numTel.text.length < 7) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Número de teléfono inválido')),
      );
      return false;
    }
    return true;
  }

  // Suponiendo que ya tienes el archivo como File
  Future<String?> subirDocumento(File archivo, String nombreArchivo) async {
    final storage = Supabase.instance.client.storage;
    final bucket = storage.from('fiscales');

    final response = await bucket.upload(
      'regimenes/$nombreArchivo',
      archivo,
      fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
    );

    if (response != null) {
      return bucket.getPublicUrl('regimenes/$nombreArchivo');
    } else {
      return null;
    }
  }

  void _guardarBase(String? urlDocumento) async {
    if (!mounted) return;
    await supabase.from('Cliente_frec').insert({
      'nombre': _nombre.text,
      'apellido_pat': _apellidoPat.text,
      'apellido_mat': _apellidoMat.text,
      'num_tel': _numTel.text,
      'rfc': _rfc.text,
      'domicilio': _domicilio.text,
      'regimen_fiscal': urlDocumento ?? '', // Guarda la URL del documento
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Registrar Cliente Frecuente',
          style: TextStyle(
            color: ProyectColors.primaryGreen,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _nombre,
                style: const TextStyle(color: ProyectColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Nombre',
                  prefixIcon:
                      Icon(Icons.person, color: ProyectColors.primaryGreen),
                  labelStyle:
                      const TextStyle(color: ProyectColors.textSecondary),
                  filled: true,
                  fillColor: ProyectColors.surfaceDark,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: _apellidoPat,
                style: const TextStyle(color: ProyectColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Apellido paterno',
                  prefixIcon: Icon(Icons.person_outline,
                      color: ProyectColors.primaryGreen),
                  labelStyle:
                      const TextStyle(color: ProyectColors.textSecondary),
                  filled: true,
                  fillColor: ProyectColors.surfaceDark,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: _apellidoMat,
                style: const TextStyle(color: ProyectColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Apellido materno',
                  prefixIcon: Icon(Icons.person_outline,
                      color: ProyectColors.primaryGreen),
                  labelStyle:
                      const TextStyle(color: ProyectColors.textSecondary),
                  filled: true,
                  fillColor: ProyectColors.surfaceDark,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _numTel,
                style: const TextStyle(color: ProyectColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Número de teléfono',
                  prefixIcon:
                      Icon(Icons.phone, color: ProyectColors.primaryGreen),
                  labelStyle:
                      const TextStyle(color: ProyectColors.textSecondary),
                  filled: true,
                  fillColor: ProyectColors.surfaceDark,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly, // Solo números
                  LengthLimitingTextInputFormatter(10), // Máximo 10 dígitos
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: _rfc,
                style: const TextStyle(color: ProyectColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'RFC',
                  prefixIcon:
                      Icon(Icons.badge, color: ProyectColors.primaryGreen),
                  labelStyle:
                      const TextStyle(color: ProyectColors.textSecondary),
                  filled: true,
                  fillColor: ProyectColors.surfaceDark,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _domicilio,
          style: const TextStyle(color: ProyectColors.textPrimary),
          decoration: InputDecoration(
            labelText: 'Domicilio',
            prefixIcon: Icon(Icons.home, color: ProyectColors.primaryGreen),
            labelStyle: const TextStyle(color: ProyectColors.textSecondary),
            filled: true,
            fillColor: ProyectColors.surfaceDark,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () async {
            FilePickerResult? result = await FilePicker.platform.pickFiles(
              type: FileType.custom,
              allowedExtensions: ['pdf', 'jpg', 'png', 'docx'],
            );

            if (result != null && result.files.single.path != null) {
              _archivoSeleccionado = File(result.files.single.path!);
              _nombreArchivo = result.files.single.name;

              // Mostrar el nombre del archivo en el campo
              _regimenFiscal.text = _nombreArchivo!;
            }
          },
          child: AbsorbPointer(
            child: TextField(
              enabled: false,
              controller: _regimenFiscal,
              style: const TextStyle(color: ProyectColors.textPrimary),
              decoration: InputDecoration(
                labelText: 'Régimen fiscal',
                prefixIcon: Icon(Icons.account_balance,
                    color: ProyectColors.primaryGreen),
                labelStyle: const TextStyle(color: ProyectColors.textSecondary),
                filled: true,
                fillColor: ProyectColors.surfaceDark,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: ProyectColors.primaryGreen,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _guardar,
            icon: const Icon(Icons.save, color: ProyectColors.backgroundDark),
            label: const Text(
              'Guardar Cliente',
              style: TextStyle(
                color: ProyectColors.backgroundDark,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

///////----------------Etiquetas productos--------------------//////
class EtiquetasProductosFields extends StatefulWidget {
  const EtiquetasProductosFields({super.key});

  @override
  State<EtiquetasProductosFields> createState() =>
      _EtiquetasProductosFieldsState();
}

class _EtiquetasProductosFieldsState extends State<EtiquetasProductosFields>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  //controller
  final ScrollController _scrollController = ScrollController();
  final ScrollController _scrollControllerFamilias = ScrollController();
  final ScrollController _scrollControllerMarca = ScrollController();

  // Línea
  final TextEditingController _lineaNombre = TextEditingController();
  List<Map<String, dynamic>> _lineas = [];

  // Familia
  final TextEditingController _familiaNombre = TextEditingController();
  final TextEditingController _familiaPrefijo = TextEditingController();
  List<Map<String, dynamic>> _familias = [];

  // Marca
  final TextEditingController _marcaNombre = TextEditingController();
  List<Map<String, dynamic>> _marcas = [];

  List<String> _prefijosExistentes = [];

  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    if (!mounted) return;
    _tabController = TabController(length: 3, vsync: this);
    _initAsync();
  }

  Future<void> _initAsync() async {
    if (!mounted) return;
    await loadDatos();
    await _cargarFamilias();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _lineaNombre.dispose();
    _familiaNombre.dispose();
    _familiaPrefijo.dispose();
    _marcaNombre.dispose();
    super.dispose();
  }

  Future<void> _cargarFamilias() async {
    final responseFamilias =
        await supabase.from('Familia').select('id, nombre, prefijo');
    if (responseFamilias is List) {
      if (!mounted) return;
      setState(() {
        _familias = responseFamilias
            .map<Map<String, dynamic>>((f) => {
                  'id': f['id'],
                  'nombre': f['nombre'],
                  'prefijo': f['prefijo'],
                })
            .toList();
        _prefijosExistentes =
            _familias.map((f) => f['prefijo'] as String).toList();
      });
    }
  }

  void _guardarLinea() async {
    if (_lineaNombre.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor ingresa el nombre de la línea')),
      );
      return;
    }
    int cont = _lineas.length;
    if (!mounted) return;
    setState(() {
      _lineas.add({'nombre': _lineaNombre.text.trim()});
    });
    if (cont < _lineas.length) {
      await supabase.from('Linea').insert({'nombre': _lineaNombre.text.trim()});
    }
    _lineaNombre.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Línea guardada con éxito')),
    );
  }

  void _guardarFamilia() async {
    final nuevoPrefijo = '${_familiaPrefijo.text.trim()}-';

    if (_familiaNombre.text.trim().isEmpty ||
        _familiaPrefijo.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor completa todos los campos de familia')),
      );
      return;
    }

    // Verificar si el prefijo ya existe
    if (_prefijosExistentes.contains(nuevoPrefijo)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('El prefijo "$nuevoPrefijo" ya existe.')),
      );
      return;
    }

    int cont = _familias.length;
    if (!mounted) return;
    setState(() {
      _familias.add({
        'nombre': _familiaNombre.text.trim(),
        'prefijo': nuevoPrefijo,
      });
      _prefijosExistentes
          .add(nuevoPrefijo); // Actualizamos la lista de prefijos
    });

    if (cont < _familias.length) {
      await supabase.from('Familia').insert({
        'nombre': _familiaNombre.text.trim(),
        'prefijo': nuevoPrefijo,
      });
    }

    _familiaNombre.clear();
    _familiaPrefijo.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Familia guardada con éxito')),
    );
  }

  void _guardarMarca() async {
    if (_marcaNombre.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor ingresa el nombre de la marca')),
      );
      return;
    }
    int cont = _marcas.length;
    if (!mounted) return;
    setState(() {
      _marcas.add({'nombre': _marcaNombre.text.trim()});
    });
    if (cont < _marcas.length) {
      await supabase.from('Marca').insert({
        'nombre': _marcaNombre.text.trim(),
      });
    }
    _marcaNombre.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Marca guardada con éxito')),
    );
  }

  void _modificarLinea(Map<String, dynamic> linea) {
    final TextEditingController nombreController =
        TextEditingController(text: linea['nombre']);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ProyectColors.surfaceDark,
        title: const Text('Editar Línea',
            style: TextStyle(color: ProyectColors.primaryGreen)),
        content: TextField(
          controller: nombreController,
          decoration: const InputDecoration(
              labelText: 'Nombre',
              labelStyle: TextStyle(color: ProyectColors.textSecondary)),
          style: TextStyle(color: ProyectColors.textPrimary),
        ),
        actions: [
          ElevatedButton.icon(
            style: TextButton.styleFrom(
                backgroundColor: ProyectColors.primaryGreen),
            onPressed: () => Navigator.pop(ctx),
            icon: Icon(Icons.close, color: ProyectColors.backgroundDark),
            label: const Text('Cancelar',
                style: TextStyle(color: ProyectColors.backgroundDark)),
          ),
          ElevatedButton.icon(
            style: TextButton.styleFrom(
                backgroundColor: ProyectColors.primaryGreen),
            onPressed: () async {
              final nuevoNombre = nombreController.text.trim();
              if (nuevoNombre.isEmpty) return;

              await supabase
                  .from('Linea')
                  .update({'nombre': nuevoNombre}).eq('id', linea['id']);
              Navigator.pop(ctx);
              await loadDatos();
            },
            icon: Icon(Icons.check, color: ProyectColors.backgroundDark),
            label: const Text('Aceptar',
                style: TextStyle(color: ProyectColors.backgroundDark)),
          ),
        ],
      ),
    );
  }

  void _modificarFamilia(Map<String, dynamic> familia) {
    final nombreController = TextEditingController(text: familia['nombre']);
    final prefijoController = TextEditingController(
        text: familia['prefijo'].toString().replaceAll('-', ''));

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ProyectColors.surfaceDark,
        title: const Text('Editar Familia',
            style: TextStyle(color: ProyectColors.primaryGreen)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nombreController,
              decoration: const InputDecoration(
                  labelText: 'Nombre',
                  labelStyle: TextStyle(color: ProyectColors.textSecondary)),
              style: TextStyle(color: ProyectColors.textPrimary),
            ),
            TextField(
              controller: prefijoController,
              decoration: const InputDecoration(
                  labelText: 'Prefijo',
                  labelStyle: TextStyle(color: ProyectColors.textSecondary)),
            ),
          ],
        ),
        actions: [
          ElevatedButton.icon(
            style: TextButton.styleFrom(
                backgroundColor: ProyectColors.primaryGreen),
            onPressed: () => Navigator.pop(ctx),
            icon: Icon(Icons.close, color: ProyectColors.backgroundDark),
            label: const Text('Cancelar',
                style: TextStyle(color: ProyectColors.backgroundDark)),
          ),
          ElevatedButton.icon(
            style: TextButton.styleFrom(
                backgroundColor: ProyectColors.primaryGreen),
            onPressed: () async {
              final nuevoNombre = nombreController.text.trim();
              final nuevoPrefijo = '${prefijoController.text.trim()}-';

              if (nuevoNombre.isEmpty || nuevoPrefijo.isEmpty) return;

              if (_prefijosExistentes.contains(nuevoPrefijo) &&
                  nuevoPrefijo != familia['prefijo']) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('El prefijo "$nuevoPrefijo" ya existe.')),
                );
                return;
              }

              await supabase.from('Familia').update({
                'nombre': nuevoNombre,
                'prefijo': nuevoPrefijo,
              }).eq('id', familia['id']);
              Navigator.pop(ctx);
              await _cargarFamilias();
            },
            icon: Icon(Icons.check, color: ProyectColors.backgroundDark),
            label: const Text('Aceptar',
                style: TextStyle(color: ProyectColors.backgroundDark)),
          ),
        ],
      ),
    );
  }

  void _modificarMarca(Map<String, dynamic> marca) {
    final TextEditingController nombreController =
        TextEditingController(text: marca['nombre']);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ProyectColors.surfaceDark,
        title: const Text('Editar Marca',
            style: TextStyle(color: ProyectColors.primaryGreen)),
        content: TextField(
          controller: nombreController,
          decoration: const InputDecoration(
              labelText: 'Nombre',
              labelStyle: TextStyle(color: ProyectColors.textSecondary)),
        ),
        actions: [
          ElevatedButton.icon(
            style: TextButton.styleFrom(
                backgroundColor: ProyectColors.primaryGreen),
            onPressed: () => Navigator.pop(ctx),
            icon: Icon(Icons.close, color: ProyectColors.backgroundDark),
            label: const Text('Cancelar',
                style: TextStyle(color: ProyectColors.backgroundDark)),
          ),
          ElevatedButton.icon(
            style: TextButton.styleFrom(
                backgroundColor: ProyectColors.primaryGreen),
            onPressed: () async {
              final nuevoNombre = nombreController.text.trim();
              if (nuevoNombre.isEmpty) return;

              await supabase
                  .from('Marca')
                  .update({'nombre': nuevoNombre}).eq('id', marca['id']);
              Navigator.pop(ctx);
              await loadDatos();
            },
            icon: Icon(Icons.check, color: ProyectColors.backgroundDark),
            label: const Text('Aceptar',
                style: TextStyle(color: ProyectColors.backgroundDark)),
          ),
        ],
      ),
    );
  }

  void _eliminarLinea(Map<String, dynamic> linea) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ProyectColors.surfaceDark,
        title: const Text(
          'Confirmar',
          style: const TextStyle(color: ProyectColors.primaryGreen),
        ),
        content: Text(
          '¿Eliminar la línea "${linea['nombre']}"?',
          style: const TextStyle(color: ProyectColors.textPrimary),
        ),
        actions: [
          ElevatedButton.icon(
            style: TextButton.styleFrom(
                backgroundColor: ProyectColors.primaryGreen),
            label: const Text(
              'Cancelar',
              style: const TextStyle(color: ProyectColors.backgroundDark),
            ),
            onPressed: () => Navigator.pop(ctx, false),
            icon: Icon(Icons.close, color: ProyectColors.backgroundDark),
          ),
          ElevatedButton.icon(
            style: TextButton.styleFrom(backgroundColor: ProyectColors.danger),
            label: const Text(
              'Eliminar',
              style: const TextStyle(color: ProyectColors.backgroundDark),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            icon: Icon(
              Icons.delete,
              color: ProyectColors.backgroundDark,
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await supabase.from('Linea').delete().eq('id', linea['id']);
      await loadDatos();
    }
  }

  void _eliminarFamilia(Map<String, dynamic> familia) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ProyectColors.surfaceDark,
        title: const Text('Confirmar',
            style: TextStyle(color: ProyectColors.primaryGreen)),
        content: Text('¿Eliminar la familia "${familia['nombre']}"?',
            style: TextStyle(color: ProyectColors.textPrimary)),
        actions: [
          ElevatedButton.icon(
            style: TextButton.styleFrom(
                backgroundColor: ProyectColors.primaryGreen),
            onPressed: () => Navigator.pop(ctx, false),
            icon: Icon(Icons.close, color: ProyectColors.backgroundDark),
            label: const Text('Cancelar',
                style: TextStyle(color: ProyectColors.backgroundDark)),
          ),
          ElevatedButton.icon(
            style: TextButton.styleFrom(backgroundColor: ProyectColors.danger),
            onPressed: () => Navigator.pop(ctx, true),
            icon: Icon(Icons.delete, color: ProyectColors.backgroundDark),
            label: const Text('Eliminar',
                style: TextStyle(color: ProyectColors.backgroundDark)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await supabase.from('Familia').delete().eq('id', familia['id']);
      await _cargarFamilias();
    }
  }

  void _eliminarMarca(Map<String, dynamic> marca) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ProyectColors.surfaceDark,
        title: const Text('Confirmar',
            style: TextStyle(color: ProyectColors.primaryGreen)),
        content: Text('¿Eliminar la marca "${marca['nombre']}"?',
            style: TextStyle(color: ProyectColors.textPrimary)),
        actions: [
          ElevatedButton.icon(
            style: TextButton.styleFrom(
                backgroundColor: ProyectColors.primaryGreen),
            onPressed: () => Navigator.pop(ctx, false),
            icon: Icon(Icons.close, color: ProyectColors.backgroundDark),
            label: const Text('Cancelar',
                style: TextStyle(color: ProyectColors.backgroundDark)),
          ),
          ElevatedButton.icon(
            style: TextButton.styleFrom(backgroundColor: ProyectColors.danger),
            onPressed: () => Navigator.pop(ctx, true),
            icon: Icon(Icons.delete, color: ProyectColors.backgroundDark),
            label: const Text('Eliminar',
                style: TextStyle(color: ProyectColors.backgroundDark)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await supabase.from('Marca').delete().eq('id', marca['id']);
      await loadDatos();
    }
  }

  Future<void> loadDatos() async {
    final responseLineas = await supabase.from('Linea').select('id, nombre');
    final responseFamilias =
        await supabase.from('Familia').select('id, nombre, prefijo');
    final responseMarcas = await supabase.from('Marca').select('id, nombre');

    // Asegúrate de que las respuestas sean listas antes de asignarlas
    if (responseLineas is List &&
        responseFamilias is List &&
        responseMarcas is List) {
      if (!mounted) return;
      setState(() {
        _lineas = List<Map<String, dynamic>>.from(responseLineas);
        _familias = List<Map<String, dynamic>>.from(responseFamilias);
        _marcas = List<Map<String, dynamic>>.from(responseMarcas);
      });
    } else {
      // Manejo de errores si alguna respuesta falla
      print('Error al cargar datos desde Supabase');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Etiquetas de Productos',
          style: TextStyle(
            color: ProyectColors.primaryGreen,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        TabBar(
          controller: _tabController,
          indicatorColor: ProyectColors.primaryGreen,
          labelColor: ProyectColors.primaryGreen,
          unselectedLabelColor: ProyectColors.textSecondary,
          tabs: const [
            Tab(text: 'Línea'),
            Tab(text: 'Familia'),
            Tab(text: 'Marca'),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Línea
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextField(
                    controller: _lineaNombre,
                    style: const TextStyle(color: ProyectColors.textPrimary),
                    decoration: InputDecoration(
                      labelText: 'Nombre de la línea',
                      prefixIcon: Icon(Icons.view_stream,
                          color: ProyectColors.primaryGreen),
                      labelStyle:
                          const TextStyle(color: ProyectColors.textSecondary),
                      filled: true,
                      fillColor: ProyectColors.surfaceDark,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  //button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ProyectColors.primaryGreen,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _guardarLinea,
                      icon: const Icon(Icons.save,
                          color: ProyectColors.backgroundDark),
                      label: const Text(
                        'Guardar Línea',
                        style: TextStyle(
                          color: ProyectColors.backgroundDark,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_lineas.isNotEmpty)
                    Expanded(
                      child: Container(
                        height: 800,
                        decoration: BoxDecoration(
                          color: ProyectColors.surfaceDark,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: RawScrollbar(
                          thumbColor: ProyectColors.primaryGreen,
                          controller: _scrollController,
                          thumbVisibility: true,
                          radius: const Radius.circular(8),
                          thickness: 6,
                          child: GridView.builder(
                            controller: _scrollController,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: 3,
                            ),
                            padding: const EdgeInsets.all(12),
                            itemCount: _lineas.length,
                            itemBuilder: (context, index) {
                              final linea = _lineas[index];
                              return Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: ProyectColors.backgroundDark,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: ProyectColors.primaryGreen),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.view_stream,
                                        color: ProyectColors.primaryGreen),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        linea['nombre'] ?? '',
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            color: ProyectColors.textPrimary),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () => _modificarLinea(linea),
                                      child: Icon(
                                        Icons.edit,
                                        color: ProyectColors.warning,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () => _eliminarLinea(linea),
                                      child: Icon(
                                        Icons.delete,
                                        color: ProyectColors.danger,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    )
                ],
              ),
              // Familia
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _familiaNombre,
                    style: const TextStyle(color: ProyectColors.textPrimary),
                    decoration: InputDecoration(
                      labelText: 'Nombre de la familia',
                      prefixIcon: Icon(Icons.family_restroom,
                          color: ProyectColors.primaryGreen),
                      labelStyle:
                          const TextStyle(color: ProyectColors.textSecondary),
                      filled: true,
                      fillColor: ProyectColors.surfaceDark,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _familiaPrefijo,
                    style: const TextStyle(color: ProyectColors.textPrimary),
                    decoration: InputDecoration(
                      labelText: 'Prefijo',
                      prefixIcon: Icon(Icons.short_text,
                          color: ProyectColors.primaryGreen),
                      labelStyle:
                          const TextStyle(color: ProyectColors.textSecondary),
                      filled: true,
                      fillColor: ProyectColors.surfaceDark,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ProyectColors.primaryGreen,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _guardarFamilia,
                      icon: const Icon(Icons.save,
                          color: ProyectColors.backgroundDark),
                      label: const Text(
                        'Guardar Familia',
                        style: TextStyle(
                          color: ProyectColors.backgroundDark,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_familias.isNotEmpty)
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: ProyectColors.surfaceDark,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: RawScrollbar(
                          controller: _scrollControllerFamilias,
                          thumbColor: ProyectColors.primaryGreen,
                          thumbVisibility: true,
                          radius: const Radius.circular(8),
                          thickness: 6,
                          child: GridView.builder(
                            controller: _scrollControllerFamilias,
                            padding: const EdgeInsets.all(12),
                            itemCount: _familias.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount:
                                  3, // Puedes cambiar a 5 si prefieres más columnas
                              crossAxisSpacing: 4,
                              mainAxisSpacing: 4,
                              childAspectRatio: 2.2,
                            ),
                            itemBuilder: (context, index) {
                              final familia = _familias[index];
                              return Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: ProyectColors.backgroundDark,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: ProyectColors.primaryGreen),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.family_restroom,
                                            color: ProyectColors.primaryGreen),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            familia['nombre'] ?? '',
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                color:
                                                    ProyectColors.textPrimary,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            _modificarFamilia(familia);
                                          },
                                          child: Icon(
                                            Icons.edit,
                                            color: ProyectColors.warning,
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            _eliminarFamilia(familia);
                                          },
                                          child: Icon(
                                            Icons.delete,
                                            color: ProyectColors.danger,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Prefijo: ${familia['prefijo']}',
                                      style: const TextStyle(
                                          color: ProyectColors.textSecondary,
                                          fontSize: 12),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              // Marca
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _marcaNombre,
                    style: const TextStyle(color: ProyectColors.textPrimary),
                    decoration: InputDecoration(
                      labelText: 'Nombre de la marca',
                      prefixIcon: Icon(Icons.business,
                          color: ProyectColors.primaryGreen),
                      labelStyle:
                          const TextStyle(color: ProyectColors.textSecondary),
                      filled: true,
                      fillColor: ProyectColors.surfaceDark,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ProyectColors.primaryGreen,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _guardarMarca,
                      icon: const Icon(Icons.save,
                          color: ProyectColors.backgroundDark),
                      label: const Text(
                        'Guardar Marca',
                        style: TextStyle(
                          color: ProyectColors.backgroundDark,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_marcas.isNotEmpty)
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: ProyectColors.surfaceDark,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: RawScrollbar(
                          controller: _scrollControllerMarca,
                          thumbColor: ProyectColors.primaryGreen,
                          thumbVisibility: true,
                          radius: const Radius.circular(8),
                          thickness: 6,
                          child: GridView.builder(
                            controller: _scrollControllerMarca,
                            padding: const EdgeInsets.all(12),
                            itemCount: _marcas.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3, // 4 columnas
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: 3,
                            ),
                            itemBuilder: (context, index) {
                              final marca = _marcas[index];
                              return Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: ProyectColors.backgroundDark,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: ProyectColors.primaryGreen),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.business,
                                        color: ProyectColors.primaryGreen),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        marca['nombre'] ?? '',
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: ProyectColors.textPrimary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        _modificarMarca(marca);
                                      },
                                      child: Icon(
                                        Icons.edit,
                                        color: ProyectColors.warning,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        _eliminarMarca(marca);
                                      },
                                      child: Icon(
                                        Icons.delete,
                                        color: ProyectColors.danger,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
