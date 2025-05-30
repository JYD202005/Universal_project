import 'package:flutter/material.dart';
import 'package:base_de_datos_universal/colours/colours.dart';
import 'package:base_de_datos_universal/dashboard/menubar.dart' as custom_menu;
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> _fechas = ['2024-05-01', '2024-05-15', '2024-06-01'];
  final List<String> _nombres = ['Juan Pérez', 'Ana López', 'Carlos Ruiz'];

  String? _fechaSeleccionada;
  String? _nombreSeleccionado;

  String _formularioActivo = '';
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _fechaController = TextEditingController();
  File? _archivoSeleccionado;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
    _fechaSeleccionada = _fechas.first;
    _nombreSeleccionado = _nombres.first;
  }

  Future<void> inate() async {}

  Widget _buildTabContent(String label) {
    final List<String> opciones1 = [
      'Estado Articulos',
      'Opcion A2',
      'Opcion A3'
    ];
    String valor1 = opciones1.first;

    return Center(
      child: Card(
        color: ProyectColors.backgroundDark,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                value: valor1,
                decoration: const InputDecoration(
                  labelText: 'Categoría',
                  filled: true,
                  fillColor: ProyectColors.surfaceDark,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12))),
                  labelStyle: TextStyle(color: ProyectColors.textSecondary),
                ),
                dropdownColor: ProyectColors.surfaceDark,
                style: const TextStyle(color: ProyectColors.textPrimary),
                items: opciones1.map((opcion) {
                  return DropdownMenuItem(value: opcion, child: Text(opcion));
                }).toList(),
                onChanged: (nuevoValor) {
                  valor1 = nuevoValor!;
                },
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _formularioActivo =
                            _formularioActivo == 'subida' ? '' : 'subida';
                      });
                    },
                    icon: const Icon(Icons.upload,
                        color: ProyectColors.backgroundDark),
                    label: const Text('Subir',
                        style: TextStyle(
                            color: ProyectColors.backgroundDark,
                            fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ProyectColors.primaryGreen,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _formularioActivo =
                            _formularioActivo == 'descarga' ? '' : 'descarga';
                      });
                    },
                    icon: const Icon(Icons.download,
                        color: ProyectColors.backgroundDark),
                    label: const Text('Descargar',
                        style: TextStyle(
                            color: ProyectColors.backgroundDark,
                            fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ProyectColors.primaryGreen,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                    ),
                  ),
                  const SizedBox(width: 16),
                  if (valor1 == 'Estado Articulos') ...[
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: () async {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Generando PDF...')),
                        );

                        try {
                          final articulos =
                              await obtenerEstadoArticulosDesdeSupabase();
                          final pdfFile =
                              await generarPdfEstadoArticulos(articulos);

                          // Mostrar mensaje con la ubicación del archivo
                          final mensaje = 'PDF guardado en: ${pdfFile.path}';
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(mensaje)),
                          );

                          await OpenFile.open(pdfFile.path);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error al generar PDF: $e')),
                          );
                        }
                      },
                      icon: const Icon(
                        Icons.download,
                        color: ProyectColors.backgroundDark,
                      ),
                      label: const Text(
                        'Crear PDF',
                        style: TextStyle(
                          color: ProyectColors.backgroundDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ProyectColors.primaryGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                        elevation: 4,
                        shadowColor: Colors.black45,
                      ),
                    ),
                  ]
                ],
              ),
              if (_formularioActivo == 'subida') ...[
                const Divider(color: ProyectColors.primaryGreen),
                const SizedBox(height: 16),
                const Text(
                  'Seleccione los datos a subir',
                  style: TextStyle(
                    color: ProyectColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _nombreController,
                  style: const TextStyle(color: ProyectColors.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    labelStyle: TextStyle(color: ProyectColors.textSecondary),
                    filled: true,
                    fillColor: ProyectColors.surfaceDark,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12))),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _fechaController,
                  readOnly: true,
                  onTap: () async {
                    DateTime? fecha = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      builder: (context, child) {
                        return Theme(
                          data: ThemeData.dark().copyWith(
                            colorScheme: const ColorScheme.dark(
                              primary: ProyectColors.primaryGreen,
                              surface: ProyectColors.backgroundDark,
                              onSurface: ProyectColors.textPrimary,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (fecha != null && mounted) {
                      setState(() {
                        _fechaController.text = fecha.toString().split(' ')[0];
                      });
                    }
                  },
                  style: const TextStyle(color: ProyectColors.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Fecha',
                    labelStyle: TextStyle(color: ProyectColors.textSecondary),
                    filled: true,
                    fillColor: ProyectColors.surfaceDark,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12))),
                    suffixIcon: Icon(Icons.calendar_today,
                        color: ProyectColors.primaryGreen),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () async {
                    FilePickerResult? result =
                        await FilePicker.platform.pickFiles();
                    if (result != null && result.files.single.path != null) {
                      setState(() {
                        _archivoSeleccionado = File(result.files.single.path!);
                      });
                    }
                  },
                  icon: const Icon(Icons.attach_file,
                      color: ProyectColors.backgroundDark),
                  label: Text(
                    _archivoSeleccionado == null
                        ? 'Seleccionar archivo'
                        : 'Archivo: ${_archivoSeleccionado!.path.split('/').last}',
                    style: const TextStyle(
                        color: ProyectColors.backgroundDark,
                        fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ProyectColors.primaryGreen,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                  ),
                ),
              ],
              if (_formularioActivo == 'descarga') ...[
                const Divider(color: ProyectColors.primaryGreen),
                const SizedBox(height: 16),
                const Text(
                  'Seleccione los datos a descargar',
                  style: TextStyle(
                    color: ProyectColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _fechaSeleccionada,
                  dropdownColor: ProyectColors.surfaceDark,
                  decoration: const InputDecoration(
                    labelText: 'Fecha',
                    labelStyle: TextStyle(color: ProyectColors.textSecondary),
                    filled: true,
                    fillColor: ProyectColors.surfaceDark,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12))),
                  ),
                  style: const TextStyle(color: ProyectColors.textPrimary),
                  items: _fechas.map((fecha) {
                    return DropdownMenuItem(value: fecha, child: Text(fecha));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _fechaSeleccionada = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _nombreSeleccionado,
                  dropdownColor: ProyectColors.surfaceDark,
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    labelStyle: TextStyle(color: ProyectColors.textSecondary),
                    filled: true,
                    fillColor: ProyectColors.surfaceDark,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12))),
                  ),
                  style: const TextStyle(color: ProyectColors.textPrimary),
                  items: _nombres.map((nombre) {
                    return DropdownMenuItem(value: nombre, child: Text(nombre));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _nombreSeleccionado = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Descargando datos de $_nombreSeleccionado en $_fechaSeleccionada'),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ProyectColors.primaryGreen,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                  ),
                  child: const Text(
                    'Aceptar descarga',
                    style: TextStyle(
                        color: ProyectColors.backgroundDark,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ProyectColors.surfaceDark,
      body: Row(
        children: [
          custom_menu.MenuBar(
            selectedIndex: 4,
            onDestinationSelected: (_) {},
          ),
          Expanded(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                  color: ProyectColors.backgroundDark,
                  child: const Text(
                    'Historial',
                    style: TextStyle(
                      color: ProyectColors.textPrimary,
                      fontSize: 22,
                    ),
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildTabContent('Entradas'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<File> generarPdfEstadoArticulos(
      List<Map<String, dynamic>> articulos) async {
    final pdf = pw.Document();

    // Agregar estilos personalizados
    final headerStyle = pw.TextStyle(
      fontSize: 12,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.white,
    );

    final cellStyle = pw.TextStyle(
      fontSize: 10,
      color: PdfColors.black,
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(20),
        build: (context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text('Reporte de Estado de Artículos',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  )),
            ),
            pw.SizedBox(height: 10),
            pw.Text('Fecha: ${DateTime.now().toString().split(' ')[0]}',
                style: pw.TextStyle(fontSize: 10)),
            pw.SizedBox(height: 20),

            // Tabla de artículos
            pw.Table.fromTextArray(
              headers: [
                'ID',
                'Clave',
                'Nombre',
                'Familia',
                'Marca',
                'Stock',
                'Mínimo',
                'Proveedor',
                'Estado',
              ],
              data: articulos.map((item) {
                // Color según el estado
                PdfColor estadoColor = PdfColors.black;
                if (item['estado'] == 'Crítico') {
                  estadoColor = PdfColors.red;
                } else if (item['estado'] == 'Bajo') {
                  estadoColor = PdfColors.orange;
                } else {
                  estadoColor = PdfColors.green;
                }

                return [
                  item['id'].toString(),
                  item['clave_producto'] ?? '-',
                  item['nombre_producto'] ?? '-',
                  item['familia'] ?? '-',
                  item['marca'] ?? '-',
                  item['stock'].toString(),
                  item['stock_min'].toString(),
                  item['proveedor'] ?? '-',
                  pw.Text(item['estado'] ?? '-',
                      style: pw.TextStyle(color: estadoColor)),
                ];
              }).toList(),
              headerStyle: headerStyle,
              headerDecoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#2E7D32'), // Verde oscuro
                borderRadius: pw.BorderRadius.circular(4),
              ),
              cellStyle: cellStyle,
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerLeft,
                2: pw.Alignment.centerLeft,
                3: pw.Alignment.centerLeft,
                4: pw.Alignment.centerLeft,
                5: pw.Alignment.center,
                6: pw.Alignment.center,
                7: pw.Alignment.centerLeft,
                8: pw.Alignment.center,
              },
              border: pw.TableBorder.all(
                color: PdfColor.fromHex('#E0E0E0'),
                width: 0.5,
              ),
              cellPadding: pw.EdgeInsets.all(4),
              columnWidths: {
                0: const pw.FixedColumnWidth(40), // ID
                1: const pw.FixedColumnWidth(60), // Clave
                2: const pw.FixedColumnWidth(120), // Nombre
                3: const pw.FixedColumnWidth(80), // Familia
                4: const pw.FixedColumnWidth(80), // Marca
                5: const pw.FixedColumnWidth(40), // Stock
                6: const pw.FixedColumnWidth(40), // Mínimo
                7: const pw.FixedColumnWidth(100), // Proveedor
                8: const pw.FixedColumnWidth(50), // Estado
              },
            ),

            // Resumen al final
            pw.SizedBox(height: 20),
            pw.Row(
              children: [
                pw.Text('Total de artículos: ${articulos.length}',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(width: 20),
                pw.Text(
                    'Críticos: ${articulos.where((a) => a['estado'] == 'Crítico').length}',
                    style: pw.TextStyle(color: PdfColors.red)),
                pw.SizedBox(width: 10),
                pw.Text(
                    'Bajos: ${articulos.where((a) => a['estado'] == 'Bajo').length}',
                    style: pw.TextStyle(color: PdfColors.orange)),
                pw.SizedBox(width: 10),
                pw.Text(
                    'Óptimos: ${articulos.where((a) => a['estado'] == 'Óptimo').length}',
                    style: pw.TextStyle(color: PdfColors.green)),
              ],
            ),
          ];
        },
      ),
    );

    // Obtener el directorio de descargas
    Directory? downloadsDirectory;

    try {
      if (Platform.isAndroid || Platform.isIOS) {
        // Para dispositivos móviles
        downloadsDirectory = await getExternalStorageDirectory();
      } else {
        // Para desktop (Windows, macOS, Linux)
        downloadsDirectory = await getDownloadsDirectory();
      }

      // Si no se pudo obtener el directorio de descargas, usar el temporal
      downloadsDirectory ??= await getTemporaryDirectory();

      // Crear el nombre del archivo con fecha y hora
      final fecha = DateTime.now();
      final nombreArchivo =
          'Estado_Articulos_${fecha.year}${fecha.month.toString().padLeft(2, '0')}${fecha.day.toString().padLeft(2, '0')}_${fecha.hour.toString().padLeft(2, '0')}${fecha.minute.toString().padLeft(2, '0')}.pdf';

      // Crear el archivo
      final file = File('${downloadsDirectory!.path}/$nombreArchivo');
      await file.writeAsBytes(await pdf.save());

      return file;
    } catch (e) {
      // En caso de error, usar el directorio temporal como fallback
      final output = await getTemporaryDirectory();
      final file = File(
          "${output.path}/estado_articulos_${DateTime.now().millisecondsSinceEpoch}.pdf");
      await file.writeAsBytes(await pdf.save());
      return file;
    }
  }

  Future<List<Map<String, dynamic>>>
      obtenerEstadoArticulosDesdeSupabase() async {
    final supabase = Supabase.instance.client;
    final response = await supabase
        .from('Articulos')
        .select('id, clave, nombre, cantidad_stock, cantidad_min, '
            'familia_id (nombre), marca_id (nombre), provee_id (nombre)')
        .eq('deshabilitado', true);

    if (response is List) {
      List<Map<String, dynamic>> listaConEstado = [];

      for (var item in response) {
        final int stock = item['cantidad_stock'] ?? 0;
        final int stockMinimo = item['cantidad_min'] ?? 0;

        String estado;
        if (stock * 2 <= stockMinimo) {
          estado = 'Crítico';
        } else if (stock < stockMinimo) {
          estado = 'Bajo';
        } else {
          estado = 'Óptimo';
        }

        listaConEstado.add({
          'id': item['id'],
          'clave_producto': item['clave'],
          'nombre_producto': item['nombre'],
          'familia': item['familia_id']?['nombre'] ?? 'Sin familia',
          'marca': item['marca_id']?['nombre'] ?? 'Sin marca',
          'stock': stock,
          'stock_min': stockMinimo,
          'proveedor': item['provee_id']?['nombre'] ?? 'Sin proveedor',
          'estado': estado,
        });
      }

      return listaConEstado;
    } else {
      throw Exception('Error al obtener artículos: $response');
    }
  }
}
