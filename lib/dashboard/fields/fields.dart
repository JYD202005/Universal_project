import 'package:flutter/material.dart';
import 'package:base_de_datos_universal/colours/colours.dart';

class RegistrarArticuloFields extends StatelessWidget {
  const RegistrarArticuloFields({super.key});

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
        TextField(
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
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Marca',
                  prefixIcon: Icon(Icons.business, color: ProyectColors.primaryGreen),
                  labelStyle: const TextStyle(color: ProyectColors.textSecondary),
                  filled: true,
                  fillColor: ProyectColors.surfaceDark,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: const [],
                onChanged: (_) {},
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Línea',
                  prefixIcon: Icon(Icons.category, color: ProyectColors.primaryGreen),
                  labelStyle: const TextStyle(color: ProyectColors.textSecondary),
                  filled: true,
                  fillColor: ProyectColors.surfaceDark,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: const [],
                onChanged: (_) {},
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Familia',
                  prefixIcon: Icon(Icons.group_work, color: ProyectColors.primaryGreen),
                  labelStyle: const TextStyle(color: ProyectColors.textSecondary),
                  filled: true,
                  fillColor: ProyectColors.surfaceDark,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: const [],
                onChanged: (_) {},
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Proveedor',
                  prefixIcon: Icon(Icons.local_shipping, color: ProyectColors.primaryGreen),
                  labelStyle: const TextStyle(color: ProyectColors.textSecondary),
                  filled: true,
                  fillColor: ProyectColors.surfaceDark,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: const [],
                onChanged: (_) {},
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Precio',
                  prefixIcon: Icon(Icons.attach_money, color: ProyectColors.primaryGreen),
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
                decoration: InputDecoration(
                  labelText: 'Cantidad Inicial',
                  prefixIcon: Icon(Icons.confirmation_number, color: ProyectColors.primaryGreen),
                  labelStyle: const TextStyle(color: ProyectColors.textSecondary),
                  filled: true,
                  fillColor: ProyectColors.surfaceDark,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
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
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: ProyectColors.primaryGreen,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              // Acción de guardar
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

///////----------------Compras--------------------//////

class RegistrarCompraFields extends StatelessWidget {
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
            prefixIcon: Icon(Icons.inventory_2, color: ProyectColors.primaryGreen),
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
            prefixIcon: Icon(Icons.local_shipping, color: ProyectColors.primaryGreen),
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
                  prefixIcon: Icon(Icons.confirmation_number, color: ProyectColors.primaryGreen),
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
                decoration: InputDecoration(
                  labelText: 'Precio unitario',
                  prefixIcon: Icon(Icons.attach_money, color: ProyectColors.primaryGreen),
                  labelStyle: const TextStyle(color: ProyectColors.textSecondary),
                  filled: true,
                  fillColor: ProyectColors.surfaceDark,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
            prefixIcon: Icon(Icons.calculate, color: ProyectColors.primaryGreen),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

///////----------------Ventas--------------------//////

class RegistrarVentaFields extends StatelessWidget {
  const RegistrarVentaFields({super.key});
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
            prefixIcon: Icon(Icons.inventory_2, color: ProyectColors.primaryGreen),
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
                  prefixIcon: Icon(Icons.confirmation_number, color: ProyectColors.primaryGreen),
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
                decoration: InputDecoration(
                  labelText: 'Precio individual',
                  prefixIcon: Icon(Icons.attach_money, color: ProyectColors.primaryGreen),
                  labelStyle: const TextStyle(color: ProyectColors.textSecondary),
                  filled: true,
                  fillColor: ProyectColors.surfaceDark,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
            prefixIcon: Icon(Icons.calculate, color: ProyectColors.primaryGreen),
            labelStyle: const TextStyle(color: ProyectColors.textSecondary),
            filled: true,
            fillColor: ProyectColors.surfaceDark,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: InputDecoration(
            labelText: 'Nombre del cliente (opcional)',
            prefixIcon: Icon(Icons.person, color: ProyectColors.primaryGreen),
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

class RegistrarProveedorFields extends StatelessWidget {
  const RegistrarProveedorFields({super.key});
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
        TextField(
          decoration: InputDecoration(
            labelText: 'Nombre del proveedor',
            prefixIcon: Icon(Icons.business, color: ProyectColors.primaryGreen),
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
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Rubro',
                  prefixIcon: Icon(Icons.category, color: ProyectColors.primaryGreen),
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
                decoration: InputDecoration(
                  labelText: 'Categoría',
                  prefixIcon: Icon(Icons.layers, color: ProyectColors.primaryGreen),
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
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Familia',
                  prefixIcon: Icon(Icons.group_work, color: ProyectColors.primaryGreen),
                  labelStyle: const TextStyle(color: ProyectColors.textSecondary),
                  filled: true,
                  fillColor: ProyectColors.surfaceDark,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: const [],
                onChanged: (_) {},
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Línea',
                  prefixIcon: Icon(Icons.line_style, color: ProyectColors.primaryGreen),
                  labelStyle: const TextStyle(color: ProyectColors.textSecondary),
                  filled: true,
                  fillColor: ProyectColors.surfaceDark,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: const [],
                onChanged: (_) {},
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: InputDecoration(
            labelText: 'Descripción',
            prefixIcon: Icon(Icons.description, color: ProyectColors.primaryGreen),
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
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Código SAT',
                  prefixIcon: Icon(Icons.qr_code, color: ProyectColors.primaryGreen),
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
                decoration: InputDecoration(
                  labelText: 'Precio estimado',
                  prefixIcon: Icon(Icons.attach_money, color: ProyectColors.primaryGreen),
                  labelStyle: const TextStyle(color: ProyectColors.textSecondary),
                  filled: true,
                  fillColor: ProyectColors.surfaceDark,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                keyboardType: TextInputType.number,
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              // Acción de guardar proveedor
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
}