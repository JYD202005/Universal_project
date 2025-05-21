import 'package:flutter/material.dart';
import 'package:base_de_datos_universal/colours/colours.dart';

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

  // cargar dropdown de marcas, familias, líneas y proveedores
  List<Map<String, dynamic>> _loadMarca = [];
  String? _selectedMarca;
  List<Map<String, dynamic>> _loadFamilia = [];
  String? _selectedFamilia;
  List<Map<String, dynamic>> _loadLinea = [];
  String? _selectedLinea;
  List<Map<String, dynamic>> _loadProveedor = [];
  String? _selectedProveedor;

  //Lista Para guardar los artículos
  final List<Map<String, dynamic>> _guardardo = [];

  //Metodo para cargar los dropdowns
  //cambiar lo de adentro por las variables de la base de datos
  void _loadDrops() async {
    _loadMarca = [
      {'id': 1, 'name': 'Marca 1'},
      {'id': 2, 'name': 'Marca 2'},
      {'id': 3, 'name': 'Marca 3'},
    ];
    _loadFamilia = [
      {'id': 1, 'name': 'Familia 1', 'Prefijo': 'L-'},
      {'id': 2, 'name': 'Familia 2', 'Prefijo': 'G-'},
      {'id': 3, 'name': 'Familia 3', 'Prefijo': 'H-'}
    ];
    _loadLinea = [
      {'id': 1, 'name': 'Línea 1'},
      {'id': 2, 'name': 'Línea 2'},
      {'id': 3, 'name': 'Línea 3'},
    ];
    _loadProveedor = [
      {'id': 1, 'name': 'Proveedor 1'},
      {'id': 2, 'name': 'Proveedor 2'},
      {'id': 3, 'name': 'Proveedor 3'},
    ];
  }

  //Guardar el artículo
  void _guardarArticulo() async {
    try {
      if (!restricciones()) return;

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
      // Obtener el prefijo según la familia seleccionada
      final familiaSeleccionada = _loadFamilia.firstWhere(
        (familia) => familia['id'].toString() == _selectedFamilia,
      );
      String prefijo = familiaSeleccionada['Prefijo'];

      // Contar cuántas claves ya existen con ese prefijo
      int maxNumero = 0;
      for (var item in _guardardo) {
        final clave = item['Clave'];
        if (clave != null && clave.toString().startsWith(prefijo)) {
          final partes = clave.split('-');
          if (partes.length == 2) {
            final numero = int.tryParse(partes[1]);
            if (numero != null && numero > maxNumero) {
              maxNumero = numero;
            }
          }
        }
      }
      int cantidadAntes = _guardardo.length;
      // Generar nueva clave
      final nuevaClave = '$prefijo${maxNumero + 1}';

      int actual = int.parse(_cantidad.text);
      int minimo = int.parse(_minimaController.text);

      String estado;
      if (actual * 2 <= minimo) {
        estado = 'Crítico';
      } else if (actual < minimo) {
        estado = 'Bajo';
      } else {
        estado = 'Óptimo';
      }

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
        'Estado': estado,
        'Disponible': true,
      });
      // Verificar si se guardó
      if (_guardardo.length > cantidadAntes) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Artículo guardado con éxito'),
          ),
        );
        print(_guardardo);
        Limpiar();
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

  void Limpiar() {
    _nombre.clear();
    _precio.clear();
    _cantidad.clear();
    _codigo.clear();
    _minimaController.clear();
    setState(() {
      _selectedMarca = null;
      _selectedFamilia = null;
      _selectedLinea = null;
      _selectedProveedor = null;
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
    _loadDrops();
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
                          child: Text(item['name']),
                        ))
                    .toList(),
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
                          child: Text(item['name']),
                        ))
                    .toList(),
                style: const TextStyle(color: ProyectColors.textPrimary),
                dropdownColor: ProyectColors.surfaceDark,
                decoration: InputDecoration(
                  labelText: 'Línea',
                  prefixIcon:
                      Icon(Icons.category, color: ProyectColors.primaryGreen),
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
                          child: Text(item['name']),
                        ))
                    .toList(),
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
                          child: Text(item['name']),
                        ))
                    .toList(),
                style: const TextStyle(color: ProyectColors.textPrimary),
                dropdownColor: ProyectColors.surfaceDark,
                decoration: InputDecoration(
                  labelText: 'Proveedor',
                  prefixIcon: Icon(Icons.local_shipping,
                      color: ProyectColors.primaryGreen),
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
          decoration: InputDecoration(
            labelText: 'Código de barras',
            prefixIcon: Icon(Icons.qr_code, color: ProyectColors.primaryGreen),
            labelStyle: const TextStyle(color: ProyectColors.textSecondary),
            filled: true,
            fillColor: ProyectColors.surfaceDark,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
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
  String? _selectedArticulo;
  int _cantidad = 1;
  final TextEditingController _cantidadController = TextEditingController(text: '1');
  final List<Map<String, dynamic>> _carrito = [];

  // Artículos simulados
  final List<Map<String, dynamic>> _articulos = [
    {'id': '1', 'nombre': 'Cable UTP', 'precio': 50.0},
    {'id': '2', 'nombre': 'Router TP-Link', 'precio': 800.0},
    {'id': '3', 'nombre': 'Arduino UNO', 'precio': 350.0},
  ];

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

  double get _precioUnitario {
    final articulo = _articulos.firstWhere(
      (a) => a['id'] == _selectedArticulo,
      orElse: () => {},
    );
    return articulo['precio'] ?? 0.0;
  }

  String get _nombreArticulo {
    final articulo = _articulos.firstWhere(
      (a) => a['id'] == _selectedArticulo,
      orElse: () => {},
    );
    return articulo['nombre'] ?? '';
  }

  double get _precioTotal {
    double total = 0.0;
    for (var item in _carrito) {
      total += (item['precio'] as double) * (item['cantidad'] as int);
    }
    return total;
  }

  void _agregarAlCarrito() {
    final parsedCantidad = int.tryParse(_cantidadController.text);
    if (_selectedArticulo == null || parsedCantidad == null || parsedCantidad <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un artículo y cantidad válida')),
      );
      return;
    }
    setState(() {
      _cantidad = parsedCantidad;
      final index = _carrito.indexWhere((item) => item['id'] == _selectedArticulo);
      if (index >= 0) {
        _carrito[index]['cantidad'] += _cantidad;
      } else {
        _carrito.add({
          'id': _selectedArticulo,
          'nombre': _nombreArticulo,
          'precio': _precioUnitario,
          'cantidad': _cantidad,
        });
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Método de pago',
            style: TextStyle(color: ProyectColors.primaryGreen, fontWeight: FontWeight.bold),
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
                        labelStyle: const TextStyle(color: ProyectColors.textPrimary),
                        filled: true,
                        fillColor: ProyectColors.surfaceDark,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: _metodosPago
                          .map((metodo) => DropdownMenuItem<String>(
                                value: metodo,
                                child: Text(metodo, style: const TextStyle(color: ProyectColors.textPrimary)),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setModalState(() {
                          _metodoPagoSeleccionado = value;
                        });
                        setState(() {
                          _metodoPagoSeleccionado = value;
                        });
                      },
                    ),
                    if (_metodoPagoSeleccionado == 'Tarjeta Visa') ...[
                      const SizedBox(height: 16),
                      TextField(
                        controller: _numeroTarjeta,
                        style: const TextStyle(color: ProyectColors.textPrimary),
                        decoration: InputDecoration(
                          labelText: 'Número de la tarjeta',
                          prefixIcon: Icon(Icons.credit_card, color: ProyectColors.primaryGreen),
                          labelStyle: const TextStyle(color: ProyectColors.textPrimary),
                          filled: true,
                          fillColor: ProyectColors.surfaceDark,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                              style: const TextStyle(color: ProyectColors.textPrimary),
                              decoration: InputDecoration(
                                labelText: 'Vencimiento (MM/YYYY)',
                                prefixIcon: Icon(Icons.date_range, color: ProyectColors.primaryGreen),
                                labelStyle: const TextStyle(color: ProyectColors.textPrimary),
                                filled: true,
                                fillColor: ProyectColors.surfaceDark,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                hintText: 'MM/YYYY',
                                hintStyle: const TextStyle(color: ProyectColors.textSecondary),
                              ),
                              keyboardType: TextInputType.datetime,
                              maxLength: 7,
                              onChanged: (value) {
                                // Formato automático MM/YYYY
                                if (value.length == 2 && !_fechaVencimiento.text.contains('/')) {
                                  _fechaVencimiento.text = '$value/';
                                  _fechaVencimiento.selection = TextSelection.fromPosition(
                                    TextPosition(offset: _fechaVencimiento.text.length),
                                  );
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: _cvv,
                              style: const TextStyle(color: ProyectColors.textPrimary),
                              decoration: InputDecoration(
                                labelText: 'CVV',
                                prefixIcon: Icon(Icons.lock, color: ProyectColors.primaryGreen),
                                labelStyle: const TextStyle(color: ProyectColors.textPrimary),
                                filled: true,
                                fillColor: ProyectColors.surfaceDark,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                        style: const TextStyle(color: ProyectColors.textPrimary),
                        decoration: InputDecoration(
                          labelText: 'Nombre del titular',
                          prefixIcon: Icon(Icons.person, color: ProyectColors.primaryGreen),
                          labelStyle: const TextStyle(color: ProyectColors.textPrimary),
                          filled: true,
                          fillColor: ProyectColors.surfaceDark,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _direccion,
                        style: const TextStyle(color: ProyectColors.textPrimary),
                        decoration: InputDecoration(
                          labelText: 'Dirección de facturación',
                          prefixIcon: Icon(Icons.home, color: ProyectColors.primaryGreen),
                          labelStyle: const TextStyle(color: ProyectColors.textPrimary),
                          filled: true,
                          fillColor: ProyectColors.surfaceDark,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _correo,
                        style: const TextStyle(color: ProyectColors.textPrimary),
                        decoration: InputDecoration(
                          labelText: 'Correo electrónico',
                          prefixIcon: Icon(Icons.email, color: ProyectColors.primaryGreen),
                          labelStyle: const TextStyle(color: ProyectColors.textPrimary),
                          filled: true,
                          fillColor: ProyectColors.surfaceDark,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _telefono,
                        style: const TextStyle(color: ProyectColors.textPrimary),
                        decoration: InputDecoration(
                          labelText: 'Teléfono',
                          prefixIcon: Icon(Icons.phone, color: ProyectColors.primaryGreen),
                          labelStyle: const TextStyle(color: ProyectColors.textPrimary),
                          filled: true,
                          fillColor: ProyectColors.surfaceDark,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ProyectColors.primaryGreen,
              ),
              child: const Text('Aceptar', style: TextStyle(color: ProyectColors.backgroundDark)),
              onPressed: () {
                if (_metodoPagoSeleccionado == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Selecciona un método de pago')),
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
                      const SnackBar(content: Text('Número de tarjeta inválido')),
                    );
                    return;
                  }
                  if (!vencimientoRegex.hasMatch(venc)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Fecha de vencimiento inválida. Usa MM/YYYY')),
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
                      const SnackBar(content: Text('Nombre del titular requerido')),
                    );
                    return;
                  }
                  if (!emailRegex.hasMatch(correo)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Correo electrónico inválido')),
                    );
                    return;
                  }
                  // Puedes agregar más validaciones si lo deseas
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
    }
    // Si pasa todas las validaciones:
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
          DropdownButtonFormField<String>(
            value: _selectedArticulo,
            style: const TextStyle(color: ProyectColors.textPrimary),
            dropdownColor: ProyectColors.surfaceDark,
            decoration: InputDecoration(
              labelText: 'Artículo',
              prefixIcon: Icon(Icons.inventory_2, color: ProyectColors.primaryGreen),
              labelStyle: const TextStyle(color: ProyectColors.textPrimary),
              filled: true,
              fillColor: ProyectColors.surfaceDark,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            items: _articulos
                .map((art) => DropdownMenuItem<String>(
                      value: art['id'],
                      child: Text(art['nombre'], style: const TextStyle(color: ProyectColors.textPrimary)),
                    ))
                .toList(),
            onChanged: (value) {
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
                    labelText: 'Cantidad',
                    prefixIcon: Icon(Icons.confirmation_number, color: ProyectColors.primaryGreen),
                    labelStyle: const TextStyle(color: ProyectColors.textPrimary),
                    filled: true,
                    fillColor: ProyectColors.surfaceDark,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                    prefixIcon: Icon(Icons.attach_money, color: ProyectColors.primaryGreen),
                    labelStyle: const TextStyle(color: ProyectColors.textPrimary),
                    filled: true,
                    fillColor: ProyectColors.surfaceDark,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  controller: TextEditingController(
                    text: _selectedArticulo == null ? '' : _precioUnitario.toStringAsFixed(2),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _agregarAlCarrito,
              icon: const Icon(Icons.add_shopping_cart, color: ProyectColors.backgroundDark),
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
            const Text(
              'Carrito',
              style: TextStyle(
                color: ProyectColors.primaryGreen,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 90,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _carrito.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final item = _carrito[index];
                  return Card(
                    color: ProyectColors.surfaceDark,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item['nombre'], style: const TextStyle(color: ProyectColors.textPrimary, fontWeight: FontWeight.bold)),
                              Text('Cantidad: ${item['cantidad']}', style: const TextStyle(color: ProyectColors.textPrimary)),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: ProyectColors.danger),
                            tooltip: 'Eliminar',
                            onPressed: () => _eliminarDelCarrito(item['id']),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              enabled: false,
              style: const TextStyle(color: ProyectColors.textPrimary),
              decoration: InputDecoration(
                labelText: 'Precio total',
                prefixIcon: Icon(Icons.calculate, color: ProyectColors.primaryGreen),
                labelStyle: const TextStyle(color: ProyectColors.textPrimary),
                filled: true,
                fillColor: ProyectColors.surfaceDark,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              controller: TextEditingController(text: _precioTotal.toStringAsFixed(2)),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ProyectColors.primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _comprar,
                icon: const Icon(Icons.shopping_cart_checkout, color: ProyectColors.backgroundDark),
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
  //Cargar dropdown de marcas, familias y líneas
  List<Map<String, dynamic>> _loadMarca = [];
  String? _selectedMarca;
  List<Map<String, dynamic>> _loadFamilia = [];
  String? _selectedFamilia;
  List<Map<String, dynamic>> _loadLinea = [];
  String? _selectedLinea;
  //Cargar dropdown de proveedores
  void _loadDrops() async {
    _loadMarca = [
      {'id': 1, 'name': 'Marca 1'},
      {'id': 2, 'name': 'Marca 2'},
      {'id': 3, 'name': 'Marca 3'},
    ];
    _loadFamilia = [
      {'id': 1, 'name': 'Familia 1'},
      {'id': 2, 'name': 'Familia 2'},
      {'id': 3, 'name': 'Familia 3'}
    ];
    _loadLinea = [
      {'id': 1, 'name': 'Línea 1'},
      {'id': 2, 'name': 'Línea 2'},
      {'id': 3, 'name': 'Línea 3'},
    ];
  }

  //Guardar el proveedor
  final List<Map<String, dynamic>> _guardarProvee = [];

  @override
  void initState() {
    super.initState();
    _loadDrops();
  }

  void _guardar() {
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
        'PrecioEstimado': double.parse(_precioEstimado.text),
      });
      if (_guardarProvee.length > cantidadAntes) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Proveedor guardado con éxito'),
          ),
        );
        print(_guardarProvee);
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
                          child: Text(item['name']),
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
                          child: Text(item['name']),
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
                          child: Text(item['name']),
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
              child: TextField(
                controller: _precioEstimado,
                style: const TextStyle(color: ProyectColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Precio estimado',
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

    final double? precio = double.tryParse(_precioEstimado.text);

    if (precio == null || precio <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Precio deben ser números y positivo'),
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
  State<RegistrarClienteFrecuenteFields> createState() => _RegistrarClienteFrecuenteFieldsState();
}

class _RegistrarClienteFrecuenteFieldsState extends State<RegistrarClienteFrecuenteFields> {
  final TextEditingController _nombre = TextEditingController();
  final TextEditingController _apellidoPat = TextEditingController();
  final TextEditingController _apellidoMat = TextEditingController();
  final TextEditingController _numTel = TextEditingController();
  final TextEditingController _rfc = TextEditingController();
  final TextEditingController _domicilio = TextEditingController();
  final TextEditingController _regimenFiscal = TextEditingController();

  final List<Map<String, dynamic>> _clientes = [];

  void _guardar() {
    if (!restricciones()) return;
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
      Limpiar();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al guardar el cliente')),
      );
    }
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
                  prefixIcon: Icon(Icons.person, color: ProyectColors.primaryGreen),
                  labelStyle: const TextStyle(color: ProyectColors.textSecondary),
                  filled: true,
                  fillColor: ProyectColors.surfaceDark,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                  prefixIcon: Icon(Icons.person_outline, color: ProyectColors.primaryGreen),
                  labelStyle: const TextStyle(color: ProyectColors.textSecondary),
                  filled: true,
                  fillColor: ProyectColors.surfaceDark,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                  prefixIcon: Icon(Icons.person_outline, color: ProyectColors.primaryGreen),
                  labelStyle: const TextStyle(color: ProyectColors.textSecondary),
                  filled: true,
                  fillColor: ProyectColors.surfaceDark,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                  prefixIcon: Icon(Icons.phone, color: ProyectColors.primaryGreen),
                  labelStyle: const TextStyle(color: ProyectColors.textSecondary),
                  filled: true,
                  fillColor: ProyectColors.surfaceDark,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: _rfc,
                style: const TextStyle(color: ProyectColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'RFC',
                  prefixIcon: Icon(Icons.badge, color: ProyectColors.primaryGreen),
                  labelStyle: const TextStyle(color: ProyectColors.textSecondary),
                  filled: true,
                  fillColor: ProyectColors.surfaceDark,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
        TextField(
          controller: _regimenFiscal,
          style: const TextStyle(color: ProyectColors.textPrimary),
          decoration: InputDecoration(
            labelText: 'Régimen fiscal',
            prefixIcon: Icon(Icons.account_balance, color: ProyectColors.primaryGreen),
            labelStyle: const TextStyle(color: ProyectColors.textSecondary),
            filled: true,
            fillColor: ProyectColors.surfaceDark,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: ProyectColors.primaryGreen,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
