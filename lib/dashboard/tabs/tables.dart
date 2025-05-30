import 'package:flutter/material.dart';
import 'package:base_de_datos_universal/colours/colours.dart';

class ArticulosTable extends StatefulWidget {
  final List<Map<String, dynamic>> articulos;
  final void Function(int) onEditar;
  final void Function(int) onBorrar;
  final bool _scrollable = true;

  const ArticulosTable({
    super.key,
    required this.articulos,
    required this.onEditar,
    required this.onBorrar,
    required bool scrollable,
  });

  @override
  State<ArticulosTable> createState() => _ArticulosTableState();
}

//controllers
final ScrollController _verticalTableScrollController = ScrollController();
final ScrollController _horizontalTableScrollController = ScrollController();

class _ArticulosTableState extends State<ArticulosTable> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
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
              thumbVisibility: widget._scrollable,
              trackVisibility: widget._scrollable,
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
                  child: RawScrollbar(
                    controller: _verticalTableScrollController,
                    thumbVisibility: widget._scrollable,
                    trackVisibility: widget._scrollable,
                    thumbColor: ProyectColors.primaryGreen.withOpacity(0.8),
                    thickness: 6,
                    radius: const Radius.circular(8),
                    crossAxisMargin: 1,
                    child: SingleChildScrollView(
                      controller: _verticalTableScrollController,
                      scrollDirection: Axis.vertical,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: constraints.maxWidth,
                        ),
                        child: DataTable(
                          showCheckboxColumn: false,
                          dataRowHeight: 60,
                          headingRowHeight: 56,
                          columnSpacing: 24,
                          dividerThickness: 1,
                          headingRowColor: WidgetStateProperty.all(
                              ProyectColors.primaryGreen),
                          dataRowColor: WidgetStateProperty.all(
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
                          columns: [
                            DataColumn(
                                headingRowAlignment: MainAxisAlignment.center,
                                label: Center(child: Text('Clave'))),
                            DataColumn(
                                headingRowAlignment: MainAxisAlignment.center,
                                label: Center(child: Text('Nombre'))),
                            DataColumn(
                                headingRowAlignment: MainAxisAlignment.center,
                                label: Center(child: Text('Familia'))),
                            DataColumn(
                                headingRowAlignment: MainAxisAlignment.center,
                                label: Center(child: Text('Marca'))),
                            DataColumn(
                                headingRowAlignment: MainAxisAlignment.center,
                                label: Center(child: Text('Línea'))),
                            DataColumn(
                                headingRowAlignment: MainAxisAlignment.center,
                                label: Center(child: Text('Proveedor'))),
                            DataColumn(
                                headingRowAlignment: MainAxisAlignment.center,
                                label: Center(child: Text('Precio'))),
                            DataColumn(
                                headingRowAlignment: MainAxisAlignment.center,
                                label: Center(child: Text('Stock'))),
                            DataColumn(
                                headingRowAlignment: MainAxisAlignment.center,
                                label: Center(child: Text('Código Barras'))),
                            DataColumn(
                                headingRowAlignment: MainAxisAlignment.center,
                                label: Center(child: Text('Acciones'))),
                          ],
                          rows: List.generate(widget.articulos.length, (index) {
                            final art = widget.articulos[index];
                            return DataRow(
                              cells: [
                                DataCell(Align(
                                    alignment: Alignment.center,
                                    child: Text(art['clave'].toString()))),
                                DataCell(Align(
                                    alignment: Alignment.center,
                                    child: Text(art['nombre'].toString()))),
                                DataCell(Align(
                                    alignment: Alignment.center,
                                    child: Text(art['familia'].toString()))),
                                DataCell(Align(
                                    alignment: Alignment.center,
                                    child:
                                        Text(art['marca']?.toString() ?? ''))),
                                DataCell(Align(
                                    alignment: Alignment.center,
                                    child:
                                        Text(art['linea']?.toString() ?? ''))),
                                DataCell(Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                        art['proveedor']?.toString() ?? ''))),
                                DataCell(Align(
                                    alignment: Alignment.center,
                                    child: Text('\$${art['precio'] ?? ''}'))),
                                DataCell(Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                        art['cantidad']?.toString() ?? ''))),
                                DataCell(Align(
                                    alignment: Alignment.center,
                                    child:
                                        Text(art['codigo']?.toString() ?? ''))),
                                DataCell(
                                  Align(
                                    alignment: Alignment.center,
                                    child: Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit,
                                              color:
                                                  ProyectColors.primaryGreen),
                                          tooltip: 'Editar',
                                          onPressed: () =>
                                              widget.onEditar(index),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete,
                                              color: ProyectColors.danger),
                                          tooltip: 'Borrar',
                                          onPressed: () =>
                                              widget.onBorrar(index),
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
              ),
            ),
          ),
        ),
      );
    });
  }
}

///////----------------Proveedores--------------------//////

