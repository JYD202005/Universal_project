import 'package:flutter/material.dart';
import 'package:base_de_datos_universal/colours/colours.dart';

class ArticulosTable extends StatelessWidget {
  final List<Map<String, dynamic>> articulos;
  final void Function(int) onEditar;
  final void Function(int) onBorrar;

  const ArticulosTable({
    super.key,
    required this.articulos,
    required this.onEditar,
    required this.onBorrar,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        padding: const EdgeInsets.all(24),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: ProyectColors.primaryGreen, width: 2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                showCheckboxColumn: false,
                dataRowHeight: 60,
                headingRowHeight: 56,
                columnSpacing: 24,
                dividerThickness: 1,
                headingRowColor: MaterialStateProperty.all(ProyectColors.primaryGreen),
                dataRowColor: MaterialStateProperty.all(ProyectColors.surfaceDark),
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
                  DataColumn(label: Center(child: Text('Clave'))),
                  DataColumn(label: Center(child: Text('Nombre'))),
                  DataColumn(label: Center(child: Text('Familia'))),
                  DataColumn(label: Center(child: Text('Marca'))),
                  DataColumn(label: Center(child: Text('Línea'))),
                  DataColumn(label: Center(child: Text('Proveedor'))),
                  DataColumn(label: Center(child: Text('Precio'))),
                  DataColumn(label: Center(child: Text('Stock'))),
                  DataColumn(label: Center(child: Text('Código Barras'))),
                  DataColumn(label: Center(child: Text('Acciones'))),
                ],
                rows: List.generate(articulos.length, (index) {
                  final art = articulos[index];
                  return DataRow(
                    cells: [
                      DataCell(Center(child: Text(art['clave'].toString()))),
                      DataCell(Center(child: Text(art['nombre'].toString()))),
                      DataCell(Center(child: Text(art['familia'].toString()))),
                      DataCell(Center(child: Text(art['marca']?.toString() ?? ''))),
                      DataCell(Center(child: Text(art['linea']?.toString() ?? ''))),
                      DataCell(Center(child: Text(art['proveedor']?.toString() ?? ''))),
                      DataCell(Center(child: Text('\$${art['precio'] ?? ''}'))),
                      DataCell(Center(child: Text(art['cantidad']?.toString() ?? ''))),
                      DataCell(Center(child: Text(art['codigo']?.toString() ?? ''))),
                      DataCell(
                        Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: ProyectColors.primaryGreen),
                                tooltip: 'Editar',
                                onPressed: () => onEditar(index),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: ProyectColors.danger),
                                tooltip: 'Borrar',
                                onPressed: () => onBorrar(index),
                              ),
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
    );
  }
}

///////----------------Proveedores--------------------//////

class ProveedoresTable extends StatelessWidget {
  final List<Map<String, dynamic>> proveedores;
  final void Function(int) onEditar;
  final void Function(int) onBorrar;
  final void Function(String descripcion) onVerDescripcion;
  final void Function(String url) onDescargarPrecios;

  const ProveedoresTable({
    super.key,
    required this.proveedores,
    required this.onEditar,
    required this.onBorrar,
    required this.onVerDescripcion,
    required this.onDescargarPrecios,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        padding: const EdgeInsets.all(24),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: ProyectColors.primaryGreen, width: 2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                showCheckboxColumn: false,
                dataRowHeight: 60,
                headingRowHeight: 56,
                columnSpacing: 24,
                dividerThickness: 1,
                headingRowColor: MaterialStateProperty.all(ProyectColors.primaryGreen),
                dataRowColor: MaterialStateProperty.all(ProyectColors.surfaceDark),
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
                  DataColumn(label: Center(child: Text('Nombre'))),
                  DataColumn(label: Center(child: Text('Rubro'))),
                  DataColumn(label: Center(child: Text('Marca'))),
                  DataColumn(label: Center(child: Text('Familia'))),
                  DataColumn(label: Center(child: Text('Línea'))),
                  DataColumn(label: Center(child: Text('Descripción'))),
                  DataColumn(label: Center(child: Text('Código SAT'))),
                  DataColumn(label: Center(child: Text('Precios'))),
                  DataColumn(label: Center(child: Text('Acciones'))),
                ],
                rows: List.generate(proveedores.length, (index) {
                  final prov = proveedores[index];
                  return DataRow(
                    cells: [
                      DataCell(Center(child: Text(prov['nombre'] ?? ''))),
                      DataCell(Center(child: Text(prov['rubro'] ?? ''))),
                      DataCell(Center(child: Text(prov['marca'] ?? ''))),
                      DataCell(Center(child: Text(prov['familia'] ?? ''))),
                      DataCell(Center(child: Text(prov['linea'] ?? ''))),
                      DataCell(
                        Center(
                          child: IconButton(
                            icon: const Icon(Icons.info_outline, color: ProyectColors.primaryGreen),
                            tooltip: 'Ver descripción',
                            onPressed: () => onVerDescripcion(prov['descripcion'] ?? ''),
                          ),
                        ),
                      ),
                      DataCell(Center(child: Text(prov['codigo_sat'] ?? ''))),
                      DataCell(
                        Center(
                          child: IconButton(
                            icon: const Icon(Icons.download, color: ProyectColors.primaryGreen),
                            tooltip: 'Descargar catálogo de precios',
                            onPressed: () => onDescargarPrecios(prov['precios_url'] ?? ''),
                          ),
                        ),
                      ),
                      DataCell(
                        Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: ProyectColors.primaryGreen),
                                tooltip: 'Editar',
                                onPressed: () => onEditar(index),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: ProyectColors.danger),
                                tooltip: 'Borrar',
                                onPressed: () => onBorrar(index),
                              ),
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
    );
  }
}
