import 'package:flutter/material.dart';
import 'package:base_de_datos_universal/colours/colours.dart';
import 'package:base_de_datos_universal/dashboard/menubar.dart' as custom_menu;
import 'package:base_de_datos_universal/dashboard/fields/fields.dart';

class RegisterMenuScreen extends StatefulWidget {
  const RegisterMenuScreen({super.key});

  @override
  State<RegisterMenuScreen> createState() => _RegisterMenuScreenState();
}

//AppBar Desplacamiento De Submenus
class _RegisterMenuScreenState extends State<RegisterMenuScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ProyectColors.surfaceDark,
      body: Row(
        children: [
          custom_menu.MenuBar(
            selectedIndex: 1,
            onDestinationSelected: (int index) {
              setState(() {});
            },
          ),
          Expanded(
            child: DefaultTabController(
              length: 5,
              child: Scaffold(
                backgroundColor: ProyectColors.surfaceDark,
                appBar: AppBar(
                  automaticallyImplyLeading: false,
                  backgroundColor: ProyectColors.backgroundDark,
                  elevation: 0,
                  title: const Text('Registro',
                      style: TextStyle(color: ProyectColors.textPrimary)),
                  bottom: const TabBar(
                    isScrollable: true,
                    indicatorColor: ProyectColors.primaryGreen,
                    labelColor: ProyectColors.primaryGreen,
                    unselectedLabelColor: ProyectColors.textSecondary,
                    labelPadding: EdgeInsets.symmetric(
                        horizontal: 24), // Espaciado uniforme
                    tabs: [
                      Tab(
                          child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.attach_money, size: 20),
                          SizedBox(width: 8),
                          Text('Venta'),
                        ],
                      )),
                      Tab(
                          child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add, size: 20),
                          SizedBox(width: 8),
                          Text('Artículo'),
                        ],
                      )),
                      /*Tab(
                          child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shopping_cart, size: 20),
                          SizedBox(width: 8),
                          Text('Compra'),
                        ],
                      )),*/
                      Tab(
                          child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.local_shipping, size: 20),
                          SizedBox(width: 8),
                          Text('Proveedor'),
                        ],
                      )),
                      Tab(
                          child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.group, size: 20),
                          SizedBox(width: 8),
                          Text('Cliente Frecuente'),
                        ],
                      )),
                      Tab(
                          child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.tag, size: 20),
                          SizedBox(width: 8),
                          Text('Etiquetas Productos'),
                        ],
                      )),
                    ],
                  ),
                ),
                body: const TabBarView(
                  children: [
                    RegistrarVentaForm(),
                    RegistrarArticuloForm(),
                    //RegistrarCompraForm(),
                    RegistrarProveedorForm(),
                    RegistrarClienteForm(),
                    RegistrarTagForm(),
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

class RegistrarArticuloForm extends StatelessWidget {
  const RegistrarArticuloForm({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        color: ProyectColors.backgroundDark,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: RegistrarArticuloFields(), // <--- Aquí usas el widget externo
        ),
      ),
    );
  }
}

/*class RegistrarCompraForm extends StatelessWidget {
  const RegistrarCompraForm({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        color: ProyectColors.backgroundDark,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: RegistrarCompraFields(), // <--- Aquí usas el widget externo
        ),
      ),
    );
  }
}*/

class RegistrarVentaForm extends StatelessWidget {
  const RegistrarVentaForm({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        color: ProyectColors.backgroundDark,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: RegistrarVentaFields(), // <--- Aquí usas el widget externo
        ),
      ),
    );
  }
}

class RegistrarProveedorForm extends StatelessWidget {
  const RegistrarProveedorForm({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        color: ProyectColors.backgroundDark,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: RegistrarProveedorFields(), // <--- Aquí usas el widget externo
        ),
      ),
    );
  }
}

class RegistrarClienteForm extends StatelessWidget {
  const RegistrarClienteForm({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(
        child: Text('Formulario Cliente',
            style: TextStyle(color: ProyectColors.textPrimary)));
  }
}

class RegistrarTagForm extends StatelessWidget {
  const RegistrarTagForm({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(
        child: Text('Formulario tag',
            style: TextStyle(color: ProyectColors.textPrimary)));
  }
}