class ProveedoresTable extends StatefulWidget {
  final List<Map<String, dynamic>> proveedores;
  final void Function(int) onEditar;
  final void Function(int) onBorrar;
  final void Function(String descripcion) onVerDescripcion;
  final void Function(String url) onDescargarPrecios;
  final bool _scrollable = true;

  const ProveedoresTable({
    super.key,
    required this.proveedores,
    required this.onEditar,
    required this.onBorrar,
    required this.onVerDescripcion,
    required this.onDescargarPrecios,
    required bool scrollable,
  });

  @override
  State<ProveedoresTable> createState() => _ProveedoresTableState();
}

//controllers
final ScrollController _verticalTableScrollController2 = ScrollController();
final ScrollController _horizontalTableScrollController2 = ScrollController();

class _ProveedoresTableState extends State<ProveedoresTable> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
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
              controller: _horizontalTableScrollController2,
              thumbVisibility: widget._scrollable,
              trackVisibility: widget._scrollable,
              thumbColor: ProyectColors.primaryGreen.withOpacity(0.8),
              thickness: 6,
              radius: const Radius.circular(8),
              crossAxisMargin: 1,
              child: SizedBox(
                height: 60 + 6 * 70,
                width: constraints.maxWidth,
                child: SingleChildScrollView(
                  controller: _horizontalTableScrollController2,
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    controller: _verticalTableScrollController2,
                    scrollDirection: Axis.vertical,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: constraints.maxWidth,
                      ),
                      child: IntrinsicWidth(
                        child: IntrinsicHeight(
                          child: DataTable(
                            showCheckboxColumn: false,
                            dataRowHeight: 60,
                            headingRowHeight: 56,
                            columnSpacing: 24,
                            dividerThickness: 1,
                            headingRowColor: WidgetStateProperty.all(
                                ProyectColors.primaryGreen),
                            dataRowColor: WidgetStateProperty.all(
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
                            columns: [
                              DataColumn(
                                  headingRowAlignment: MainAxisAlignment.center,
                                  label: Center(child: Text('ID'))),
                              DataColumn(
                                  headingRowAlignment: MainAxisAlignment.center,
                                  label: Center(child: Text('Nombre'))),
                              DataColumn(
                                  headingRowAlignment: MainAxisAlignment.center,
                                  label: Center(child: Text('Rubro'))),
                              DataColumn(
                                  headingRowAlignment: MainAxisAlignment.center,
                                  label: Center(child: Text('Marca'))),
                              DataColumn(
                                  headingRowAlignment: MainAxisAlignment.center,
                                  label: Center(child: Text('Familia'))),
                              DataColumn(
                                  headingRowAlignment: MainAxisAlignment.center,
                                  label: Center(child: Text('Línea'))),
                              DataColumn(
                                  headingRowAlignment: MainAxisAlignment.center,
                                  label: Center(child: Text('Descripción'))),
                              DataColumn(
                                  headingRowAlignment: MainAxisAlignment.center,
                                  label: Center(child: Text('Código SAT'))),
                              DataColumn(
                                  headingRowAlignment: MainAxisAlignment.center,
                                  label: Center(child: Text('Precios'))),
                              DataColumn(
                                  headingRowAlignment: MainAxisAlignment.center,
                                  label: Center(child: Text('Acciones'))),
                            ],
                            rows: List.generate(widget.proveedores.length,
                                (index) {
                              final prov = widget.proveedores[index];
                              return DataRow(
                                cells: [
                                  DataCell(Center(
                                      child:
                                          Text(prov['id'].toString() ?? ''))),
                                  DataCell(Center(
                                      child: Text(prov['nombre'] ?? ''))),
                                  DataCell(
                                      Center(child: Text(prov['rubro'] ?? ''))),
                                  DataCell(
                                      Center(child: Text(prov['marca'] ?? ''))),
                                  DataCell(Center(
                                      child: Text(prov['familia'] ?? ''))),
                                  DataCell(
                                      Center(child: Text(prov['linea'] ?? ''))),
                                  DataCell(
                                    Center(
                                      child: IconButton(
                                        icon: const Icon(Icons.info_outline,
                                            color: ProyectColors.primaryGreen),
                                        tooltip: 'Ver descripción',
                                        onPressed: () =>
                                            widget.onVerDescripcion(
                                                prov['descripcion'] ?? ''),
                                      ),
                                    ),
                                  ),
                                  DataCell(Center(
                                      child: Text(prov['codigo_sat'] ?? ''))),
                                  DataCell(
                                    Center(
                                      child: IconButton(
                                        icon: const Icon(Icons.download,
                                            color: ProyectColors.primaryGreen),
                                        tooltip:
                                            'Descargar catálogo de precios',
                                        onPressed: () =>
                                            widget.onDescargarPrecios(
                                                prov['precios_url'] ?? ''),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Center(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit,
                                                color:
                                                    ProyectColors.primaryGreen),
                                            tooltip: 'Editar',
                                            onPressed: () =>
                                                widget.onEditar(index),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete,
                                                color: ProyectColors.danger),
                                            tooltip: 'Borrar',
                                            onPressed: () =>
                                                widget.onBorrar(index),
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
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
