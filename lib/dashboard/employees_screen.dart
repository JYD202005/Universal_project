import 'package:flutter/material.dart';
import 'package:base_de_datos_universal/colours/colours.dart';
import 'package:base_de_datos_universal/dashboard/menubar.dart' as custom_menu;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EmployeesScreen extends StatefulWidget {
  const EmployeesScreen({super.key});

  @override
  State<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends State<EmployeesScreen> {
  final List<Map<String, String>> _empleados = [];

  String _busqueda = '';
  bool _mostrarFormulario = false;
  DateTime? _fechaRegistroSeleccionada;

  // Controladores para el formulario
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _patController = TextEditingController();
  final TextEditingController _matController = TextEditingController();
  final TextEditingController _puestoController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();

  final ScrollController _verticalTableScrollController = ScrollController();
  final supabase = Supabase.instance.client;

  List<Map<String, String>> get _empleadosFiltrados {
    return _empleados.where((emp) {
      return emp['nombre_pila']!
              .toLowerCase()
              .contains(_busqueda.toLowerCase()) ||
          emp['puesto']!.toLowerCase().contains(_busqueda.toLowerCase());
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    if (!mounted) return;
    _cargarEmpleados();
  }

  Future<void> _cargarEmpleados() async {
    if (!mounted) return;
    try {
      final response = await supabase.from('Usuarios').select('''
      correo, contrasena, nombre_pila, apellido_pat, apellido_mat, fec_ingre, puesto,telefono
    ''');

      if (response == null) return;

      final List<Map<String, String>> temp =
          response.map<Map<String, String>>((item) {
        return {
          'correo': item['correo']?.toString() ?? '',
          'contrasena': item['contrasena']?.toString() ?? '',
          'nombre_pila': item['nombre_pila']?.toString() ?? '',
          'apellido_pat': item['apellido_pat']?.toString() ?? '',
          'apellido_mat': item['apellido_mat']?.toString() ?? '',
          'fec_ingre': item['fec_ingre']?.toString() ?? '',
          'puesto': item['puesto']?.toString() ?? '',
          'telefono': item['telefono'].toString()
        };
      }).toList();

      if (!mounted) return;
      setState(() {
        _empleados.clear();
        _empleados.addAll(temp);
      });
    } catch (e) {
      print('Error al cargar empleados: $e');
    }
  }

  void _abrirFormulario() {
    if (!mounted) return;
    setState(() {
      _mostrarFormulario = true;
      _nombreController.clear();
      _puestoController.clear();
      _telefonoController.clear();
      _correoController.clear();
      _fechaRegistroSeleccionada = DateTime.now();
      _patController.clear();
      _matController.clear();
    });
  }

  void _cerrarFormulario() {
    setState(() {
      _mostrarFormulario = false;
    });
  }

  void _guardarEmpleado() async {
    if (!mounted) return;
    String contrasena =
        '${_nombreController.text.trim()}${_telefonoController}';
    setState(() {
      _empleados.add({
        'nombre_pila': _nombreController.text,
        'apellido_pat': _patController.text,
        'apellido_mat': _matController.text,
        'puesto': _puestoController.text,
        'telefono': _telefonoController.text,
        'correo': _correoController.text,
        'contrasena': contrasena,
        'fec_ingre': _fechaRegistroSeleccionada != null
            ? _fechaRegistroSeleccionada!.toString().split(' ')[0]
            : DateTime.now().toString().split(' ')[0],
      });
      _mostrarFormulario = false;
    });
    await _guardarEmpleadoEnUsuario();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Empleado agregado')),
    );
  }

  Future<void> _guardarEmpleadoEnUsuario() async {
    if (!mounted) return;
    String contrasena = '${_nombreController.text.trim()}';
    final fecha = _fechaRegistroSeleccionada != null
        ? _fechaRegistroSeleccionada!.toIso8601String().split('T')[0]
        : DateTime.now().toIso8601String().split('T')[0];

    try {
      final response = await supabase.from('Usuarios').insert({
        'nombre_pila': _nombreController.text,
        'apellido_pat': _patController.text,
        'apellido_mat': _matController.text,
        'puesto': _puestoController.text,
        'telefono': _telefonoController.text,
        'correo': _correoController.text,
        'contrasena': contrasena,
        'fec_ingre': fecha,
      });
      print(response);
      // Opcional: limpiar campos o cerrar formulario
      setState(() {
        _mostrarFormulario = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Empleado guardado en la base de datos')),
      );
    } catch (error) {
      print('Error al guardar en Supabase: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al guardar el empleado')),
      );
    }
  }

  Future<void> _borrarEmpleadoPorCorreo(String correo) async {
    try {
      final response =
          await supabase.from('Usuarios').delete().eq('correo', correo);

      try {
        setState(() {
          _empleados.removeWhere((empleado) => empleado['correo'] == correo);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Empleado eliminado')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error al eliminar: ${response.error!.message}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar: $e')),
      );
    }
  }

  void _cargarDatosUsuario(Map<String, dynamic> usuario) {
    _nombreController.text = usuario['nombre_pila'] ?? '';
    _patController.text = usuario['apellido_pat'] ?? '';
    _matController.text = usuario['apellido_mat'] ?? '';
    _puestoController.text = usuario['puesto'] ?? '';
    _telefonoController.text = usuario['telefono']?.toString() ?? '';
    _correoController.text = usuario['correo'] ?? '';
    _fechaRegistroSeleccionada = usuario['fec_ingre'] != null
        ? DateTime.parse(usuario['fec_ingre'])
        : null;
  }

  Future<void> _modificarEmpleado() async {
    if (!mounted) return;

    final fecha = _fechaRegistroSeleccionada != null
        ? _fechaRegistroSeleccionada!.toIso8601String().split('T')[0]
        : DateTime.now().toIso8601String().split('T')[0];

    try {
      final response = await supabase.from('Usuarios').update({
        'nombre_pila': _nombreController.text,
        'apellido_pat': _patController.text,
        'apellido_mat': _matController.text,
        'puesto': _puestoController.text,
        'telefono': int.tryParse(_telefonoController.text),
        'correo': _correoController.text,
        'fec_ingre': fecha,
        // No actualizamos correo si es clave primaria e inmutable
      }).eq('correo',
          _correoController.text); // donde correo = el correo del usuario
      if (!mounted) return;
      setState(() {
        _mostrarFormulario = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Empleado modificado correctamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al modificar: $e')),
      );
    }
  }

  void _abrirFormularioModificar(Map<String, dynamic> usuario) {
    _cargarDatosUsuario(usuario);
    setState(() {
      _mostrarFormulario = true;
    });
  }

  void mostrarFormularioEmpleadoDialog(
    BuildContext context, {
    bool modoEdicion = false,
    Map<String, dynamic>? usuario,
  }) {
    if (modoEdicion && usuario != null) {
      _cargarDatosUsuario(usuario);
    } else {
      // Limpia los campos si es nuevo
      _nombreController.clear();
      _patController.clear();
      _matController.clear();
      _puestoController.clear();
      _telefonoController.clear();
      _correoController.clear();
      _fechaRegistroSeleccionada = null;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 350,
            height: 600,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: ProyectColors.backgroundDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: ProyectColors.primaryGreen,
                width: 2,
              ),
            ),
            child: SingleChildScrollView(
              controller: _verticalTableScrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Encabezado y cerrar
                  Row(
                    children: [
                      Expanded(
                        child: AutoSizeText(
                          modoEdicion ? 'Editar empleado' : 'Nuevo empleado',
                          style: const TextStyle(
                            color: ProyectColors.primaryGreen,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          minFontSize: 5,
                          maxFontSize: 30,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        tooltip: 'Cerrar',
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: _nombreController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre',
                      filled: true,
                      fillColor: ProyectColors.surfaceDark,
                    ),
                    style: const TextStyle(color: ProyectColors.textPrimary),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: _patController,
                    decoration: const InputDecoration(
                      labelText: 'Apellido Pat',
                      filled: true,
                      fillColor: ProyectColors.surfaceDark,
                    ),
                    style: const TextStyle(color: ProyectColors.textPrimary),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: _matController,
                    decoration: const InputDecoration(
                      labelText: 'Apellido Mat',
                      filled: true,
                      fillColor: ProyectColors.surfaceDark,
                    ),
                    style: const TextStyle(color: ProyectColors.textPrimary),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: _puestoController,
                    decoration: const InputDecoration(
                      labelText: 'Puesto',
                      filled: true,
                      fillColor: ProyectColors.surfaceDark,
                    ),
                    style: const TextStyle(color: ProyectColors.textPrimary),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: _telefonoController,
                    decoration: const InputDecoration(
                      labelText: 'Teléfono',
                      filled: true,
                      fillColor: ProyectColors.surfaceDark,
                    ),
                    style: const TextStyle(color: ProyectColors.textPrimary),
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    enabled: false,
                    controller: _correoController,
                    decoration: const InputDecoration(
                      labelText: 'Correo',
                      labelStyle: TextStyle(color: ProyectColors.textPrimary),
                      filled: true,
                      fillColor: ProyectColors.surfaceDark,
                    ),
                    style: const TextStyle(color: ProyectColors.textPrimary),
                    keyboardType: TextInputType.emailAddress,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'[a-zA-Z0-9@._-]'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  GestureDetector(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate:
                            _fechaRegistroSeleccionada ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                        builder: (context, child) => Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.dark(
                              primary: ProyectColors.primaryGreen,
                              onPrimary: Colors.white,
                              surface: ProyectColors.surfaceDark,
                              onSurface: ProyectColors.textPrimary,
                            ),
                            dialogBackgroundColor: ProyectColors.backgroundDark,
                          ),
                          child: child!,
                        ),
                      );
                      if (picked != null) {
                        _fechaRegistroSeleccionada = picked;
                      }
                    },
                    child: AbsorbPointer(
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'Fecha de registro',
                          filled: true,
                          fillColor: ProyectColors.surfaceDark,
                          suffixIcon: Icon(
                            Icons.calendar_today,
                            color: ProyectColors.primaryGreen,
                          ),
                        ),
                        style:
                            const TextStyle(color: ProyectColors.textPrimary),
                        controller: TextEditingController(
                          text: _fechaRegistroSeleccionada != null
                              ? _fechaRegistroSeleccionada!
                                  .toString()
                                  .split(' ')[0]
                              : '',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Botón Guardar / Actualizar
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ProyectColors.primaryGreen,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        if (modoEdicion) {
                          await _modificarEmpleado();
                        } else {
                          _guardarEmpleado();
                        }
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.save,
                          color: ProyectColors.backgroundDark),
                      label: Text(
                        modoEdicion ? 'Actualizar' : 'Guardar',
                        style: const TextStyle(
                          color: ProyectColors.backgroundDark,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ProyectColors.surfaceDark,
      body: Row(
        children: [
          custom_menu.MenuBar(
            selectedIndex: 3,
            onDestinationSelected: (_) {},
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Columna principal con buscador y tabla
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Gestión de Empleados',
                          style: TextStyle(
                            color: ProyectColors.primaryGreen,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                style: const TextStyle(
                                    color: ProyectColors.textPrimary),
                                decoration: InputDecoration(
                                  hintText: 'Buscar por nombre o puesto...',
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
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ProyectColors.primaryGreen,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 16),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: _abrirFormulario,
                              icon: const Icon(Icons.person_add,
                                  color: ProyectColors.backgroundDark),
                              label: const Text(
                                'Agregar empleado',
                                style: TextStyle(
                                  color: ProyectColors.backgroundDark,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Tabla de empleados
                              Flexible(
                                flex: _mostrarFormulario
                                    ? 3
                                    : 1, // Ajusta el espacio según el formulario
                                child: Container(
                                  margin: const EdgeInsets.only(
                                      right:
                                          100), // Espacio visual a la derecha
                                  decoration: BoxDecoration(
                                    color: ProyectColors.backgroundDark,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                        color: ProyectColors.primaryGreen,
                                        width: 2),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: DataTable(
                                        showCheckboxColumn: false,
                                        dataRowHeight: 60,
                                        headingRowHeight: 56,
                                        columnSpacing: 24,
                                        dividerThickness: 1,
                                        headingRowColor:
                                            MaterialStateProperty.all(
                                                ProyectColors.primaryGreen),
                                        dataRowColor: MaterialStateProperty.all(
                                            ProyectColors.surfaceDark),
                                        headingTextStyle: const TextStyle(
                                          color: ProyectColors.textPrimary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                        dataTextStyle: const TextStyle(
                                          color: ProyectColors.textPrimary,
                                          fontSize: 15,
                                        ),
                                        columns: const [
                                          DataColumn(
                                              label: Center(
                                                  child: Text('Nombre'))),
                                          DataColumn(
                                              label: Center(
                                                  child: Text(
                                                      'Apellido Paterno'))),
                                          DataColumn(
                                              label: Center(
                                                  child: Text(
                                                      'Apellido Materno'))),
                                          DataColumn(
                                              label: Center(
                                                  child: Text('Puesto'))),
                                          DataColumn(
                                              label: Center(
                                                  child: Text('Teléfono'))),
                                          DataColumn(
                                              label: Center(
                                                  child: Text('Correo'))),
                                          DataColumn(
                                              label: Center(
                                                  child: Text(
                                                      'Fecha de registro'))),
                                          DataColumn(
                                              label: Center(
                                                  child: Text('Acciones'))),
                                        ],
                                        rows: List.generate(
                                            _empleadosFiltrados.length,
                                            (index) {
                                          final emp =
                                              _empleadosFiltrados[index];
                                          return DataRow(
                                            cells: [
                                              DataCell(Center(
                                                  child: Text(
                                                      emp['nombre_pila'] ??
                                                          ''))),
                                              DataCell(Center(
                                                  child: Text(
                                                      emp['apellido_pat'] ??
                                                          ''))),
                                              DataCell(Center(
                                                  child: Text(
                                                      emp['apellido_mat'] ??
                                                          ''))),
                                              DataCell(Center(
                                                  child: Text(
                                                      emp['puesto'] ?? ''))),
                                              DataCell(Center(
                                                  child: Text(
                                                      emp['telefono'] ?? ''))),
                                              DataCell(Center(
                                                  child: Text(
                                                      emp['correo'] ?? ''))),
                                              DataCell(Center(
                                                  child: Text(
                                                      emp['fec_ingre'] ?? ''))),
                                              DataCell(
                                                Center(
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      IconButton(
                                                        icon: const Icon(
                                                            Icons.edit,
                                                            color: ProyectColors
                                                                .primaryGreen),
                                                        tooltip: 'Editar',
                                                        onPressed: () {
                                                          mostrarFormularioEmpleadoDialog(
                                                              context,
                                                              modoEdicion: true,
                                                              usuario: emp);
                                                        },
                                                      ),
                                                      IconButton(
                                                          icon: const Icon(
                                                              Icons.delete,
                                                              color:
                                                                  ProyectColors
                                                                      .danger),
                                                          tooltip: 'Eliminar',
                                                          onPressed: () {
                                                            _borrarEmpleadoPorCorreo(
                                                                emp['correo'] ??
                                                                    '');
                                                          }),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        }),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // Panel lateral para el formulario
                              if (_mostrarFormulario)
                                Flexible(
                                  flex: 1,
                                  child: Container(
                                    width: 350,
                                    height: double.infinity,
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: ProyectColors.backgroundDark,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                          color: ProyectColors.primaryGreen,
                                          width: 2),
                                    ),
                                    child: SingleChildScrollView(
                                      controller:
                                          _verticalTableScrollController,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Encabezado y botón cerrar
                                          Row(
                                            children: [
                                              Expanded(
                                                child: AutoSizeText(
                                                  'Nuevo empleado',
                                                  style: const TextStyle(
                                                    color: ProyectColors
                                                        .primaryGreen,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  maxLines: 1,
                                                  minFontSize: 5,
                                                  maxFontSize: 30,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              SizedBox(
                                                width:
                                                    40, // límite máximo ancho para el botón
                                                height:
                                                    40, // límite máximo alto para el botón
                                                child: IconButton(
                                                  padding: EdgeInsets.zero,
                                                  icon: FittedBox(
                                                    fit: BoxFit.scaleDown,
                                                    child: const Icon(
                                                        Icons.close,
                                                        color: Colors.red),
                                                  ),
                                                  tooltip: 'Cerrar',
                                                  onPressed: _cerrarFormulario,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 16),
                                          TextField(
                                            controller: _nombreController,
                                            decoration: const InputDecoration(
                                              labelText: 'Nombre',
                                              filled: true,
                                              fillColor:
                                                  ProyectColors.surfaceDark,
                                            ),
                                            style: const TextStyle(
                                                color:
                                                    ProyectColors.textPrimary),
                                          ),
                                          const SizedBox(height: 12),
                                          // Campo Apellidopat
                                          TextField(
                                            controller: _patController,
                                            decoration: const InputDecoration(
                                              labelText: 'Apellido Pat',
                                              filled: true,
                                              fillColor:
                                                  ProyectColors.surfaceDark,
                                            ),
                                            style: const TextStyle(
                                                color:
                                                    ProyectColors.textPrimary),
                                          ),

                                          const SizedBox(height: 12),
                                          //apellido mat
                                          TextField(
                                            controller: _matController,
                                            decoration: const InputDecoration(
                                              labelText: 'Apellido Mat',
                                              filled: true,
                                              fillColor:
                                                  ProyectColors.surfaceDark,
                                            ),
                                            style: const TextStyle(
                                                color:
                                                    ProyectColors.textPrimary),
                                          ),

                                          const SizedBox(height: 12),

                                          // Campo Puesto
                                          TextField(
                                            controller: _puestoController,
                                            decoration: const InputDecoration(
                                              labelText: 'Puesto',
                                              filled: true,
                                              fillColor:
                                                  ProyectColors.surfaceDark,
                                            ),
                                            style: const TextStyle(
                                                color:
                                                    ProyectColors.textPrimary),
                                          ),
                                          const SizedBox(height: 12),
                                          // Campo Teléfono
                                          TextField(
                                            controller: _telefonoController,
                                            decoration: const InputDecoration(
                                              labelText: 'Teléfono',
                                              filled: true,
                                              fillColor:
                                                  ProyectColors.surfaceDark,
                                            ),
                                            style: const TextStyle(
                                                color:
                                                    ProyectColors.textPrimary),
                                            keyboardType: TextInputType.phone,
                                            inputFormatters: [
                                              FilteringTextInputFormatter
                                                  .digitsOnly, // solo números
                                              LengthLimitingTextInputFormatter(
                                                  10), // máximo 10 dígitos
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          // Campo Correo
                                          TextField(
                                            controller: _correoController,
                                            decoration: const InputDecoration(
                                              labelText: 'Correo',
                                              filled: true,
                                              fillColor:
                                                  ProyectColors.surfaceDark,
                                            ),
                                            style: const TextStyle(
                                                color:
                                                    ProyectColors.textPrimary),
                                            keyboardType:
                                                TextInputType.emailAddress,
                                          ),
                                          const SizedBox(height: 12),
                                          // Campo Fecha de registro
                                          GestureDetector(
                                            onTap: () async {
                                              final DateTime? picked =
                                                  await showDatePicker(
                                                context: context,
                                                initialDate:
                                                    _fechaRegistroSeleccionada ??
                                                        DateTime.now(),
                                                firstDate: DateTime(2000),
                                                lastDate: DateTime.now(),
                                                builder: (context, child) =>
                                                    Theme(
                                                  data: Theme.of(context)
                                                      .copyWith(
                                                    colorScheme:
                                                        ColorScheme.dark(
                                                      primary: ProyectColors
                                                          .primaryGreen,
                                                      onPrimary: Colors.white,
                                                      surface: ProyectColors
                                                          .surfaceDark,
                                                      onSurface: ProyectColors
                                                          .textPrimary,
                                                    ),
                                                    dialogBackgroundColor:
                                                        ProyectColors
                                                            .backgroundDark,
                                                  ),
                                                  child: child!,
                                                ),
                                              );
                                              if (picked != null) {
                                                setState(() {
                                                  _fechaRegistroSeleccionada =
                                                      picked;
                                                });
                                              }
                                            },
                                            child: AbsorbPointer(
                                              child: TextField(
                                                decoration: InputDecoration(
                                                  labelText:
                                                      'Fecha de registro',
                                                  filled: true,
                                                  fillColor:
                                                      ProyectColors.surfaceDark,
                                                  suffixIcon: const Icon(
                                                      Icons.calendar_today,
                                                      color: ProyectColors
                                                          .primaryGreen),
                                                ),
                                                style: const TextStyle(
                                                    color: ProyectColors
                                                        .textPrimary),
                                                controller:
                                                    TextEditingController(
                                                  text: _fechaRegistroSeleccionada !=
                                                          null
                                                      ? _fechaRegistroSeleccionada!
                                                          .toString()
                                                          .split(' ')[0]
                                                      : '',
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 24),
                                          // Botón Guardar
                                          SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton.icon(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    ProyectColors.primaryGreen,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 16),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12)),
                                              ),
                                              onPressed: _guardarEmpleado,
                                              icon: const Icon(Icons.save,
                                                  color: ProyectColors
                                                      .backgroundDark),
                                              label: const Text(
                                                'Guardar',
                                                style: TextStyle(
                                                  color: ProyectColors
                                                      .backgroundDark,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
