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
  List<Map<String, dynamic>> _guardardo = [];

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

///////----------------Compras--------------------//////

/*class RegistrarCompraFields extends StatelessWidget {
  const RegistrarCompraFields({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Registrar Compra',
          style: TextStyle(
            color: ProyectColors.primaryGreen,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: 'Artículo',
            prefixIcon:
                Icon(Icons.inventory_2, color: ProyectColors.primaryGreen),
            labelStyle: const TextStyle(color: ProyectColors.textSecondary),
            filled: true,
            fillColor: ProyectColors.surfaceDark,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          items: const [],
          onChanged: (_) {},
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: 'Proveedor',
            prefixIcon:
                Icon(Icons.local_shipping, color: ProyectColors.primaryGreen),
            labelStyle: const TextStyle(color: ProyectColors.textSecondary),
            filled: true,
            fillColor: ProyectColors.surfaceDark,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          items: const [],
          onChanged: (_) {},
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Cantidad comprada',
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
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Precio unitario',
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
        const SizedBox(height: 16),
        TextField(
          decoration: InputDecoration(
            labelText: 'Total acumulado',
            prefixIcon:
                Icon(Icons.calculate, color: ProyectColors.primaryGreen),
            labelStyle: const TextStyle(color: ProyectColors.textSecondary),
            filled: true,
            fillColor: ProyectColors.surfaceDark,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          keyboardType: TextInputType.number,
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
            onPressed: () {
              // Acción de guardar compra
            },
            icon: const Icon(Icons.save, color: ProyectColors.backgroundDark),
            label: const Text(
              'Guardar Compra',
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
*/
///////----------------Ventas--------------------//////
//Por Modificar
class RegistrarVentaFields extends StatefulWidget {
  const RegistrarVentaFields({super.key});

  @override
  State<RegistrarVentaFields> createState() => _RegistrarVentaFieldsState();
}

class _RegistrarVentaFieldsState extends State<RegistrarVentaFields> {
  bool _checked = false;

  @override
  Widget build(BuildContext context) {
    return Column(
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
          decoration: InputDecoration(
            labelText: 'Artículo',
            prefixIcon:
                Icon(Icons.inventory_2, color: ProyectColors.primaryGreen),
            labelStyle: const TextStyle(color: ProyectColors.textSecondary),
            filled: true,
            fillColor: ProyectColors.surfaceDark,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          items: const [],
          onChanged: (_) {},
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Cantidad vendida',
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
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Precio individual',
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
        const SizedBox(height: 16),
        TextField(
          decoration: InputDecoration(
            labelText: 'Total acumulado',
            prefixIcon:
                Icon(Icons.calculate, color: ProyectColors.primaryGreen),
            labelStyle: const TextStyle(color: ProyectColors.textSecondary),
            filled: true,
            fillColor: ProyectColors.surfaceDark,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Row(
                spacing: 16,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '¿Es un cliente Frecuente?',
                    style: TextStyle(
                      color: ProyectColors.textPrimary,
                      fontSize: 16,
                    ),
                  ),
                  Checkbox(
                    value: _checked,
                    checkColor: ProyectColors.backgroundDark,
                    activeColor: ProyectColors.primaryGreen,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _checked = value;
                        });
                      }
                    },
                  )
                ],
              ),
            ),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Nombre del cliente (opcional)',
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
          ],
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
            onPressed: () {
              // Acción de guardar venta
            },
            icon: const Icon(Icons.save, color: ProyectColors.backgroundDark),
            label: const Text(
              'Guardar Venta',
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
  List<Map<String, dynamic>> _guardarProvee = [];

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
